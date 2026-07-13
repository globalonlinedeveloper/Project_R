import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// i18n regression guards (audit RATEL_I18N_HARDCODED_AUDIT.md §15). Added AFTER
/// the user-facing surfaces + all 10 ARB locales were brought to parity (S144–
/// S147, increments I1–I4), so the surfaces are clean and this test HOLDS the
/// line: a NEW hard-coded user-facing English literal — or a resurfaced
/// "52 languages" / Spanish-veneer claim — fails the build.
void main() {
  // ------------------------------------------------------------------------
  // Guard 1 — no hard-coded user-facing string literals in the two surface
  // trees. Route copy through context.l10n.<key> (add the key to app_en.arb).
  // ------------------------------------------------------------------------
  test('no hard-coded user-facing literals in features / core components', () {
    const List<String> scope = <String>['lib/features', 'lib/core/components'];

    // Constructors / named params that put a raw string in front of the user.
    final RegExp textCtor = RegExp(r'''\bText\(\s*(['"])(.*?)\1''');
    final RegExp namedText = RegExp(
        r'''\b(?:hintText|helperText|semanticLabel|tooltip|label)\s*:\s*(['"])(.*?)\1''');
    final RegExp hasWord = RegExp(r'[A-Za-z]{2,}'); // >=2 ASCII letters = real copy
    final RegExp cefr = RegExp(r'^[ABC][12]$'); // A1..C2

    // Brand tokens (design system; audit §13.3) — never localized.
    const Set<String> brand = <String>{'Ratel', 'RATEL', 'PRO', 'RATEL PRO', 'XP'};
    // Stable placeholder EXAMPLES (like '@mia') — not sentence copy.
    const Set<String> placeholders = <String>{'yourname'};
    // Render-map IDENTIFIERS localized AT the render site (audit §13.6): the
    // settings goal presets + theme-mode records carry their English id and are
    // shown via ratelGoalDisplayLabel / _themeLabel.
    const Set<String> renderIds = <String>{
      'Casual', 'Regular', 'Serious', 'Intense', // settings _goals
      'Match device', 'Light', 'Dark', // settings theme-mode records
    };
    // Whole files that are a documented English fallback / unreachable stub.
    const Set<String> exemptFiles = <String>{
      'lib/core/components/ratel_bottom_nav.dart', // defaultTabs fallback (§13.7)
      'lib/features/common/coming_soon_screen.dart', // dead stub (§14)
    };

    bool allowed(String lit) {
      final String s = lit.trim();
      if (s.contains(r'$')) return true; // interpolation -> dynamic / localized
      if (!hasWord.hasMatch(s)) return true; // emoji / punctuation / digits only
      if (cefr.hasMatch(s)) return true;
      // Drop non-ASCII (emoji) + collapse spaces, then match the allowlist sets,
      // so an emoji-prefixed brand like '🔒 PRO' resolves to 'PRO'.
      final String norm = s
          .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      return brand.contains(norm) ||
          placeholders.contains(norm) ||
          renderIds.contains(norm);
    }

    final List<String> offenders = <String>[];
    for (final String dir in scope) {
      final Directory d = Directory(dir);
      expect(d.existsSync(), isTrue, reason: 'run from the package root ($dir)');
      for (final FileSystemEntity e in d.listSync(recursive: true)) {
        if (e is! File || !e.path.endsWith('.dart')) continue;
        final String norm = e.path.replaceAll(r'\', '/');
        if (exemptFiles.contains(norm)) continue;
        final List<String> lines = e.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final String t = lines[i].trimLeft();
          if (t.startsWith('//') || t.startsWith('*')) continue; // comments
          for (final RegExp p in <RegExp>[textCtor, namedText]) {
            for (final RegExpMatch m in p.allMatches(lines[i])) {
              final String lit = m.group(2)!;
              if (!allowed(lit)) offenders.add('$norm:${i + 1}: "$lit"');
            }
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'New user-facing string literal(s) found. Route copy through '
          'context.l10n.<key> (add the key to lib/l10n/app_en.arb + translate). '
          'If genuinely by-design (brand / CEFR / emoji / render-map id), extend '
          'the allowlist in this test:\n${offenders.join('\n')}',
    );
  });

  // ------------------------------------------------------------------------
  // Guard 2 — no "52 languages" / Spanish-veneer copy in ANY ARB value. The
  // app teaches English from 10 languages (audit §12); legit language endonyms
  // live ONLY in langName* keys, which are excluded.
  // ------------------------------------------------------------------------
  test('no false language-count / Spanish-veneer copy in any ARB', () {
    final RegExp veneer =
        RegExp(r'52 languages|Español|Spanish is strong', caseSensitive: false);
    final Directory l10n = Directory('lib/l10n');
    expect(l10n.existsSync(), isTrue, reason: 'run from the package root');

    final List<String> offenders = <String>[];
    for (final FileSystemEntity e in l10n.listSync()) {
      if (e is! File || !e.path.endsWith('.arb')) continue;
      final Map<String, dynamic> arb =
          jsonDecode(e.readAsStringSync()) as Map<String, dynamic>;
      arb.forEach((String k, dynamic v) {
        if (k.startsWith('@') || k.startsWith('langName')) return;
        if (v is String && veneer.hasMatch(v)) {
          offenders.add('${e.path.split(Platform.pathSeparator).last}:$k = "$v"');
        }
      });
    }

    expect(
      offenders,
      isEmpty,
      reason: 'ARB value(s) claim "52 languages" / contain Spanish-veneer copy. '
          'The app teaches English from 10 languages; endonyms belong only in '
          'langName* keys:\n${offenders.join('\n')}',
    );
  });
}
