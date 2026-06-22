from __future__ import annotations

import argparse
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from .gate import DEFAULT_THRESHOLD, decide  # noqa: E402
from .generate import Generator, StubGenerator  # noqa: E402
from .jury import Jury, StubJury  # noqa: E402
from .types import Decision  # noqa: E402
from .validate import run_validators  # noqa: E402

FIXED_NOW = "2026-06-23T00:00:00Z"


def _prov(batch_id: str, review_status: str, now: str) -> dict:
    return {
        "batch_id": batch_id,
        "provenance": "ai_generated",
        "model_version": "subscription/stub-0",
        "review_status": review_status,
        "content_version": 1,
        "created_at": now,
        "updated_at": now,
    }


def run_pipeline(
    locale: str,
    exercise_type: str,
    count: int,
    *,
    generator: Generator | None = None,
    jury: Jury | None = None,
    threshold: float = DEFAULT_THRESHOLD,
    batch_id: str | None = None,
    now: str = FIXED_NOW,
):
    generator = generator or StubGenerator()
    jury = jury or StubJury()
    batch_id = batch_id or f"batch_{locale}_{exercise_type}_{now[:10].replace('-', '')}"

    published: dict[str, list[dict]] = {}
    results = []
    for cand in generator.generate(locale, exercise_type, count):
        verdict = jury.assess(cand)
        # structural validation needs a complete row -> stamp a draft provenance
        errors = run_validators(cand.table, {**cand.row, "provenance": _prov(batch_id, "draft", now)})
        res = decide(cand, verdict, errors, threshold)
        results.append(res)
        if res.decision is Decision.auto_certified:
            row = {**cand.row, "provenance": _prov(batch_id, res.decision.value, now)}
            published.setdefault(cand.table, []).append(row)

    batch = {"batch_id": batch_id, "schema_version": "2020-12-1", "locale": locale, "tables": published}
    summary = {
        "candidates": len(results),
        "auto_certified": sum(1 for r in results if r.decision is Decision.auto_certified),
        "needs_review": sum(1 for r in results if r.decision is Decision.needs_review),
    }
    return batch, summary, results


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="RATEL content pipeline (subscription-only; NO metered API).")
    ap.add_argument("--locale", default="en")
    ap.add_argument("--type", dest="exercise_type", default="mcq")
    ap.add_argument("--count", type=int, default=3)
    ap.add_argument("--out", default=None, help="write the gated batch JSON; omit for a dry-run summary")
    args = ap.parse_args(argv)

    batch, summary, _ = run_pipeline(args.locale, args.exercise_type, args.count)
    # post-emit guard: every published row must validate against the frozen schema
    for table, rows in batch["tables"].items():
        for i, row in enumerate(rows):
            errs = run_validators(table, row)
            if errs:
                print(f"FATAL: published {table} row {i} invalid: {errs}", file=sys.stderr)
                return 2
    if args.out:
        pathlib.Path(args.out).write_text(json.dumps(batch, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"wrote {args.out}: {summary}")
    else:
        print("DRY-RUN", json.dumps(summary), "published:", {k: len(v) for k, v in batch["tables"].items()})
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
