#!/usr/bin/env python3
"""Publish course content to the R2/CDN content base (C-2, plan §B; O-1 = R2).

For every bundled course `assets/content/<code>/course.batch.json`:
  - upload a CONTENT-ADDRESSED versioned copy  content/<code>/course.<sha12>.json
    (immutable long-cache; identical content never re-uploads, changed content
    always gets a NEW key -> zero stale-cache risk),
  - then rewrite the tiny catalog  content/manifest.json  (short-cache) that the
    app fetches first: {"schema":1,"generated_at":...,"courses":[{code,batch_id,
    sha,path,rows,bytes}]}. `path` is RELATIVE to the content base.
Also asserts a GET/HEAD-only public CORS policy on the bucket (course files are
public data; the web app fetches them cross-origin from learnwithratel.com).

GRACEFUL DEGRADE (CI-safe, mirrors the Android-signing pattern): when the R2_*
env vars are absent the script prints a notice and exits 0, so deploy-web stays
green until the owner adds the secrets. Locally: source Apps/.cowork-private/
secrets.env first.
"""
import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

REQUIRED = ("R2_ACCESS_KEY_ID", "R2_SECRET_ACCESS_KEY", "R2_ENDPOINT", "R2_BUCKET")
PREFIX = "content"
CONTENT_CACHE = "public, max-age=31536000, immutable"
MANIFEST_CACHE = "public, max-age=300"


def main() -> int:
    missing = [k for k in REQUIRED if not os.environ.get(k)]
    if missing:
        print(f"::notice::R2 secrets absent ({', '.join(missing)}) — content publish SKIPPED (graceful).")
        return 0
    import boto3  # deferred so the skip path needs no dependency

    s3 = boto3.client(
        "s3",
        endpoint_url=os.environ["R2_ENDPOINT"],
        aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"],
        region_name="auto",
    )
    bucket = os.environ["R2_BUCKET"]

    root = Path(__file__).resolve().parent.parent / "assets" / "content"
    courses = []
    for batch_file in sorted(root.glob("*/course.batch.json")):
        code = batch_file.parent.name
        raw = batch_file.read_bytes()
        data = json.loads(raw)  # fail loudly on unparseable content — never publish garbage
        sha = hashlib.sha256(raw).hexdigest()[:12]
        rows = sum(len(v) for v in data.get("tables", {}).values() if isinstance(v, list))
        rel = f"{code}/course.{sha}.json"
        key = f"{PREFIX}/{rel}"
        try:
            s3.head_object(Bucket=bucket, Key=key)
            state = "exists (skipped)"
        except Exception:
            s3.put_object(
                Bucket=bucket, Key=key, Body=raw,
                ContentType="application/json",
                CacheControl=CONTENT_CACHE,
            )
            state = "uploaded"
        courses.append({
            "code": code,
            "batch_id": str(data.get("batch_id", "")),
            "sha": sha,
            "path": rel,
            "rows": rows,
            "bytes": len(raw),
        })
        print(f"  {code}: {rows} rows, {len(raw)} B -> {key} [{state}]")

    if not courses:
        print("::warning::no bundled courses found — manifest NOT rewritten")
        return 1

    manifest = {
        "schema": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "courses": courses,
    }
    s3.put_object(
        Bucket=bucket, Key=f"{PREFIX}/manifest.json",
        Body=json.dumps(manifest, separators=(",", ":")).encode(),
        ContentType="application/json",
        CacheControl=MANIFEST_CACHE,
    )
    print(f"  manifest: {len(courses)} course(s) -> {PREFIX}/manifest.json")

    # Public read-only CORS (GET/HEAD) so the web app can fetch cross-origin.
    s3.put_bucket_cors(Bucket=bucket, CORSConfiguration={
        "CORSRules": [{
            "AllowedOrigins": ["*"],
            "AllowedMethods": ["GET", "HEAD"],
            "AllowedHeaders": ["*"],
            "MaxAgeSeconds": 86400,
        }]
    })
    print("  CORS: GET/HEAD from any origin asserted on the bucket")
    return 0


if __name__ == "__main__":
    sys.exit(main())
