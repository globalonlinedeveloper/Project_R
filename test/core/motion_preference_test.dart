import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';

void main() {
  test('OS reduce-motion is a HARD floor over any user preference', () {
    for (final pref in MotionPreference.values) {
      expect(
        effectiveMotionTier(
            osReduceMotion: true,
            perfTier: PerfTier.high,
            motionPreference: pref),
        anyOf(MotionTier.minimal, MotionTier.none),
        reason: 'OS reduce-motion must cap motion regardless of "$pref"',
      );
    }
    // Specifically: high pref + OS reduce-motion collapses to minimal.
    expect(
      effectiveMotionTier(
          osReduceMotion: true,
          perfTier: PerfTier.high,
          motionPreference: MotionPreference.high),
      MotionTier.minimal,
    );
  });

  test('user "off" collapses to none; "reduced" caps at reduced; "high" full', () {
    expect(
      effectiveMotionTier(
          osReduceMotion: false,
          perfTier: PerfTier.high,
          motionPreference: MotionPreference.off),
      MotionTier.none,
    );
    expect(
      effectiveMotionTier(
          osReduceMotion: false,
          perfTier: PerfTier.high,
          motionPreference: MotionPreference.reduced),
      MotionTier.reduced,
    );
    expect(
      effectiveMotionTier(
          osReduceMotion: false,
          perfTier: PerfTier.high,
          motionPreference: MotionPreference.high),
      MotionTier.full,
    );
  });

  test('low device perf still caps motion under a "high" preference', () {
    expect(
      effectiveMotionTier(
          osReduceMotion: false,
          perfTier: PerfTier.low,
          motionPreference: MotionPreference.high),
      MotionTier.minimal,
    );
  });
}
// Traceability: R-WT5
