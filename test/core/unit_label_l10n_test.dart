// Increment-A regression: the course-unit SECTION/LEVEL fallback labels are now
// localized at the render edge (core/l10n render maps), keeping the content
// projection l10n-free (R-K6). These pin BYTE-IDENTITY with the old hardcoded
// literals so no visible English changes, and prove the fallback branches map.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';

void main() {
  testWidgets('ratelUnitSectionLabel / ratelUnitTitleLabel localize fallbacks',
      (WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (BuildContext c) {
        ctx = c;
        return const SizedBox.shrink();
      }),
    ));

    // Authored gloss (no fallback) passes through UNTOUCHED.
    expect(ratelUnitSectionLabel(ctx, 'SECTION 1 · FOUNDATIONS', null, null),
        'SECTION 1 · FOUNDATIONS');
    expect(ratelUnitTitleLabel(ctx, 'Basics', null), 'Basics');

    // Plain section fallback -> homeSectionN (byte-identical to 'SECTION n').
    expect(ratelUnitSectionLabel(ctx, 'SECTION 3', 3, null), 'SECTION 3');

    // CEFR-band fallback -> homeSectionLevel + homeLevelBand, byte-identical to
    // the retired 'SECTION n · LEVEL band' / 'Level band' literals.
    expect(ratelUnitSectionLabel(ctx, 'SECTION 4 · LEVEL A2', 4, 'A2'),
        'SECTION 4 · LEVEL A2');
    expect(ratelUnitTitleLabel(ctx, 'Level A2', 'A2'), 'Level A2');
  });
}
