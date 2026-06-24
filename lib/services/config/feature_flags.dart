// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// FLAGS-1 [R-M2] — feature-flag & experiment EVALUATION core (dark-launch, A/B,
// wave gating, emergency kill-switch, minimum-supported-version gate).
//
// R-M2 specifies a server-evaluated flag/experiment layer: flip features by
// config (no app update), run A/B tests, gate content waves + staged platform
// rollout, and — if the flag service is unreachable — fall back to a SAFE
// baked-in default that NEVER blocks learning. This file is the pure,
// deterministic DECISION core of that layer; the live config transport is an
// injected seam.
//
// Build-ahead-able here (pure Dart, ZERO I/O, ZERO clock, ZERO RNG):
//   • [FeatureFlags]  — resolve a feature on/off (and gameplay/limit constants)
//     from an injected remote snapshot, with an emergency kill-switch that ALWAYS
//     wins, and a safe compiled-in default when the snapshot lacks a key or the
//     service is unreachable (snapshot == null).
//   • [MinVersionGate] — the minimum-supported-version check. It FAILS OPEN: a
//     null/unparseable current version, or absent thresholds, never locks anyone
//     out (returns [VersionVerdict.ok]).
//   • [Experiments]   — deterministic A/B assignment by a STABLE HASH of
//     (salt:userId) — same user, same bucket, every session/device, no RNG —
//     honoring the kill-switch and excluding minors (and unknown-age, fail
//     closed) from NON-essential experiments.
//   • [RolloutGate]   — deterministic percentage / wave gating (content wave +
//     staged platform rollout) by the same stable hash.
//
// Seam notes (go-live wiring — all STAY OUT of this file):
//   • [FlagConfig] is the INJECTED resolved snapshot. At go-live it is hydrated
//     from Firebase Remote Config + a small Supabase feature_flags/tier_overlay
//     table (signed, versioned, rollback-able), fetched on startup / server-side.
//     A `null` snapshot models an unreachable service → safe compiled-in
//     [FlagDefaults] (learning is never blocked).
//   • the audience ([FlagAudience]) is supplied by the verified age gate (the
//     minor-safe identity model); `unknown` fails closed (treated as a minor).
//   • bucketing is a stable hash, NOT randomness, so assignments are reproducible
//     and need no stored per-user bucket table.
//
// GO-LIVE STOP: wire [FlagConfig] to the real Remote Config + Supabase flag fetch
// (with signature / version / rollback verification), feed [FlagAudience] from the
// age gate, and surface the [MinVersionGate] verdict in the startup flow. No live
// config service, key, or deploy is consumed here.

/// Audience class for experiment eligibility, supplied at go-live by the verified
/// age gate. [unknown] FAILS CLOSED — treated like a [minor] for exclusion — so an
/// unverified user is never enrolled in a non-essential experiment.
enum FlagAudience {
  adult,
  minor,
  unknown;

  /// Only a known [adult] is eligible for NON-essential experiments; minors and
  /// unknown-age users are excluded (fail closed).
  bool get eligibleForNonEssential => this == FlagAudience.adult;
}

/// Compiled-in SAFE defaults (launch-locked), used when the remote snapshot is
/// unreachable or does not carry a key. These never block learning.
class FlagDefaults {
  const FlagDefaults({
    this.flags = const <String, bool>{},
    this.numbers = const <String, num>{},
  });

  /// Default on/off for each feature key (an absent key resolves OFF).
  final Map<String, bool> flags;

  /// Default gameplay/limit constants (XP, energy, caps, ad frequency, …).
  final Map<String, num> numbers;
}

/// The INJECTED resolved remote snapshot (Firebase Remote Config + the Supabase
/// feature_flags/tier_overlay table at go-live). A `null` snapshot models an
/// unreachable service — callers then fall back to [FlagDefaults].
class FlagConfig {
  const FlagConfig({
    this.flags = const <String, bool>{},
    this.numbers = const <String, num>{},
    this.killed = const <String>{},
  });

