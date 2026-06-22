from __future__ import annotations

from .types import Candidate, Decision, GateResult, JuryVerdict

DEFAULT_THRESHOLD = 0.85


def decide(
    candidate: Candidate,
    verdict: JuryVerdict,
    validator_errors: list[str],
    threshold: float = DEFAULT_THRESHOLD,
) -> GateResult:
    reasons: list[str] = []
    ok = True
    if validator_errors:
        ok = False
        reasons.append(f"{len(validator_errors)} validator error(s)")
    if verdict.score < threshold:
        ok = False
        reasons.append(f"jury {verdict.score} < {threshold}")
    decision = Decision.auto_certified if ok else Decision.needs_review
    return GateResult(
        candidate=candidate, decision=decision, jury=verdict,
        validator_errors=validator_errors, reasons=reasons,
    )
