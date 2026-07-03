#!/usr/bin/env python3
"""S106 resumable re-voice driver. Re-voice an EXPLICIT allowlist of 12 podcast
passages to ONE Google Cloud TTS voice (default en-US-Chirp3-HD-Kore) via the
plain GCP_TTS_API_KEY (v1 text:synthesize; NO Vertex, NO service account). Per
passage: transcript = join(sentence_refs -> sentence.target_text) -> MP3 ->
overwrite the SAME R2 key podcasts/<passage_id>.mp3 (uri UNCHANGED) -> refresh
ONLY media_asset.voice_id + duration_ms (asset_id/uri/tts_tier/provenance
UNCHANGED). Resumable: a state file records done ids; the batch is written
atomically after each item. NEVER touches passages outside the allowlist (the
audio-less A1 sample passage_en_a1_pod_0001 is intentionally excluded)."""
import os, json, base64, subprocess, argparse, urllib.request, urllib.error, tempfile
import boto3

TARGETS = [
    "passage_en_a1_podcast_0101", "passage_en_a2_podcast_0102",
    "passage_en_a1_podcast_0103", "passage_en_a2_podcast_0104",
    "passage_en_b1_podcast_0105", "passage_en_b1_podcast_0106",
    "passage_en_b2_podcast_0107", "passage_en_b2_podcast_0108",
    "passage_en_c1_podcast_0109", "passage_en_c1_podcast_0110",
    "passage_en_c2_podcast_0111", "passage_en_c2_podcast_0112",
]

def gcp_tts(text, voice, lang="en-US"):
    url = "https://texttospeech.googleapis.com/v1/text:synthesize?key=" + os.environ["GCP_TTS_API_KEY"]
    body = {"input": {"text": text}, "voice": {"languageCode": lang, "name": voice},
            "audioConfig": {"audioEncoding": "MP3"}}
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            d = json.load(r)
    except urllib.error.HTTPError as e:
        raise SystemExit(f"GCP TTS HTTP {e.code}: {e.read()[:300]}")
    return base64.b64decode(d["audioContent"])

def probe_ms(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                          "-of", "default=nk=1:nw=1", path],
                         capture_output=True, text=True, check=True).stdout.strip()
    return int(round(float(out) * 1000))

def atomic_write(path, obj):
    d = os.path.dirname(path) or "."
    fd, tmp = tempfile.mkstemp(dir=d, suffix=".tmp"); os.close(fd)
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
    os.replace(tmp, path)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--batch", required=True)
    ap.add_argument("--voice", default="en-US-Chirp3-HD-Kore")
    ap.add_argument("--prefix", default="podcasts")
    ap.add_argument("--state", default="/sessions/hopeful-jolly-wozniak/revoice_state.json")
    ap.add_argument("--max", type=int, default=99)
    a = ap.parse_args()
    state = json.load(open(a.state)) if os.path.exists(a.state) else {"done": {}}
    d = json.load(open(a.batch, encoding="utf-8")); T = d["tables"]
    S = {s["sentence_id"]: s["target_text"] for s in T["sentence"]}
    P = {p["passage_id"]: p for p in T["passage"]}
    M = {m["asset_id"]: m for m in T["media_asset"]}
    s3 = boto3.client("s3", endpoint_url=os.environ["R2_ENDPOINT"],
                      aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
                      aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"], region_name="auto")
    bucket = os.environ["R2_BUCKET"]
    remaining = [pid for pid in TARGETS if pid not in state["done"]]
    todo = remaining[:a.max]
    print(f"targets remaining={len(remaining)} processing_this_leg={len(todo)}")
    for pid in todo:
        p = P[pid]
        assert p.get("kind") == "podcast", f"{pid} not a podcast"
        aid = p["audio_ref"]; m = M[aid]
        transcript = " ".join(S[r] for r in p["sentence_refs"] if r in S)
        mp3 = f"/sessions/hopeful-jolly-wozniak/audio/{pid}.mp3"
        open(mp3, "wb").write(gcp_tts(transcript, a.voice))
        dur = probe_ms(mp3); size = os.path.getsize(mp3)
        assert 3000 <= dur <= 60000, f"{pid} implausible duration {dur}ms"
        key = f"{a.prefix}/{pid}.mp3"
        s3.put_object(Bucket=bucket, Key=key, Body=open(mp3, "rb").read(),
                      ContentType="audio/mpeg",
                      CacheControl="public, max-age=31536000, immutable")
        h = s3.head_object(Bucket=bucket, Key=key)
        assert h["ContentLength"] == size, (pid, h["ContentLength"], size)
        old_voice = m.get("voice_id"); old_dur = m.get("duration_ms")
        m["voice_id"] = a.voice; m["duration_ms"] = dur   # ONLY these two fields
        atomic_write(a.batch, d)
        state["done"][pid] = {"voice": a.voice, "dur_ms": dur, "was": f"{old_voice}/{old_dur}",
                              "size": size, "etag": h["ETag"].strip('"'), "key": key}
        atomic_write(a.state, state)
        print(f"OK {pid}  {old_voice}->{a.voice}  dur {old_dur}->{dur}ms  size={size}B  etag={h['ETag'].strip(chr(34))[:16]}")
    print(f"leg done. total done={len(state['done'])}/{len(TARGETS)}")

if __name__ == "__main__":
    main()
