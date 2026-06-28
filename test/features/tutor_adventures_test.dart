import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/features/adventures/adventures_screen.dart';
import 'package:ratel/features/tutor/ai_tutor_screen.dart';

/// Tall surface so the whole lazy ListView lays out (S37 fold gotcha).
Future<void> _pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(440, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(child: MaterialApp(home: child)));
  await tester.pump();
}

void main() {
  testWidgets('Library → AI Tutor opens the REAL screen (route promoted)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI Tutor'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('screen-tutor')), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    // Free default ⇒ real PRO gate badges; relay unconfigured ⇒ honest status.
    expect(find.text('PRO'), findsWidgets);
    expect(find.textContaining('not connected'), findsOneWidget);
  });

  testWidgets('AI Tutor mode tap is HONEST (PRO gate, never a faked reply)',
      (WidgetTester tester) async {
    await _pumpTall(tester, const AiTutorScreen());
    await tester.tap(find.text('Talk to Ratel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('RATEL PRO unlocks live AI tutoring.'), findsOneWidget);
  });

  testWidgets('Library → Adventures opens the REAL screen (FREE, route promoted)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adventures'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('screen-adventures')), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    expect(find.text('FREE'), findsWidgets);
    expect(find.text('Order a coffee'), findsOneWidget); // authored scene label
    expect(find.textContaining('not connected'), findsOneWidget);
  });

  testWidgets('Adventures scene tap is HONEST (no fabricated conversation)',
      (WidgetTester tester) async {
    await _pumpTall(tester, const AdventuresScreen());
    await tester.tap(find.text('Order a coffee'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('This scene opens once the AI relay is connected.'),
        findsOneWidget);
  });
}
