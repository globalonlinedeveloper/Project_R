import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/theme/world_registry.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// The 31-world registry is ported VERBATIM from the design `THEMES()` (no dummy
/// data). These lock the count, the free/Pro gating, and a spot-check of the
/// ported palette against the design so a regeneration drift is caught.
void main() {
  group('theme world registry (design THEMES() port)', () {
    test('has all 31 designed worlds', () {
      expect(kThemeWorlds.length, 31);
    });

    test('exactly 2 free worlds — light + savanna (design FREE list)', () {
      expect(kFreeWorldIds, <String>{'light', 'savanna'});
      final Set<String> free = kThemeWorlds.values
          .where((ThemeWorld w) => w.isFree)
          .map((ThemeWorld w) => w.id)
          .toSet();
      expect(free, <String>{'light', 'savanna'});
      for (final ThemeWorld w in kThemeWorlds.values) {
        expect(w.isFree, kFreeWorldIds.contains(w.id), reason: w.id);
      }
    });

    test('map key equals world id; label/vehicle/backdrop present', () {
      kThemeWorlds.forEach((String key, ThemeWorld w) {
        expect(w.id, key);
        expect(w.label, isNotEmpty, reason: key);
        expect(w.vehicle, isNotEmpty, reason: key);
        expect(w.backdrop, isNotEmpty, reason: key);
      });
    });

    test('the two shipped worlds are present with the expected shape', () {
      expect(kThemeWorlds.containsKey('light'), isTrue);
      expect(kThemeWorlds.containsKey('galaxy'), isTrue);
      expect(kThemeWorlds['galaxy']!.backdrop, 'stars');
      expect(kThemeWorlds['galaxy']!.isDark, isTrue);
      expect(kThemeWorlds['light']!.isDark, isFalse);
      expect(kThemeWorlds['light']!.backdrop, 'none');
    });

    test('light palette matches the design tokens verbatim', () {
      final WorldPalette p = kThemeWorlds['light']!.palette;
      expect(p.accent, const Color(0xFF16A085)); // --accent teal
      expect(p.text, const Color(0xFF1B1D1F)); // --text
      expect(p.bg, const Color(0xFFF6F3EC)); // --bg
      expect(p.gold, const Color(0xFFE0972B)); // --gold
    });

    test('every world has real (non-transparent) accent + text colors', () {
      for (final ThemeWorld w in kThemeWorlds.values) {
        expect(w.palette.accent, isNot(const Color(0x00000000)),
            reason: '${w.id} accent');
        expect(w.palette.text, isNot(const Color(0x00000000)),
            reason: '${w.id} text');
      }
    });
  });
}
