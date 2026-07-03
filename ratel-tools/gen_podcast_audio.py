#!/usr/bin/env python3
"""Synthesize + host podcast audio. For each passage kind=podcast in the given
batch/draft JSON: TTS the transcript (joined sentence lines), obtain MP3, upload
to Cloudflare R2, emit/refresh a media_asset row (type=audio, uri=public URL) and
point passage.audio_ref at its asset_id + set duration_ms. Idempotent: skips
passages that already carry audio_ref unless --force.

Engine (--engine, default gcp):
  gcp    = Google Cloud Text-to-Speech (GCP_TTS_API_KEY; returns MP3 directly).
           Voice default en-US-Neural2-C. Owner engine choice (S105).
  gemini = Gemini TTS (GEMINI_API_KEY; returns PCM L16 24k -> ffmpeg MP3). Voice
           default Kore. Used for the original A1/A2 proof podcasts (0101/0102).
Env: R2_ENDPOINT,R2_BUCKET,R2_ACCESS_KEY_ID,R2_SECRET_ACCESS_KEY, optional
R2_PUBLIC_BASE; per engine GCP_TTS_API_KEY / GEMINI_API_KEY (+ GEMINI_TTS_MODEL)."""
import os, json, base64, re, subprocess, tempfile, argparse, urllib.request, urllib.error
import boto3

PUBLIC_BASE = os.environ.get("R2_PUBLIC_BASE", "https://pub-506169294d394678b41c2fcd4792375f.r2.dev")
MODEL = os.environ.get("GEMINI_TTS_MODEL", "gemini-2.5-flash-preview-tts")
PROV = {"batch_id": "batch_en_course_0001", "provenance": "ai_generated",
        "review_status": "auto_certified", "content_version": 1,
        "created_at": "2026-07-03T00:00:00Z", "updated_at": "2026-07-03T00:00:00Z"}

def gemini_tts(text, voice):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent"
    body = {"contents": [{"parts": [{"text": text}]}],
            "generationConfig": {"responseModalities": ["AUDIO"],
              "speechConfig": {"voiceConfig": {"prebuiltVoiceConfig": {"voiceName": voice}}}}}
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json", "x-goog-api-key": os.environ["GEMINI_API_KEY"]})
    try:
        with urllib.request.urlopen(req, timeout=90) as r:
            d = json.load(r)
    except urllib.error.HTTPError as e:
        raise SystemExit(f"Gemini TTS HTTP {e.code}: {e.read()[:300]}")
    part = d["candidates"][0]["content"]["parts"][0]
    idata = part.get("inlineData") or part.get("inline_data")
    mime = idata.get("mimeType") or idata.get("mime_type") or ""
    rate = int((re.search(r"rate=(\d+)", mime) or [0, 24000])[1])
    return base64.b64decode(idata["data"]), rate

def gcp_tts(text, voice, lang="en-US"):
    url = "https://texttospeech.googleapis.com/v1/text:synthesize?key=" + os.environ["GCP_TTS_API_KEY"]
    body = {"input": {"text": text}, "voice": {"languageCode": lang, "name": voice},
            "audioConfig": {"audioEncoding": "MP3"}}
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=90) as r:
            d = json.load(r)
    except urllib.error.HTTPError as e:
        raise SystemExit(f"GCP TTS HTTP {e.code}: {e.read()[:300]}")
    return base64.b64decode(d["audioContent"])

def probe_ms(path):
    dur = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration",
        "-of", "default=nk=1:nw=1", path], capture_output=True, text=True, check=True).stdout.strip()
    return int(round(float(dur) * 1000))

def encode_mp3(pcm, rate, outmp3):
    with tempfile.NamedTemporaryFile(suffix=".pcm", delete=False) as f:
        f.write(pcm); raw = f.name
    subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-f", "s16le",
        "-ar", str(rate), "-ac", "1", "-i", raw, "-b:a", "96k", outmp3, "-y"], check=True)
    os.unlink(raw)
    return probe_ms(outmp3)

def synth_mp3(engine, transcript, voice, outmp3):
    if engine == "gcp":
        open(outmp3, "wb").write(gcp_tts(transcript, voice))
        return probe_ms(outmp3)
    pcm, rate = gemini_tts(transcript, voice)
    return encode_mp3(pcm, rate, outmp3)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("path")
    ap.add_argument("--engine", default="gcp", choices=["gcp", "gemini"])
    ap.add_argument("--voice", default=None)
    ap.add_argument("--prefix", default="podcasts")
    ap.add_argument("--tts-tier", default="hd")
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()
    voice = a.voice or ("en-US-Neural2-C" if a.engine == "gcp" else "Kore")
    d = json.load(open(a.path, encoding="utf-8"))
    T = d["tables"]
    stext = {s["sentence_id"]: s["target_text"] for s in T.get("sentence", [])}
    media = T.setdefault("media_asset", [])
    media_by_id = {m["asset_id"]: m for m in media}
    s3 = boto3.client("s3", endpoint_url=os.environ["R2_ENDPOINT"],
        aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"], region_name="auto")
    bucket = os.environ["R2_BUCKET"]
    n = 0
    for p in T.get("passage", []):
        if p.get("kind") != "podcast":
            continue
        if p.get("audio_ref") and not a.force:
            print("skip (has audio_ref):", p["passage_id"]); continue
        lines = [stext[r] for r in p["sentence_refs"] if r in stext]
        mp3 = f"/tmp/{p['passage_id']}.mp3"
        dur_ms = synth_mp3(a.engine, " ".join(lines), voice, mp3)
        key = f"{a.prefix}/{p['passage_id']}.mp3"
        s3.put_object(Bucket=bucket, Key=key, Body=open(mp3, "rb").read(),
            ContentType="audio/mpeg", CacheControl="public, max-age=31536000, immutable")
        url = f"{PUBLIC_BASE}/{key}"
        asset_id = "mediaasset_" + p["passage_id"].split("passage_", 1)[-1]
        row = {"asset_id": asset_id, "type": "audio", "uri": url,
               "locale": p.get("locale", "en"), "voice_id": voice,
               "tts_tier": a.tts_tier, "duration_ms": dur_ms, "provenance": PROV}
        if asset_id in media_by_id:
            media_by_id[asset_id].clear(); media_by_id[asset_id].update(row)
        else:
            media.append(row); media_by_id[asset_id] = row
        p["audio_ref"] = asset_id
        p["duration_ms"] = dur_ms
        n += 1
        print(f"OK {p['passage_id']} [{a.engine}/{voice}] -> {asset_id} dur={dur_ms}ms {url}")
    json.dump(d, open(a.path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print(f"patched {n} podcast passage(s); media_asset rows now {len(media)}")

if __name__ == "__main__":
    main()
