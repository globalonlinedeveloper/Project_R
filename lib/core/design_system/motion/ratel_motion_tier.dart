import 'package:flutter/widgets.dart';

/// Device performance class feeding the motion signal (from the R-N1 perf tier).
enum PerfTier { high, mid, low }

/// Unified motion-tier signal (R-N7). Accessibility (OS reduce-motion) is a HARD
/// floor that performance "full" can never override (WCAG 2.3.3 / 2.2.2, R-K8).
enum MotionTier { full, reduced, minimal, none }

extension MotionTierX on MotionTier {
  /// Decorative looping (idle ambient) is only allowed at full.
  bool get allowsLooping => this == MotionTier.full;

  /// Enter/exit + page transitions allowed at full and reduced.
  bool get allowsTransitions =>
      this == MotionTier.full || this == MotionTier.reduced;

  /// minimal/none collapse motion to final-state stills.
  bool get isStatic => this == MotionTier.minimal || this == MotionTier.none;
}

/// Resolve the single motion tier every animated widget reads (R-N7).
///
/// Order (accessibility wins over capability, always):
///  - OS reduce-motion on  -> minimal (static stills, no motion)
///  - low-power or low perf -> minimal
///  - mid perf             -> reduced
///  - otherwise            -> full
MotionTier resolveMotionTier({
  required bool osReduceMotion,
  required PerfTier perfTier,
  bool lowPowerMode = false,
}) {
  if (osReduceMotion) return MotionTier.minimal;
  if (lowPowerMode || perfTier == PerfTier.low) return MotionTier.minimal;
  if (perfTier == PerfTier.mid) return MotionTier.reduced;
  return MotionTier.full;
}

/// Read the resolved tier from context. OS reduce-motion comes from MediaQuery
/// (`disableAnimations`); [perfTier] is injected (defaults high until the R-N1
/// device-tier probe lands in a later increment).
MotionTier motionTierOf(BuildContext context, {PerfTier perfTier = PerfTier.high}) {
  final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return resolveMotionTier(osReduceMotion: disable, perfTier: perfTier);
}

/// User-facing motion preference (Profile › Settings). Folds into the resolved
/// [MotionTier] via [effectiveMotionTier]; OS reduce-motion stays a HARD floor.
enum MotionPreference { high, reduced, off }

int _motionLevel(MotionTier t) => switch (t) {
      MotionTier.full => 3,
      MotionTier.reduced => 2,
      MotionTier.minimal => 1,
      MotionTier.none => 0,
    };

MotionTier _motionForLevel(int level) {
  if (level >= 3) return MotionTier.full;
  if (level == 2) return MotionTier.reduced;
  if (level == 1) return MotionTier.minimal;
  return MotionTier.none;
}

/// The effective tier every galaxy/world widget reads: the MOST restrictive of
/// the device perf capability, the user's [MotionPreference], and the OS
/// reduce-motion floor. OS reduce-motion caps at [MotionTier.minimal] — a HARD
/// accessibility floor (WCAG 2.3.3 / 2.2.2) that "high" can never override;
/// choosing "off" collapses to [MotionTier.none] (fully static).
MotionTier effectiveMotionTier({
  required bool osReduceMotion,
  required PerfTier perfTier,
  MotionPreference motionPreference = MotionPreference.high,
  bool lowPowerMode = false,
}) {
  final perf = resolveMotionTier(
    osReduceMotion: false,
    perfTier: perfTier,
    lowPowerMode: lowPowerMode,
  );
  final user = switch (motionPreference) {
    MotionPreference.high => MotionTier.full,
    MotionPreference.reduced => MotionTier.reduced,
    MotionPreference.off => MotionTier.none,
  };
  final osFloor = osReduceMotion ? MotionTier.minimal : MotionTier.full;
  final level =
      [perf, user, osFloor].map(_motionLevel).reduce((a, b) => a < b ? a : b);
  return _motionForLevel(level);
}
// Traceability: R-WT5 (motion preference + OS reduce-motion hard floor)
