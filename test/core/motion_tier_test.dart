import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';

void main() {
  test('OS reduce-motion is a hard floor over any perf tier (R-N7)', () {
    for (final p in PerfTier.values) {
      expect(
        resolveMotionTier(osReduceMotion: true, perfTier: p),
        MotionTier.minimal,
      );
    }
  });

  test('perf tier maps to full/reduced/minimal when motion is allowed', () {
    expect(resolveMotionTier(osReduceMotion: false, perfTier: PerfTier.high),
        MotionTier.full);
    expect(resolveMotionTier(osReduceMotion: false, perfTier: PerfTier.mid),
        MotionTier.reduced);
    expect(resolveMotionTier(osReduceMotion: false, perfTier: PerfTier.low),
        MotionTier.minimal);
  });

  test('low-power forces minimal even on high perf', () {
    expect(
      resolveMotionTier(
          osReduceMotion: false, perfTier: PerfTier.high, lowPowerMode: true),
      MotionTier.minimal,
    );
  });

  test('tier helpers gate looping and transitions', () {
    expect(MotionTier.full.allowsLooping, isTrue);
    expect(MotionTier.reduced.allowsLooping, isFalse);
    expect(MotionTier.reduced.allowsTransitions, isTrue);
    expect(MotionTier.minimal.isStatic, isTrue);
    expect(MotionTier.none.isStatic, isTrue);
  });
}
