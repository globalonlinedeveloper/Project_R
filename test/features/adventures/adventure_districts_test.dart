import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/adventures/adventure_progress_controller.dart';
import 'package:ratel/features/adventures/adventures_screen.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/l10n/generated/app_localizations.dart';

// L-4 (design 4.12, B-10): the Adventures screen renders CEFR-band DISTRICT
// cards — gradient header with `n/m explored`, current-district mascot,
// ✓ Done pill, per-scene ✓/▶ explored states — over the device-local
// explored set. en chrome byte-pinned; ar RTL + narrow gauntlet.

CourseScenario _adv(String id, String band, String title) => CourseScenario(
      id: id,
      kind: 'adventure',
      title: title,
      cefr: band,
      scenes: const <CourseScene>[
        CourseScene(sceneId: 's1', speaker: 'narrator', line: 'Line.'),
      ],
    );

CourseSpine _spine() => CourseSpine(
      courseCode: 'en',
      units: const <CourseUnit>[],
      adventures: <CourseScenario>[
        _adv('a1x', 'A1', 'Order a coffee'),
        _adv('a1y', 'A1', 'Pay the bill'),
        _adv('b1x', 'B1', 'At the airport'),
      ],
    );

ProviderContainer _c({Set<String>? explored}) =>
    ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine()),
      // Motion-clean harness (repo convention): the current-district mascot
      // bobs under real settings; suites that pumpAndSettle set the floor.
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(const AppSettings(reduceMotion: true))),
      adventureProgressStoreProvider.overrideWithValue(
          InMemoryAdventureProgressStore(explored ?? <String>{})),
    ]);

