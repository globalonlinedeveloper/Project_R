import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/models/models.dart';

void main() {
  const loader = ContentLoader();
  ContentBatch load(String area) =>
      loader.loadString(File('assets/content/$area/seed.batch.json').readAsStringSync());

  test('all pilot seeds load via the fail-closed loader', () {
    for (final area in ['en', 'es', 'ta', 'ja', '_pilot']) {
      expect(load(area).rowCount, greaterThan(0), reason: area);
    }
  });

  test('JA seed: CJK sentence with fugashi-aligned tokens', () {
    final ja = load('ja');
    expect(ja.sentences.single.tokens.map((t) => t.surface).toList(),
        ['水', 'を', '飲み', 'まし', 'た']);
    expect(ja.locales.single.scriptMeta.script, 'Jpan');
  });

  test('TA seed: non-Latin grapheme clusters preserved', () {
    expect(load('ta').sentences.single.graphemes, ['நா', 'ய்']);
  });

  test('ES seed: pair-specific item (source_locale + contrast_type)', () {
    final it = load('es').items.single;
    expect(it.sourceLocale, 'en');
    expect(it.contrastType, ContrastType.translateFromL1);
  });
}