  /// Remotely-set feature on/off values (override the defaults).
  final Map<String, bool> flags;

  /// Remotely-set gameplay/limit constants (override the defaults).
  final Map<String, num> numbers;

  /// Emergency kill-switch: feature / experiment keys forced OFF during an
  /// incident. A killed key ALWAYS resolves off (or to control), overriding any
  /// remote or default value.
  final Set<String> killed;
}

/// Pure feature-flag + constant resolver. No I/O, no clock, no randomness.
class FeatureFlags {
  const FeatureFlags(this.defaults, {this.config});

  /// Compiled-in safe defaults (always present).
  final FlagDefaults defaults;

  /// Resolved remote snapshot; `null` ⇒ service unreachable ⇒ use [defaults].
  final FlagConfig? config;

  /// Whether [key] is enabled. The kill-switch wins; then a remote value; then
  /// the compiled-in default; an unknown key is OFF (conservative).
  bool isEnabled(String key) {
    final cfg = config;
    if (cfg != null && cfg.killed.contains(key)) {
      return false;
    }
    final remote = cfg?.flags[key];
    if (remote != null) {
      return remote;
    }
    return defaults.flags[key] ?? false;
  }

  /// A gameplay/limit constant for [key]: a remote value if present, else the
  /// compiled-in default, else [fallback]. (The kill-switch applies to features,
  /// not to constants.)
  num number(String key, {num fallback = 0}) {
    final remote = config?.numbers[key];
    if (remote != null) {
      return remote;
    }
    return defaults.numbers[key] ?? fallback;
  }
}

/// Outcome of the minimum-supported-version check.
enum VersionVerdict {
  /// At or above the recommended version — no action.
  ok,

  /// Below recommended (but at/above the floor) — soft "update available" nudge.
  updateAvailable,

  /// Below the hard floor — blocking "please update".
  updateRequired;

  bool get isOk => this == VersionVerdict.ok;
}

/// A dotted numeric app version (major.minor.patch). Pre-release / build metadata
/// (after `-` or `+`) is ignored. Parsing is lenient and returns `null` on
/// anything unparseable, so the gate can FAIL OPEN.
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch)
      : assert(major >= 0),
        assert(minor >= 0),
        assert(patch >= 0);

  final int major;
  final int minor;
  final int patch;

  /// Parse `"1.4.0"` (also `"1.4"`, `"1.4.0-beta+7"`). Returns `null` when the
  /// numeric core is missing or any present component is non-numeric.
  static AppVersion? tryParse(String? raw) {
    if (raw == null) {
      return null;
    }
    var core = raw.trim();
    if (core.isEmpty) {
      return null;
    }
    for (final sep in const <String>['-', '+']) {
      final i = core.indexOf(sep);
      if (i >= 0) {
        core = core.substring(0, i);
      }
    }
    if (core.isEmpty) {
      return null;
    }
    final parts = core.split('.');
    if (parts.length > 3) {
      return null;
    }
    final nums = <int>[0, 0, 0];
    for (var i = 0; i < parts.length; i++) {
      final n = int.tryParse(parts[i]);
      if (n == null || n < 0) {
        return null;
      }
      nums[i] = n;
    }
    return AppVersion(nums[0], nums[1], nums[2]);
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) {
      return major.compareTo(other.major);
    }
    if (minor != other.minor) {
      return minor.compareTo(other.minor);
    }
    return patch.compareTo(other.patch);
  }

  @override
  bool operator ==(Object other) =>
      other is AppVersion &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// The minimum-supported-version gate. FAILS OPEN: a null/unparseable current
/// version, or absent thresholds, yields [VersionVerdict.ok] — a network blip or
/// bad config never locks a user out.
class MinVersionGate {
  const MinVersionGate({this.floor, this.recommended});

  /// Below this hard floor ⇒ [VersionVerdict.updateRequired]. `null` ⇒ no floor.
  final AppVersion? floor;