Future<void> _pump(WidgetTester tester, ProviderContainer c,
    {Size size = const Size(430, 2600), Locale? locale}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: locale == null
          ? null
          : const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
      supportedLocales: locale == null
          ? const <Locale>[Locale('en')]
          : AppLocalizations.supportedLocales,
      home: const AdventuresScreen(),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('district cards render per band with en byte-pinned chrome',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.byKey(const ValueKey<String>('adventure-district-A1')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('adventure-district-B1')),
        findsOneWidget);
    expect(find.text('A1 · Beginner'), findsOneWidget);
    expect(find.text('B1 · Intermediate'), findsOneWidget);
    expect(find.text('0/2 explored'), findsOneWidget); // en byte-pin
    expect(find.text('0/1 explored'), findsOneWidget);
    // Fresh set: A1 is the current district (design mascot walk), B1 is not.
    expect(find.byKey(const ValueKey<String>('adventure-district-current-A1')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('adventure-district-current-B1')),
        findsNothing);
    expect(find.text('✓ Done'), findsNothing);
    // Every scene row present with the open ▶ status.
    expect(find.byKey(const ValueKey<String>('adventure-row-a1x')),
        findsOneWidget);
    expect(
        find.byKey(
            const ValueKey<String>('adventure-row-status-a1x-open')),
        findsOneWidget);
  });

  testWidgets(
      'explored rows flip to ✓, progress counts, Done pill + current walk',
      (WidgetTester tester) async {
    final ProviderContainer c = _c(explored: <String>{'a1x', 'a1y'});
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.text('2/2 explored'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('adventure-district-done-A1')),
        findsOneWidget);
    expect(find.text('✓ Done'), findsOneWidget); // en byte-pin
    // A1 complete: the mascot moves to B1 (first not-all-done).
    expect(find.byKey(const ValueKey<String>('adventure-district-current-A1')),
        findsNothing);
    expect(find.byKey(const ValueKey<String>('adventure-district-current-B1')),
        findsOneWidget);
    expect(
        find.byKey(
            const ValueKey<String>('adventure-row-status-a1x-done')),
        findsOneWidget);
    expect(
        find.byKey(
            const ValueKey<String>('adventure-row-status-b1x-open')),
        findsOneWidget);
  });

  testWidgets('marking explored live updates the district card',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.text('0/2 explored'), findsOneWidget);
    c.read(adventureProgressControllerProvider.notifier).markExplored('a1x');
    await tester.pumpAndSettle();
    expect(find.text('1/2 explored'), findsOneWidget);
    expect(
        find.byKey(
            const ValueKey<String>('adventure-row-status-a1x-done')),
        findsOneWidget);
  });

  testWidgets('M-3 long-press preview still opens from a district tile',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    await tester.longPress(
        find.byKey(const ValueKey<String>('adventure-row-a1x')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('adventure-preview-sheet')),
        findsOneWidget);
    expect(find.text('🗺️ ADVENTURE · A1'), findsOneWidget);
  });

  testWidgets('de renders translated district chrome',
      (WidgetTester tester) async {
    final ProviderContainer c = _c(explored: <String>{'a1x', 'a1y'});
    addTearDown(c.dispose);
    await _pump(tester, c, locale: const Locale('de'));
    expect(find.text('2/2 erkundet'), findsOneWidget);
    expect(find.text('✓ Fertig'), findsOneWidget);
    expect(find.text('A1 · Anfänger'), findsOneWidget);
  });

  testWidgets('narrow gauntlet @360 and @320: district cards never overflow',
      (WidgetTester tester) async {
    for (final double w in <double>[360, 320]) {
      final ProviderContainer c = _c(explored: <String>{'a1x'});
      await _pump(tester, c, size: Size(w, 2600));
      c.dispose();
    }
  });

  testWidgets('design hero card + header sub render en byte-identical',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.byKey(const ValueKey<String>('adventures-hero')),
        findsOneWidget);
    expect(find.text('Pick a place and dive in'), findsOneWidget);
    expect(
        find.text('Every scene is a real conversation — no wrong answers, '
            "and it's always free."),
        findsOneWidget);
    expect(find.text('Explore a world · talk your way through'),
        findsOneWidget);
    // The superseded invented intro copy is retired.
    expect(find.textContaining('Choose your path'), findsNothing);
    // LTR play glyph on unexplored rows.
    expect(find.text('▶'), findsNWidgets(3));
    expect(find.text('◀'), findsNothing);
  });

  testWidgets('reduce-motion floor: mascots render static (no bob wiring)',
      (WidgetTester tester) async {
    final ProviderContainer c = _c(); // harness sets reduceMotion: true
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(
        find.descendant(
            of: find.byKey(
                const ValueKey<String>('adventure-district-current-A1')),
            matching: find.byType(AnimatedBuilder)),
        findsNothing);
    expect(
        find.descendant(
            of: find.byKey(const ValueKey<String>('adventures-hero')),
            matching: find.byType(AnimatedBuilder)),
        findsNothing);
    // The glyphs themselves are still there.
    expect(
        find.descendant(
            of: find.byKey(const ValueKey<String>('adventures-hero')),
            matching: find.text('🦡')),
        findsOneWidget);
  });

  testWidgets('motion enabled: the current-district mascot genuinely bobs',
      (WidgetTester tester) async {
    // NO settings override: reduceMotion defaults false -> the bob runs, so
    // this test only ever pump()s fixed slices (NEVER pumpAndSettle, 11).
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine()),
      adventureProgressStoreProvider
          .overrideWithValue(InMemoryAdventureProgressStore(<String>{})),
    ]);
    addTearDown(c.dispose);
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AdventuresScreen()),
    ));
    await tester.pump();
    final Finder bob = find.descendant(
        of: find
            .byKey(const ValueKey<String>('adventure-district-current-A1')),
        matching: find.byType(AnimatedBuilder));
    expect(bob, findsOneWidget);
    // Mid-arc (600ms of the 2400ms period) the translate is visibly nonzero.
    await tester.pump(const Duration(milliseconds: 600));
    final Transform t = tester.widget<Transform>(find.descendant(
        of: find
            .byKey(const ValueKey<String>('adventure-district-current-A1')),
        matching: find.byType(Transform)));
    expect(t.transform.getTranslation().y, lessThan(-1.0));
  });
}
