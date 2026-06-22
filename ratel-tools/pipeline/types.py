from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum


class Decision(str, Enum):
    auto_certified = "auto_certified"  # passes validators + jury -> publishable
    needs_review = "needs_review"      # held back; routed to regen (D1: no human slice)


@dataclass
class Candidate:
    table: str
    row: dict  # content row WITHOUT final provenance (stamped at the gate)


@dataclass
class JuryVerdict:
    score: float  # 0..1 agreement/confidence (free local open-weight jury, R-E3)
    notes: str = ""


@dataclass
class GateResult:
    candidate: Candidate
    decision: Decision
    jury: JuryVerdict
    validator_errors: list[str] = field(default_factory=list)
    reasons: list[str] = field(default_factory=list)
