import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';

void main() {
  test('classic is the default world; space is opt-in', () {
    const s = AppSettings();
    expect(s.world, WorldThemeId.classic);
    expect(s.motion, MotionPreference.high);
    expect(WorldTheme.of(WorldThemeId.classic).isSpace, isFalse);
    expect(WorldTheme.of(WorldThemeId.space).isSpace, isTrue);
  });

  test('classic uses the shipped light tokens; space uses the deep-space set', () {
    expect(WorldTheme.classic.tokens, same(RatelColorTokens.light));
    expect(WorldTheme.space.tokens, same(SpacePalette.tokens));
    // The whole-app surface flips to deep space when Space is active.
    expect(WorldTheme.space.tokens.surface, SpacePalette.phoneBg);
    expect(WorldTheme.space.tokens.brightness, Brightness.dark);
  });

  test('AppSettings serialises round-trip (persistence contract)', () {
    const a = AppSettings(
      world: WorldThemeId.space,
      motion: MotionPreference.reduced,
      highContrast: true,
      sound: false,
      haptics: false,
    );
    final b = AppSettings.fromMap(a.toMap());
    expect(b, a);
  });

  test('fromMap tolerates missing/garbage keys (defaults, never throws)', () {
    final a = AppSettings.fromMap(<String, Object?>{'world': 'nonsense'});
    expect(a.world, WorldThemeId.classic);
    expect(a.sound, isTrue);
  });
}
// Traceability: R-WT1 R-WT2 R-WT3
