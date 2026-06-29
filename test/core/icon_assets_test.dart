import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';

/// Asset-contract for the self-hosted Material icon font. These guard the
/// "independent / no-CDN" charter: the glyphs RATEL draws must come from a
/// vendored, pubspec-declared font — not an implicit external source.
void main() {
  test('the Material icon font is vendored in-repo and non-trivial', () {
    final File f = File('assets/fonts/MaterialIcons-Regular.ttf');
    expect(f.existsSync(), isTrue,
        reason: 'bundled icon font must live in assets/fonts/');
    expect(f.lengthSync(), greaterThan(50000));
  });

  test('pubspec declares the RatelMaterialIcons family for that font', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: RatelMaterialIcons'));
    expect(pubspec, contains('assets/fonts/MaterialIcons-Regular.ttf'));
  });

  test('RatelIcons resolve to the vendored family + official codepoints', () {
    expect(RatelIcons.arrowBack.fontFamily, 'RatelMaterialIcons');
    expect(RatelIcons.close.fontFamily, 'RatelMaterialIcons');
    expect(RatelIcons.markEmailUnread.fontFamily, 'RatelMaterialIcons');
    expect(RatelIcons.arrowBack.codePoint, 0xe5c4);
    expect(RatelIcons.close.codePoint, 0xe5cd);
    expect(RatelIcons.markEmailUnread.codePoint, 0xf18a);
    // arrow_back mirrors in RTL, matching Flutter's Icons.arrow_back.
    expect(RatelIcons.arrowBack.matchTextDirection, isTrue);
  });

  testWidgets('a RatelIcons glyph renders as an Icon', (WidgetTester tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(RatelIcons.arrowBack),
    ));
    expect(find.byIcon(RatelIcons.arrowBack), findsOneWidget);
  });
}
