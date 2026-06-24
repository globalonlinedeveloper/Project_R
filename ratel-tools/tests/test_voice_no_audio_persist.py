"""VOICE-1 [R-K3 · R-H7 · P0-14 · P1-13] — no-raw-audio / no-voiceprint schema guard.

R-K3 locks realtime-voice safety to TEXT transcripts only: raw audio is NEVER stored, and a
voiceprint / biometric enrollment template is NEVER even DERIVED (a voiceprint is biometric
PII under GDPR Art. 9 + the amended COPPA rule; P1-13). See RATEL_REQUIREMENTS.md R-K3 — the
"strict transient-only: never derive or persist raw audio, voiceprints, or enrollment
templates" line and the "voice moderation = text, not audio" line — plus P0-14 ("moderate
derived TEXT transcripts only; reported turn keeps text, never audio").

This guard is a pure, hermetic STATIC scan of schema/sql/*.sql (no DB, no network, stdlib
only). It fails the build CLOSED if any CREATE TABLE column — or any table / type name —
would persist:

  (A) raw audio BYTES: an audio/voice/speech-named column whose declared TYPE is a binary
      blob (bytea / blob / bytes / bit / varbinary / …), or whose name carries a raw-bytes
      shape (raw_audio, audio_blob, audio_data, *_pcm / *_wav / *_mp3, waveform,
      spectrogram, …); or
  (B) a VOICEPRINT / BIOMETRIC / enrollment-template column or table (voiceprint, biometric,
      voice|speaker embedding / template / vector / print, enrollment_template, …) —
      forbidden OUTRIGHT regardless of type, because the template must never be derived,
      let alone stored.

Explicitly ALLOWED (never flagged), per R-K3 / the MediaAsset-reference rule / change #52:
  * TEXT transcripts (transcript / transcription / caption / subtitle columns) — moderation
    runs on derived text; a reported turn retains only its TEXT, moderated in the R-H7 relay;
  * MediaAsset audio *references* — a pointer to a pre-rendered TTS clip (audio_ref,
    audio_url, *_path / *_id / *_key / *_asset) is a reference, NOT raw user speech
    ("Audio is a MediaAsset reference … never inlined").

SQL line/block comments and dollar-quoted function bodies are STRIPPED before scanning, so a
comment that merely says "never store a raw audio blob / transcript" (e.g. 0008_audit_log.sql)
does NOT self-trip — only real column / identifier DDL is inspected.

Runs in CI two ways: the whole-dir ``python -m pytest ratel-tools/tests`` in the
python-schema-gate, plus an explicit voice-safety step.

BUILD-AHEAD — not deployed; pending human review + go-live wiring.
GO-LIVE STOP: this guard constrains the SCHEMA only. The matching RUNTIME promise — the
realtime-voice relay deriving TEXT transcripts and discarding audio in memory, never writing
audio / voiceprint anywhere (R-H7 / R-K3) — is wired + signed off at go-live, not here.
"""
import pathlib
import re

REPO = pathlib.Path(__file__).resolve().parents[2]
SCHEMA_DIR = REPO / "schema" / "sql"

# ── identifier token sets ─────────────────────────────────────────────────────────────────────
# Unambiguous audio/voice/speech markers (kept deliberately tight — no "mel"/"samples", which
# also name statistical columns — so a non-audio column never false-positives).
AUDIO_PARTS = {
    "audio", "voice", "speech", "utterance", "utterances", "recording", "recordings",
    "waveform", "spectrogram", "pcm", "wav", "mp3", "opus", "ogg", "m4a", "aac", "flac", "mfcc",
}
# Parts that signal RAW BYTES (vs a reference / text). Only ever consulted once an AUDIO part
# is already present in the same identifier.
BYTES_PARTS = {
    "blob", "bytes", "byte", "raw", "binary", "buffer", "data", "b64", "base64",
    "pcm", "wav", "mp3", "opus", "ogg", "m4a", "aac", "flac", "waveform", "spectrogram",
}
# Column TYPES that hold opaque bytes.
BINARY_TYPES = {
    "bytea", "blob", "bytes", "bit", "varbinary", "binary", "oid", "lo",
    "tinyblob", "mediumblob", "longblob",
}
# A column whose LAST part is one of these is a REFERENCE / pointer, not stored bytes.
REF_SUFFIX = {"ref", "url", "uri", "path", "id", "key", "asset", "href", "src", "link", "loc"}
# Explicitly-allowed TEXT-transcript markers.
TRANSCRIPT_PARTS = {
    "transcript", "transcription", "transcripts", "caption", "captions", "subtitle", "subtitles",
}
# Biometric / voiceprint forbidden identifiers (Rule B + the DDL-wide text safety net).
BIOMETRIC_RX = re.compile(
    r"voiceprints?"
    r"|voice[_ ]?print"
    r"|biometric"
    r"|faceprint"
    r"|(?:voice|speaker)[_ ]?(?:embedding|template|vector|print|fingerprint)"
    r"|enroll?ment[_ ]?template",
    re.IGNORECASE,
)
CONSTRAINT_KW = {
    "primary", "foreign", "unique", "constraint", "check", "exclude", "like", "partition",
}


