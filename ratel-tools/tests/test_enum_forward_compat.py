"""L6 [P2-1, one-way door #18] enum forward-compatibility policy. Every closed controlled
vocabulary (R-C12) is classified HARD_REJECT (fail-closed) or GRACEFUL_DEGRADE; codegen fails on an
unclassified enum; HARD_REJECT emits NO `unknown` sentinel (the json_serializable decoder raises on
an unknown wire value); GRACEFUL_DEGRADE emits exactly one sentinel with no @JsonValue. Pure-Python;
imports the generator without side effects (generation is gated behind main())."""
import importlib
import inspect
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))  # ratel-tools/
cg = importlib.import_module("codegen_dart")


def _string_enums():
    return [k for k, v in cg.ENUMS.items() if "enum" in v]


def test_every_string_enum_is_classified():
    """The door #18 guard: no string enum may ship without an explicit forward-compat decision."""
    missing = [k for k in _string_enums() if k not in cg.ENUM_FORWARD_COMPAT]
    assert not missing, f"unclassified enums (codegen would abort): {missing}"
    for k in _string_enums():
        assert cg.ENUM_FORWARD_COMPAT[k] in (cg.HARD_REJECT, cg.GRACEFUL_DEGRADE)


def test_default_is_fail_closed():
    assert all(p == cg.HARD_REJECT for p in cg.ENUM_FORWARD_COMPAT.values())
    assert inspect.signature(cg.gen_enum).parameters["policy"].default == cg.HARD_REJECT


def test_money_and_scheduler_enums_are_hard_reject():
    for k in ("ledger_entry_type", "grant_source", "fsrs_state", "cefr_level", "exercise_type"):
        assert cg.ENUM_FORWARD_COMPAT[k] == cg.HARD_REJECT, f"{k} must stay fail-closed"


def test_hard_reject_emits_no_sentinel():
    out = cg.gen_enum("ledger_entry_type", cg.ENUMS["ledger_entry_type"], cg.HARD_REJECT)
    assert "unknown" not in out
    assert "@JsonValue('refund') refund;" in out  # last member terminated with ';'
    assert out.endswith("}")


def test_hard_reject_is_byte_identical_to_default():
    """Encoding the policy must not churn the committed Dart: explicit hard-reject == the default."""
    for k in _string_enums():
        assert cg.gen_enum(k, cg.ENUMS[k]) == cg.gen_enum(k, cg.ENUMS[k], cg.HARD_REJECT)


def test_graceful_degrade_emits_single_unvalued_sentinel():
    out = cg.gen_enum("demo", {"enum": ["a", "b"]}, cg.GRACEFUL_DEGRADE)
    assert out.count("unknown;") == 1                 # exactly one sentinel, list-terminating
    assert "@JsonValue('unknown')" not in out         # sentinel carries NO wire value
    assert "@JsonValue('b') b," in out                # prior last member now comma-separated
    assert "@JsonValue('a') a," in out


def test_fsrs_state_shape_unchanged():
    """Closed enum stays exactly its declared values (no silent widening)."""
    out = cg.gen_enum("fsrs_state", cg.ENUMS["fsrs_state"], cg.HARD_REJECT)
    assert out == ("@JsonEnum()\nenum FsrsState {\n"
                   "  @JsonValue('new') new_,\n"
                   "  @JsonValue('learning') learning,\n"
                   "  @JsonValue('review') review,\n"
                   "  @JsonValue('relearning') relearning;\n}")


if __name__ == "__main__":
    import subprocess
    raise SystemExit(subprocess.call([sys.executable, "-m", "pytest", __file__, "-q"]))