  /// Below this (but at/above [floor]) ⇒ [VersionVerdict.updateAvailable].
  /// `null` ⇒ no soft nudge.
  final AppVersion? recommended;

  /// Evaluate a parsed [current] version (FAILS OPEN on `null`).
  VersionVerdict evaluate(AppVersion? current) {
    if (current == null) {
      return VersionVerdict.ok;
    }
    final f = floor;
    if (f != null && current.compareTo(f) < 0) {
      return VersionVerdict.updateRequired;
    }
    final r = recommended;
    if (r != null && current.compareTo(r) < 0) {
      return VersionVerdict.updateAvailable;
    }
    return VersionVerdict.ok;
  }

  /// Convenience: parse [current] then [evaluate]; an unparseable string FAILS
  /// OPEN to [VersionVerdict.ok].
  VersionVerdict evaluateRaw(String? current) =>
      evaluate(AppVersion.tryParse(current));
}

/// One A/B variant: a [name] and a non-negative integer [weight] (relative share).
class Variant {
  const Variant(this.name, this.weight) : assert(weight >= 0);

  final String name;
  final int weight;
}

/// An A/B experiment. The FIRST variant is the control (the safe default cohort).
class Experiment {
  const Experiment(
    this.key,
    this.variants, {
    this.essential = false,
    this.salt,
  });

  /// Stable experiment key (also the kill-switch key).
  final String key;

  /// Variants; `variants.first` is the control.
  final List<Variant> variants;

  /// Essential experiments enroll everyone; NON-essential ones exclude minors
  /// (and unknown-age). Defaults to non-essential.
  final bool essential;

  /// Bucketing salt; defaults to [key] when `null`.
  final String? salt;
}

/// Pure A/B assignment. Deterministic by a stable hash of (salt:userId) — no RNG,
/// no clock, no I/O — so a user keeps the same variant across sessions/devices.
class Experiments {
  const Experiments({this.config});

  /// Resolved snapshot, consulted only for the per-experiment kill-switch.
  final FlagConfig? config;

  /// Assign [userId] to a variant of [exp]. Returns the control when the
  /// experiment is killed, when a non-essential experiment is shown to a
  /// minor / unknown audience, or when total weight is non-positive.
  String assign(
    Experiment exp, {
    required String userId,
    required FlagAudience audience,
  }) {
    final control = exp.variants.first.name;
    final cfg = config;
    if (cfg != null && cfg.killed.contains(exp.key)) {
      return control;
    }
    if (!exp.essential && !audience.eligibleForNonEssential) {
      return control;
    }
    var total = 0;
    for (final v in exp.variants) {
      total += v.weight;
    }
    if (total <= 0) {
      return control;
    }
    final bucket = _stableHash('${exp.salt ?? exp.key}:$userId') % total;
    var cumulative = 0;
    for (final v in exp.variants) {
      cumulative += v.weight;
      if (bucket < cumulative) {
        return v.name;
      }
    }
    return control;
  }
}

/// Deterministic percentage / wave gate (content wave + staged platform rollout).
class RolloutGate {
  const RolloutGate();

  /// Whether [userId] is inside a [percent] (0..100) rollout of [key]. Stable per
  /// user; `percent <= 0` ⇒ nobody, `percent >= 100` ⇒ everybody.
  bool inRollout(String key, {required String userId, required int percent}) {
    if (percent <= 0) {
      return false;
    }
    if (percent >= 100) {
      return true;
    }
    return _stableHash('rollout:$key:$userId') % 100 < percent;
  }
}

/// Stable, dependency-free string hash (polynomial mod a Mersenne prime).
/// Intermediate products stay < 2^53, so the result is identical on the Dart VM
/// and on compiled web (no 64-bit / JS divergence). Deterministic — NOT RNG.
const int _hashMod = 2147483647; // 2^31 - 1
int _stableHash(String s) {
  var h = 0;
  for (final unit in s.codeUnits) {
    h = (h * 31 + unit) % _hashMod;
  }
  return h;
}
