#!/usr/bin/env python3
"""T1.1 codegen: schema/ (JSON-Schema 2020-12 — the SoT, P0-6) -> Dart freezed models.

Emits lib/content/models/{enums,payloads,tables,models}.dart. After running, do
`dart run build_runner build` to generate the .freezed.dart/.g.dart parts.
Keep schema the single source of truth: re-run on any schema change (CI drift gate
asserts the emitted sources have no uncommitted diff)."""
from __future__ import annotations

import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCHEMA = ROOT / "schema"
OUT = ROOT / "lib" / "content" / "models"

TABLES = ["sentence", "vocab_entry", "sense", "grammar_point", "phoneme",
          "item", "locale", "media_asset", "gloss",
          # Stage-3 user/runtime tables (P0-2, L1)
          "user", "user_course", "user_item_state", "user_phoneme_state",
          "placement_session", "review_log", "credit_ledger"]
PAYLOADS = ["normalization_flags", "answer_spec", "token", "script_meta", "provenance"]

DART_AVOID = {
    "num", "part", "dynamic", "default", "in", "is", "as", "if", "else", "for", "while",
    "do", "switch", "case", "this", "new", "null", "true", "false", "void", "int", "double",
    "bool", "var", "final", "const", "class", "enum", "extends", "with", "show", "hide",
    "return", "super", "try", "catch", "throw", "assert", "break", "continue", "typedef",
    "library", "import", "export", "abstract", "mixin", "implements", "operator", "get",
    "set", "static", "external", "factory", "covariant", "late", "required", "sealed", "base",
}


def _load(rel: str) -> dict:
    return json.loads((SCHEMA / rel).read_text(encoding="utf-8"))


ENUMS = _load("enums/enums.schema.json")["$defs"]
COMMON = _load("defs/common.schema.json")["$defs"]

# --- Enum forward-compatibility policy (P2-1, one-way door #18) --------------------------------
# These $defs are CLOSED, versioned controlled vocabularies (R-C12): adding a value is a global,
# versioned catalog event, never a silent per-language addition. DEFAULT = HARD_REJECT (fail-closed):
# an unknown wire value RAISES at decode instead of being coerced, so a client older than the catalog
# can never mis-handle versioned content / financial / scheduler semantics. GRACEFUL_DEGRADE (an
# `unknown` sentinel) is reserved for a read-only, display-only enum where a forward value must not
# crash an older client — none qualify today. EVERY string enum MUST be classified here or codegen
# fails (the door #18 guard), forcing the reject-vs-degrade decision at authoring time.
HARD_REJECT = "hard_reject"
GRACEFUL_DEGRADE = "graceful_degrade"
ENUM_FORWARD_COMPAT = {
    "cefr_level": HARD_REJECT, "cefr_ceiling": HARD_REJECT, "exercise_type": HARD_REJECT,
    "pos": HARD_REJECT, "difficulty_band": HARD_REJECT, "provenance_kind": HARD_REJECT,
    "review_status": HARD_REJECT, "tts_tier": HARD_REJECT, "pron_capability": HARD_REJECT,
    "text_direction": HARD_REJECT, "item_direction": HARD_REJECT, "contrast_type": HARD_REJECT,
    "media_type": HARD_REJECT, "content_kind": HARD_REJECT, "plural_category": HARD_REJECT,
    "unicode_norm": HARD_REJECT, "fsrs_state": HARD_REJECT, "ledger_entry_type": HARD_REJECT,
    "grant_source": HARD_REJECT,
}


def pascal(s: str) -> str:
    return "".join(w[:1].upper() + w[1:] for w in re.split(r"[_\s]+", s) if w)


def camel(s: str) -> str:
    p = pascal(s)
    return p[:1].lower() + p[1:] if p else p


def enum_member(v: str) -> str:
    parts = re.split(r"[_\s]+", v)
    ident = parts[0].lower() + "".join(w[:1].upper() + w[1:] for w in parts[1:])
    if ident and ident[0].isdigit():
        ident = "v" + ident
    if ident in DART_AVOID:
        ident += "_"
    return ident


PRIMITIVE = {"content_id": "String", "bcp47": "String", "uuid": "String", "user_id": "String"}
OPENMAP = {"features": "Map<String, Object?>", "prosody": "Map<String, Object?>"}
PAYLOAD = {"provenance": "Provenance", "token": "Token", "answer_spec": "AnswerSpec",
           "normalization_flags": "NormalizationFlags", "script_meta": "ScriptMeta"}


def _refname(ref: str) -> str:
    return ref.split("#/$defs/")[-1]