# ── comment / body stripping + table parsing ───────────────────────────────────────────────────
def strip_sql(sql):
    """Drop dollar-quoted bodies, block comments, and line comments — leaving only real DDL."""
    sql = re.sub(r"\$([A-Za-z_]*)\$.*?\$\1\$", " ", sql, flags=re.DOTALL)  # $fn$ … $fn$ / $$ … $$
    sql = re.sub(r"/\*.*?\*/", " ", sql, flags=re.DOTALL)                  # /* … */
    sql = re.sub(r"--[^\n]*", " ", sql)                                    # -- … EOL
    return sql


def _split_top(body):
    """Split a CREATE TABLE body on top-level (paren-depth 0) commas."""
    out, depth, cur = [], 0, []
    for ch in body:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            out.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    tail = "".join(cur)
    if tail.strip():
        out.append(tail)
    return out


_CREATE_RX = re.compile(
    r'CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:"([^"]+)"|([A-Za-z_]\w*))\s*\(',
    re.IGNORECASE,
)


def parse_tables(sql):
    """Return [(table, [(col, type_base), …]), …] for real, column-bearing CREATE TABLEs.

    Comments + function bodies are stripped first. ``CREATE TABLE … PARTITION OF …`` has no
    column list (no ``(`` directly after the name) so it never matches — partitions are skipped.
    """
    sql = strip_sql(sql)
    tables = []
    for m in _CREATE_RX.finditer(sql):
        name = m.group(1) or m.group(2)
        depth, j = 1, m.end()
        while j < len(sql) and depth:
            if sql[j] == "(":
                depth += 1
            elif sql[j] == ")":
                depth -= 1
            j += 1
        body = sql[m.end():j - 1]
        cols = []
        for item in _split_top(body):
            toks = item.split()
            if not toks:
                continue
            first = toks[0].strip('"').lower()
            if first in CONSTRAINT_KW:
                continue
            typ = toks[1].strip('",').lower() if len(toks) > 1 else ""
            cols.append((first, typ))
        tables.append((name, cols))
    return tables


# ── violation predicates ────────────────────────────────────────────────────────────────────────
def _parts(name):
    return [p for p in re.split(r"[^a-z0-9]+", name.lower()) if p]


def is_biometric(name):
    return bool(BIOMETRIC_RX.search(name))


def is_transcript(name):
    return any(p in TRANSCRIPT_PARTS for p in _parts(name))


def is_reference(name):
    p = _parts(name)
    return bool(p) and p[-1] in REF_SUFFIX


def audio_violation(col, typ):
    """Reason string if (col, typ) would persist raw audio, else None."""
    parts = set(_parts(col))
    if not (parts & AUDIO_PARTS):
        return None
    if is_transcript(col):           # text transcripts are explicitly allowed
        return None
    type_base = typ.split("(")[0]
    if type_base in BINARY_TYPES:    # audio-named column of binary type = raw bytes
        return "audio-named column of binary type %r" % typ
    if (parts & BYTES_PARTS) and not is_reference(col):   # raw-bytes shape in a non-ref column
        return "audio column with raw-bytes shape"
    return None                      # audio_ref / audio_url / voice_locale … = allowed reference


def scan_sql(text):
    """Return [(table, column, type, reason), …] for one SQL string (empty == clean)."""
    findings = []
    stripped = strip_sql(text)
    # Rule B safety net: a biometric/voiceprint token ANYWHERE in real (non-comment) DDL —
    # a CREATE TYPE, an index expression, a default — not just a parsed column.
    for m in BIOMETRIC_RX.finditer(stripped):
        findings.append(("<ddl>", m.group(0), "", "voiceprint/biometric identifier in DDL"))
    for table, cols in parse_tables(text):
        if is_biometric(table):
            findings.append((table, "<table>", "", "biometric/voiceprint table name"))
        for col, typ in cols:
            if is_biometric(col):
                findings.append((table, col, typ, "voiceprint/biometric column"))
                continue
            reason = audio_violation(col, typ)
            if reason:
                findings.append((table, col, typ, reason))
    return findings


