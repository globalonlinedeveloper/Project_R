import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/features/progress/progress_screen.dart';

/// Pump the Progress screen alone on a TALL surface so the whole lazy ListView
/// is laid out (no below-the-fold finder misses — S37 lazy-list gotcha).
/// Evidence for [R-G2] [R-G6] [R-G9] [R-I1] [R-I2] [R-I7] [R-L14].
Future<void> _pumpTall(WidgetTester tester, ProviderContainer c) async {
  tester.view.physicalSize = const Size(440, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: ProgressScreen()),
  ));
  await tester.pump();
}

void main() {
  testWidgets(
      'Profile "View progress" opens the REAL dashboard (route promoted, not a stub)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // The banner is below the fold in the lazy ListView — scroll it in first.
    final Finder banner = find.text('View progress →');
    await tester.scrollUntilVisible(banner, 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(banner);
    await tester.pumpAndSettle();

    // It is the REAL screen (its key), NOT the honest "coming soon" stub.
    expect(
        find.byKey(const ValueKey<String>('screen-progress')), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    // The hero surfaces the REAL cold-start level (A1 · Beginner, not "A2").
    expect(find.text('Level A1 · Beginner'), findsOneWidget);
  });

  testWidgets(
      'zero-state is the REAL cold-start snapshot with honest empty states',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    await _pumpTall(tester, c);

    // Real cold-start CEFR level (A1 · Beginner), not the mockup's "A2".
    expect(find.text('Level A1 · Beginner'), findsOneWidget);
    expect(find.text('Saved words'), findsOneWidget);
    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('CEFR level'), findsOneWidget);
    expect(find.textContaining('Ability θ'), findsOneWidget);
    // Honest empty states for the no-engine stats — NEVER the mockup numbers.
    // D1: the 7-day chart frame shows but reads honestly empty (no XP yet).
    expect(find.textContaining('No XP recorded yet'), findsOneWidget);
    expect(find.textContaining('inactive days stay'), findsOneWidget);
    // D2: accuracy / study time / retention are present but honestly empty.
    expect(find.text('Accuracy'), findsOneWidget);
    expect(find.text('Study time'), findsOneWidget);
    expect(find.text('Retention'), findsOneWidget);
    // The chart + all three D2 metrics each read "No data yet" on a fresh acct.
    expect(find.text('No data yet'), findsNWidgets(4));
    expect(find.textContaining('86%'), findsNothing);
    expect(find.textContaining('retained'), findsNothing);
    expect(find.text('412'), findsNothing);
  });

  testWidgets('reflects REAL engine state after activity (lessons / words / XP)',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    // Drive REAL controllers (the only path that moves these values).
    c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
    c.read(savedWordsControllerProvider.notifier).save('hola');
    c.read(savedWordsControllerProvider.notifier).save('gato');
    await _pumpTall(tester, c);

    expect(find.text('20'), findsOneWidget); // Total XP card = real xpTotal
    expect(find.text('2'), findsOneWidget); // Saved words = real dedup count
    expect(find.text("Today's XP"), findsOneWidget);
    // D1: the real 7-day chart reflects the recorded lesson XP.
    expect(find.text('20 XP · last 7 days'), findsOneWidget);
  });
}
