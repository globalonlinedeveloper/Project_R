from __future__ import annotations

from typing import Protocol

from .types import Candidate


class Generator(Protocol):
    def generate(self, locale: str, exercise_type: str, count: int) -> list[Candidate]: ...


class StubGenerator:
    """Deterministic, NETWORK-FREE generator. The real pipeline feeds in content
    pre-generated via the subscription here; no metered API is called. Emits
    schema-shaped Item candidates so the scaffold runs end-to-end offline."""

    def generate(self, locale: str, exercise_type: str, count: int) -> list[Candidate]:
        out: list[Candidate] = []
        for i in range(1, count + 1):
            out.append(
                Candidate(
                    table="item",
                    row={
                        "item_id": f"item_{locale}_{exercise_type}_{i:04d}",
                        "locale": locale,
                        "exercise_type": exercise_type,
                        "enum_version": 1,
                        "prompt_ref": f"prompt_{locale}_{exercise_type}_{i:04d}",
                        "answer_spec": {"accepted": [f"answer{i}"], "normalization_flags": {"fold_case": True}},
                        "skill_ids": [f"skill_{locale}_core"],
                        "cefr_level": "A1",
                        "difficulty_band": "core",
                    },
                )
            )
        return out
