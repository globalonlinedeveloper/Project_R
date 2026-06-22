from __future__ import annotations

from typing import Protocol

from .types import Candidate, JuryVerdict


class Jury(Protocol):
    def assess(self, candidate: Candidate) -> JuryVerdict: ...


class StubJury:
    """Deterministic, network-free stand-in for the free local open-weight jury
    (R-E3, $0). Real jury swaps in behind this Protocol with no pipeline change."""

    def assess(self, candidate: Candidate) -> JuryVerdict:
        row = candidate.row
        score = 1.0
        notes: list[str] = []
        if candidate.table == "item":
            accepted = (row.get("answer_spec") or {}).get("accepted") or []
            if not accepted:
                score -= 0.6
                notes.append("no accepted answers")
            if not row.get("skill_ids"):
                score -= 0.3
                notes.append("no skill_ids")
        return JuryVerdict(score=round(score, 3), notes="; ".join(notes))