def dart_type(s: dict) -> str:
    if "$ref" in s:
        n = _refname(s["$ref"])
        if "enums.json" in s["$ref"]:
            d = ENUMS[n]
            if "enum" in d:
                return pascal(n)
            return "int" if d.get("type") == "integer" else "String"
        if n in PRIMITIVE:
            return PRIMITIVE[n]
        if n in OPENMAP:
            return OPENMAP[n]
        if n in PAYLOAD:
            return PAYLOAD[n]
        raise SystemExit(f"unmapped common $ref: {n}")
    if "oneOf" in s:
        non_null = [x for x in s["oneOf"] if x.get("type") != "null"]
        return dart_type(non_null[0])
    t = s.get("type")
    simple = {"string": "String", "integer": "int", "number": "double",
              "boolean": "bool", "object": "Map<String, Object?>"}
    if t in simple:
        return simple[t]
    if t == "array":
        return f"List<{dart_type(s['items'])}>"
    return "Object?"


def gen_enum(name: str, d: dict, policy: str = HARD_REJECT) -> str:
    # Forward-compat (P2-1, door #18): HARD_REJECT keeps the closed-vocabulary contract fail-closed —
    # NO sentinel is emitted, so json_serializable's generated decoder RAISES on an unknown wire value
    # (a client older than the versioned catalog must fail loudly, never silently coerce).
    # GRACEFUL_DEGRADE appends ONE `unknown` sentinel (no @JsonValue); field sites then add
    # @JsonKey(unknownEnumValue: <Enum>.unknown). Hard-reject output is byte-identical to the
    # pre-policy generator (no Dart artifact churn).
    degrade = policy == GRACEFUL_DEGRADE
    vals = list(d["enum"])
    total = len(vals) + (1 if degrade else 0)
    out = ["@JsonEnum()", f"enum {pascal(name)} {{"]
    for i, v in enumerate(vals):
        sep = "," if i < total - 1 else ";"
        out.append(f"  @JsonValue('{v}') {enum_member(v)}{sep}")
    if degrade:
        out.append("  unknown;  // forward-compat sentinel (no @JsonValue); decode falls back here")
    out.append("}")
    return "\n".join(out)


def gen_class(cls: str, obj: dict) -> str:
    props = obj["properties"]
    req = set(obj.get("required", []))
    lines = ["@freezed", f"abstract class {cls} with _${cls} {{", f"  const factory {cls}({{"]
    for k, sub in props.items():
        dt = dart_type(sub)
        cm = camel(k)
        jk = f"@JsonKey(name: '{k}') " if cm != k else ""
        if k in req:
            lines.append(f"    {jk}required {dt} {cm},")
        else:
            lines.append(f"    {jk}{dt}? {cm},")
    lines.append(f"  }}) = _{cls};")
    lines.append(f"  factory {cls}.fromJson(Map<String, dynamic> json) => _${cls}FromJson(json);")
    lines.append("}")
    return "\n".join(lines)


HDR = ("// GENERATED by ratel-tools/codegen_dart.py from schema/ (P0-6). DO NOT EDIT BY HAND.\n"
       "// Regenerate: python3 ratel-tools/codegen_dart.py && dart run build_runner build\n")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    # enums.dart
    e = [HDR, "import 'package:json_annotation/json_annotation.dart';", ""]
    for k, v in ENUMS.items():
        if "enum" in v:
            policy = ENUM_FORWARD_COMPAT.get(k)
            if policy is None:
                raise SystemExit(
                    f"enum '{k}' has no forward-compat policy (P2-1, door #18): classify it "
                    f"HARD_REJECT (default, fail-closed) or GRACEFUL_DEGRADE in ENUM_FORWARD_COMPAT")
            e.append(gen_enum(k, v, policy))
            e.append("")
    (OUT / "enums.dart").write_text("\n".join(e), encoding="utf-8")

    # payloads.dart
    p = [HDR, "import 'package:freezed_annotation/freezed_annotation.dart';", "import 'enums.dart';",
         "", "part 'payloads.freezed.dart';", "part 'payloads.g.dart';", ""]
    for name in PAYLOADS:
        p.append(gen_class(pascal(name), COMMON[name]))
        p.append("")
    (OUT / "payloads.dart").write_text("\n".join(p), encoding="utf-8")

    # tables.dart
    t = [HDR, "import 'package:freezed_annotation/freezed_annotation.dart';", "import 'enums.dart';",
         "import 'payloads.dart';", "", "part 'tables.freezed.dart';", "part 'tables.g.dart';", ""]
    for tbl in TABLES:
        t.append(gen_class(pascal(tbl), _load(f"tables/{tbl}.schema.json")))
        t.append("")
    (OUT / "tables.dart").write_text("\n".join(t), encoding="utf-8")

    # barrel
    (OUT / "models.dart").write_text(
        HDR + "\nexport 'enums.dart';\nexport 'payloads.dart';\nexport 'tables.dart';\n", encoding="utf-8")

    print("generated:", ", ".join(sorted(f.name for f in OUT.glob("*.dart"))))


if __name__ == "__main__":
    main()