def scan_dir(d):
    findings = []
    for p in sorted(pathlib.Path(d).glob("*.sql")):
        for f in scan_sql(p.read_text(encoding="utf-8")):
            findings.append((p.name,) + f)
    return findings


# ── the live invariant ────────────────────────────────────────────────────────────────────────
def test_live_schema_persists_no_raw_audio_or_voiceprint():
    findings = scan_dir(SCHEMA_DIR)
    assert findings == [], f"R-K3 voice-safety violation(s) in schema/sql: {findings}"


def test_scanner_actually_parsed_the_real_tables():
    # Guard against a vacuous pass (a broken glob / parser that silently sees nothing).
    names, all_cols = [], []
    for p in sorted(SCHEMA_DIR.glob("*.sql")):
        for t, cols in parse_tables(p.read_text(encoding="utf-8")):
            names.append(t)
            all_cols += cols
    assert len(names) >= 8, f"expected >=8 column-bearing tables, parsed {names}"
    assert ("user_id", "uuid") in all_cols, "known column user_id uuid not parsed"
    assert {"user", "audit_log"} <= set(names), f"known tables missing: {names}"
    # partitions (no column list) must be excluded
    assert not ({"review_log_2026_06", "review_log_2026_07"} & set(names)), names


# ── Rule A: raw-audio bytes are flagged ─────────────────────────────────────────────────────────
def test_flags_raw_audio_bytea_column():
    f = scan_sql("CREATE TABLE rec (id uuid, raw_audio bytea, created_at timestamptz);")
    assert any(c == "raw_audio" for _, c, _, _ in f), f


def test_flags_base64_audio_in_text_column():
    # base64 audio smuggled into a text column still trips the raw-bytes-shape rule
    assert any(c == "audio_blob" for _, c, _, _ in scan_sql("CREATE TABLE r (id uuid, audio_blob text);"))


def test_flags_binary_voice_recording_and_pcm_waveform():
    assert scan_sql("CREATE TABLE t (voice_recording bytea);")
    assert scan_sql("CREATE TABLE a (waveform bytea);")
    assert scan_sql("CREATE TABLE b (utterance_pcm bytea);")


# ── Rule B: voiceprints / biometric templates are flagged regardless of type ────────────────────
def test_flags_voiceprint_column():
    assert scan_sql("CREATE TABLE u (id uuid, voiceprint bytea);")


def test_flags_voice_embedding_even_as_float_array():
    # a DERIVED voice embedding (a voiceprint by another name) is biometric PII whatever the type
    assert scan_sql("CREATE TABLE u (id uuid, voice_embedding double precision[]);")


def test_flags_biometric_or_speaker_template_table():
    assert scan_sql("CREATE TABLE speaker_template (id uuid, vec bytea);")
    assert scan_sql("CREATE TABLE biometric_enrollment (id uuid, note text);")


def test_flags_biometric_token_outside_a_column():
    # the safety net catches a biometric token in a CREATE TYPE / index, not just a column
    assert scan_sql("CREATE TYPE voiceprint_kind AS ENUM ('x');")


# ── allowed shapes must NOT flag (transcripts, MediaAsset refs, ordinary columns, comments) ─────
def test_allows_text_transcript_column():
    assert scan_sql("CREATE TABLE turn (id uuid, transcript text, created_at timestamptz);") == []


def test_allows_mediaasset_audio_references():
    ddl = ("CREATE TABLE media_asset (id uuid, audio_ref text, audio_ref_slow text, "
           "audio_url text, audio_asset_id uuid);")
    assert scan_sql(ddl) == []


def test_allows_phoneme_state_and_ordinary_columns():
    ddl = ("CREATE TABLE user_phoneme_state (phoneme_id text, mastery double precision, "
           "responses jsonb);")
    assert scan_sql(ddl) == []


def test_comment_mentioning_audio_blob_and_voiceprint_does_not_trip():
    ddl = ("-- never store a raw audio blob or a voiceprint here\n"
           "/* transcripts stay text-only */\n"
           "CREATE TABLE t (id uuid, note text);")
    assert scan_sql(ddl) == []


def test_function_body_mentioning_voiceprint_does_not_trip():
    ddl = ("CREATE FUNCTION f() RETURNS void LANGUAGE plpgsql AS $fn$\n"
           "BEGIN\n"
           "  -- body mentions voiceprint and raw_audio bytea only in a comment/string\n"
           "  RAISE NOTICE 'no biometric data is ever stored';\n"
           "END $fn$;")
    assert scan_sql(ddl) == []


def test_scan_is_deterministic_and_clean_on_repeat():
    assert scan_dir(SCHEMA_DIR) == scan_dir(SCHEMA_DIR) == []
