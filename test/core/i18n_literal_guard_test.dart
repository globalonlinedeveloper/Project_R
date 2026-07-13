import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Replace every comment in [src] with spaces — newlines preserved, so byte
/// offsets and line numbers are unchanged — while leaving string literals
/// intact. String-aware: a `//` or `/*` INSIDE a string (e.g. a URL like
/// 'https://…') is copied through as string content, never mistaken for a
/// comment. This lets Guard 1 match ACROSS lines without commented-out code or
/// a `//` inside a literal tripping it.
String _stripComments(String src) {
  final StringBuffer out = StringBuffer();
  final int n = src.length;
  int i = 0;
  while (i < n) {
    final String c = src[i];
    // String literal (optionally r-prefixed): copy through verbatim.
    if (c == "'" || c == '"') {
      final String q = c;
      final bool triple = i + 2 < n && src[i + 1] == q && src[i + 2] == q;
      out.write(c);
      i++;
      if (triple) {
        out.write(src[i]);
        out.write(src[i + 1]);
        i += 2;
        while (i < n &&
            !(src[i] == q &&
                i + 2 < n &&
                src[i + 1] == q &&
                src[i + 2] == q)) {
          out.write(src[i]);
          i++;
        }
        for (int k = 0; k < 3 && i < n; k++) {
          out.write(src[i]);
          i++;
        }
      } else {
        while (i < n && src[i] != q) {
          if (src[i] == '\\' && i + 1 < n) {
            out.write(src[i]);
            out.write(src[i + 1]);
            i += 2;
          } else {
            out.write(src[i]);
            i++;
          }
        }
        if (i < n) {
          out.write(src[i]);
          i++;
        }
      }
      continue;
    }
    // Line comment -> spaces to end of line.
    if (c == '/' && i + 1 < n && src[i + 1] == '/') {
      while (i < n && src[i] != '\n') {
        out.write(' ');
        i++;
      }
      continue;
    }
    // Block comment -> spaces (newlines kept so line numbers survive).
    if (c == '/' && i + 1 < n && src[i + 1] == '*') {
      out.write('  ');
      i += 2;
      while (i < n && !(src[i] == '*' && i + 1 < n && src[i + 1] == '/')) {
        out.write(src[i] == '\n' ? '\n' : ' ');
        i++;
      }
      if (i + 1 < n) {
        out.write('  ');
        i += 2;
      }
      continue;
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

/// i18n regression guards (audit RATEL_I18N_HARDCODED_AUDIT.md §15). Added AFTER
/// the user-facing surfaces + all 10 ARB locales were brought to parity (S144-
/// S147, increments I1-I4), so the surfaces are clean and this test HOLDS the
/// line: a NEW hard-coded user-facing English literal — or a resurfaced
/// "52 languages" / Spanish-veneer claim — fails the build.
///
/// S148 hardening: Guard 1 now scans the WHOLE (comment-stripped) file rather
/// than line-by-line, so a `Text(` / `label:` / `semanticLabel:` whose literal
/// sits on the NEXT line — previously invisible — is caught too.
void main() {
  // ------------------------------------------------------------------------
  // Guard 1 — no hard-coded user-facing string literals in the two surface
  // trees. Route copy through context.l10n.<key> (add the key to app_en.arb).
  // ------------------------------------------------------------------------
  test('no hard-coded user-facing literals in features / core components', () {
    const List<String> scope = <String>['lib/features', 'lib/core/components'];

    // Constructors / named params that put a raw string in front of the user.
    // The gap before the opening quote is \s* (which matches NEWLINES) so a
    // multi-line `Text(\n  'lit'\n)` or a `semanticLabel:\n  'lit'` split over
    // lines is caught (S148 hardening); the literal BODY stays single-line
    // ((.*?) with no dotAll) because Dart '..'/".." strings cannot span lines.
    final RegExp textCtor = RegExp(r'''\bText\s*\(\s*(['"])(.*?)\1''');
    final RegExp namedText = RegExp(
        r'''\b(?:hintText|helperText|semanticLabel|tooltip|label)\s*:\s*(['"])(.*?)\1''');
    final RegExp hasWord = RegExp(r'[A-Za-z]{2,}'); // >=2 ASCII letters = copy
    final RegExp cefr = RegExp(r'^[ABC][12]'); // A1..C2

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
        // Whole file, comments stripped -> newline-tolerant matching.
        final String src = _stripComments(e.readAsStringSync());
        for (final RegExp p in <RegExp>[textCtor, namedText]) {
          for (final RegExpMatch m in p.allMatches(src)) {
            final String lit = m.group(2)!;
            if (allowed(lit)) continue;
            final int line =
                '\n'.allMatches(src.substring(0, m.start)).length + 1;
            offenders.add('$norm:$line: "$lit"');
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
    final RegExp veneer = RegExp(
        '52 languages|Espa\u{00f1}ol|Spanish is strong',
        caseSensitive: false);
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
          offenders
              .add('${e.path.split(Platform.pathSeparator).last}:$k = "$v"');
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
