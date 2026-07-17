import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/core.dart';

/// INC-10 FU-2 — shared "chrome scrim" contrast polish.
///
/// Backdrop worlds make chrome surfaces translucent so the animated field tints
/// through: on Ocean the plain card `surface` is alpha ~0.70, the progress-bar
/// track `surface2` ~0.08, the ring track `border` ~0.13. Muted card text and
/// "empty" progress tracks then lose contrast over the moving field. FU-2 lays
/// the shared [RatelPalette.scrim] token beneath those surfaces via one shared
/// [RatelScrim] primitive (bar + plain card) and the ring painter — a single
/// shared definition, never a per-widget raw color, and a NO-OP on opaque
/// (Daylight) surfaces.
///
/// NEGATIVE CONTROL (by construction): every "Ocean -> active/translucent"
/// assertion is paired with a "Daylight -> inactive/opaque" one. If the scrim
/// gate were dropped (active always false) the Ocean assertions fail; if it were
/// unconditional the Daylight assertions fail. Widget-tree / palette only.
ThemeWorld _w(String id) => kThemeWorlds[id]!;

Widget _themed(String id, Widget child) => MaterialApp(
      theme: RatelTheme.world(_w(id)),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('RatelScrim(active:true) lays a scrim floor beneath its child',
      (WidgetTester tester) async {
    await tester.pumpWidget(_themed(
        'ocean',
        const RatelScrim(
            active: true, radius: 12, child: SizedBox(width: 40, height: 40))));
    expect(find.byType(RatelScrim), findsOneWidget);
    // active -> a Stack + a DecoratedBox scrim floor are inserted under child.
    expect(
        find.descendant(
            of: find.byType(RatelScrim), matching: find.byType(Stack)),
        findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(RatelScrim), matching: find.byType(DecoratedBox)),
        findsWidgets);
  });

  testWidgets('RatelScrim(active:false) is a no-op (renders child verbatim)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_themed(
        'light',
        const RatelScrim(
            active: false,
            child: SizedBox(key: ValueKey<String>('c'), width: 40, height: 40))));
    expect(find.byKey(const ValueKey<String>('c')), findsOneWidget);
    // No scrim Stack inserted by RatelScrim when inactive.
    expect(
        find.descendant(
            of: find.byType(RatelScrim), matching: find.byType(Stack)),
        findsNothing);
  });

  testWidgets('Ocean: plain RatelCard backs muted content with an ACTIVE scrim',
      (WidgetTester tester) async {
    await tester.pumpWidget(_themed('ocean', const RatelCard(child: Text('q'))));
    expect(tester.widget<RatelScrim>(find.byType(RatelScrim)).active, isTrue);
  });

  testWidgets('Daylight: plain RatelCard scrim is INACTIVE (opaque -> no-op)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_themed('light', const RatelCard(child: Text('q'))));
    expect(tester.widget<RatelScrim>(find.byType(RatelScrim)).active, isFalse);
  });

  testWidgets('Ocean: RatelProgressBar empty track gets an ACTIVE scrim floor',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(_themed('ocean', const RatelProgressBar(value: 0.4)));
    expect(tester.widget<RatelScrim>(find.byType(RatelScrim)).active, isTrue);
  });

  testWidgets('Daylight: RatelProgressBar scrim is INACTIVE',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(_themed('light', const RatelProgressBar(value: 0.4)));
    expect(tester.widget<RatelScrim>(find.byType(RatelScrim)).active, isFalse);
  });

  testWidgets('Ocean: RatelProgressRing renders; its track token is translucent '
      '(scrim path on)', (WidgetTester tester) async {
    await tester
        .pumpWidget(_themed('ocean', const RatelProgressRing(value: 0.5)));
    expect(find.byType(RatelProgressRing), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    final BuildContext c = tester.element(find.byType(RatelProgressRing));
    expect(c.palette.border.a < 1.0, isTrue); // gate that drives scrimActive
  });

  testWidgets('Daylight: RatelProgressRing track token is opaque (scrim off)',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(_themed('light', const RatelProgressRing(value: 0.5)));
    final BuildContext c = tester.element(find.byType(RatelProgressRing));
    expect(c.palette.border.a >= 1.0, isTrue);
  });
}
