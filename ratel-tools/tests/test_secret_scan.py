"""M7 [P0-6 · TS-5] secret-scan guard.

Fails the build if a real-shaped secret is ever committed: a Supabase/JWT service-role or
anon key, a `sb_secret_` key, a Stripe `sk_live_`/`sk_test_` key, a Google `AIza…` key, or
a PEM private key. Patterns require the FULL secret shape, so bare prefixes in prose/docs
(e.g. the word ``service_role`` or a lone ``sk_live_``) do not trip. The scanner, its own
fixtures, and the build-ahead backlog (which lists example patterns) are allow-listed so
the guard never self-flags.

Runs in CI two ways: the whole-dir ``python -m pytest ratel-tools/tests`` in the
python-schema-gate, plus an explicit secret-scan step. Planted-secret fixtures are written
to a pytest ``tmp_path`` (outside the repo) and the fake values are concatenated at runtime
so this source file contains no full-shape secret of its own.

BUILD-AHEAD — not deployed; pending human review + go-live wiring.
GO-LIVE STOP: actual key rotation + injecting the real key into the server runtime.
"""
import pathlib
import re

REPO = pathlib.Path(__file__).resolve().parents[2]

# Full-shape secret patterns (a bare prefix without a value does NOT match).
PATTERNS = {
    "jwt": re.compile(r"eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}"),
    "sb_secret": re.compile(r"sb_secret_[A-Za-z0-9]{20,}"),
    "stripe": re.compile(r"sk_(?:live|test)_[A-Za-z0-9]{16,}"),
    "google": re.compile(r"AIza[0-9A-Za-z_-]{35}"),
    "pem": re.compile(r"-----BEGIN (?:[A-Z0-9 ]+ )?PRIVATE KEY-----"),
}

# Directories never worth scanning (vcs, build output, vendored SDKs, caches).
SKIP_DIRS = {
    ".git", "build", ".dart_tool", ".pub-cache", "flutter", "node_modules",
    ".idea", ".build", "Pods", ".gradle",
}
# Binary/asset extensions skipped (base64-ish blobs would false-positive).
BIN_EXT = {
    ".png", ".jpg", ".jpeg", ".gif", ".ico", ".webp", ".ttf", ".otf", ".woff",
    ".woff2", ".riv", ".so", ".bin", ".jar", ".keystore", ".zip", ".xz", ".gz",
    ".tar", ".wasm", ".class", ".pdf", ".mp3", ".mp4", ".lock",
}
# Allow-list: the scanner itself + the build-ahead backlog (example patterns), relative
# to the repo root. Intentional example/fixture text lives here and must not trip.
EXCLUDE_FILES = {
    "ratel-tools/tests/test_secret_scan.py",
    "docs/STAGE3_PARTB_LOCAL_BACKLOG.md",
    "Apps/STAGE3_PARTB_LOCAL_BACKLOG.md",
}


def scan_tree(root):
    """Return [(path, pattern_name, match)] for every full-shape secret under root."""
    root = pathlib.Path(root)
    findings = []
    for p in root.rglob("*"):
        if not p.is_file():
            continue
        if any(part in SKIP_DIRS for part in p.parts):
            continue
        if p.suffix.lower() in BIN_EXT:
            continue
        try:
            rel = str(p.resolve().relative_to(REPO))
        except ValueError:
            rel = None
        if rel in EXCLUDE_FILES:
            continue
        try:
            txt = p.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        for name, rx in PATTERNS.items():
            for m in rx.finditer(txt):
                findings.append((str(p), name, m.group(0)))
    return findings


def test_repo_tree_has_no_committed_secrets():
    findings = scan_tree(REPO)
    assert findings == [], f"committed secret(s) detected: {findings}"


def test_scanner_flags_each_planted_secret(tmp_path):
    # Build full-shape fakes by concatenation so this file holds no real secret.
    jwt = "eyJ" + "a" * 20 + "." + "b" * 20 + "." + "c" * 20
    samples = {
        "creds.txt": "sk_" + "live_" + "A" * 24,
        "dot.env": "sb_secret_" + "B" * 24,
        "token.json": jwt,
        "id_rsa": "-----BEGIN RSA PRIVATE KEY-----",
        "config.dart": "AIza" + "C" * 35,
    }
    for fn, content in samples.items():
        (tmp_path / fn).write_text(content)
    found = {name for _, name, _ in scan_tree(tmp_path)}
    assert found == {"stripe", "sb_secret", "jwt", "pem", "google"}, found


def test_plain_begin_private_key_is_flagged(tmp_path):
    (tmp_path / "k.pem").write_text("-----BEGIN PRIVATE KEY-----\nMIIxxx\n")
    assert any(n == "pem" for _, n, _ in scan_tree(tmp_path))


def test_near_miss_not_flagged(tmp_path):
    # A variable named after the role + bare prefixes with NO value must not trip.
    (tmp_path / "ok.dart").write_text(
        'final serviceRole = readEnv("SERVICE_ROLE");\n'
        '// mentions sk_live_ sb_secret_ AIza eyJ but carries no value\n'
    )
    assert scan_tree(tmp_path) == []


def test_scanner_and_backlog_are_allow_listed():
    # The scanner file and the backlog are excluded by construction...
    assert "ratel-tools/tests/test_secret_scan.py" in EXCLUDE_FILES
    # ...and the real repo (which contains them) still scans clean.
    assert scan_tree(REPO) == []
