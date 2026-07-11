import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/prefs_ui_locale_store.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/services/preferences/ui_locale.dart';
import 'package:ratel/services/preferences/ui_locale_store.dart';

/// L-2 · R-C13 app-shell i18n — the ARB layer + device-local locale override.
///
/// Covers the full chain (store → controller → MaterialApp locale → ARB
/// strings), the English fallback that keeps every bare-`MaterialApp` legacy
/// harness valid, the settings picker mechanics, and an Arabic RTL smoke at
/// 360 width.
const CourseSpine _testSpine =
    CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
      section: 'SECTION 1 · LEVEL A1',
      title: 'Level A1',
      lessons: <CourseLesson>[
        CourseLesson(
            id: 'l_greet',
            title: 'Saludos',
            cefr: 'A1',
            exercises: <CourseExercise>[
              CourseExercise(
                  id: 'i1',
                  exerciseType: 'mcq',
                  prompt: 'Say hello',
                  accepted: <String>['hola']),
            ]),
      ]),
]);

Widget _app(UiLocaleStore store) => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_testSpine),
        // Reduce motion so pumpAndSettle settles (home_test precedent).
        settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(const AppSettings(reduceMotion: true))),
        uiLocaleStoreProvider.overrideWithValue(store),
      ],
      child: const RatelApp(),
    );

Widget _settingsWith(Locale locale, UiLocaleStore store) => ProviderScope(
      overrides: <Override>[
        uiLocaleStoreProvider.overrideWithValue(store),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsScreen(),
      ),
    );

void main() {
  test('UiLocaleStore roundtrip — in-memory and prefs', () async {
    final InMemoryUiLocaleStore mem = InMemoryUiLocaleStore();
    expect(mem.load(), isNull);
    await mem.save('es');
    expect(mem.load(), 'es');
    await mem.save(null);
    expect(mem.load(), isNull);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final PrefsUiLocaleStore store = PrefsUiLocaleStore(prefs);
    expect(store.load(), isNull);
    await store.save('ar');
    expect(store.load(), 'ar');
    expect(prefs.getString(PrefsUiLocaleStore.prefsKey), 'ar');
    await store.save(null);
    expect(store.load(), isNull);
  });

  test('controller: null (system) by default; setLocale persists + clears',
      () async {
    final InMemoryUiLocaleStore store = InMemoryUiLocaleStore();
    final ProviderContainer container = ProviderContainer(overrides: <Override>[
      uiLocaleStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    expect(container.read(uiLocaleControllerProvider), isNull);
    await container
        .read(uiLocaleControllerProvider.notifier)
        .setLocale(const Locale('es'));
    expect(container.read(uiLocaleControllerProvider), const Locale('es'));
    expect(store.current, 'es');
    await container.read(uiLocaleControllerProvider.notifier).setLocale(null);
    expect(container.read(uiLocaleControllerProvider), isNull);
    expect(store.current, isNull);
  });

  test('controller: a seeded store restores the override at boot', () {
    final ProviderContainer container = ProviderContainer(overrides: <Override>[
      uiLocaleStoreProvider.overrideWithValue(InMemoryUiLocaleStore('ru')),
    ]);
    addTearDown(container.dispose);
    expect(container.read(uiLocaleControllerProvider), const Locale('ru'));
  });

  testWidgets(
      'English fallback: bare MaterialApp (no delegates) renders English '
      'chrome — the legacy-harness guarantee', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: SettingsScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('LEARNING'), findsOneWidget);
    // Below the fold of the lazy settings ListView — scroll to build it.
    await tester.scrollUntilVisible(find.text('App language'), 200);
    expect(find.text('App language'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
  });

  test('defaultTabs stay byte-identical English (fallback contract)', () {
    expect(
        RatelBottomNav.defaultTabs.map((RatelNavTab t) => t.label).toList(),
        <String>['Home', 'Library', 'Leagues', 'Quests', 'Profile']);
  });

  testWidgets('full app in Spanish: nav chrome localized; live flip to '
      'Japanese rebuilds', (WidgetTester tester) async {
    await tester.pumpWidget(_app(InMemoryUiLocaleStore('es')));
    await tester.pumpAndSettle();
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Misiones'), findsOneWidget);

    final ProviderContainer container =
        ProviderScope.containerOf(tester.element(find.byType(RatelApp)));
    await container
        .read(uiLocaleControllerProvider.notifier)
        .setLocale(const Locale('ja'));
    await tester.pumpAndSettle();
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('クエスト'), findsOneWidget);
    expect(find.text('Inicio'), findsNothing);
  });

  testWidgets('settings in Spanish (delegates installed): chrome localized',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        _settingsWith(const Locale('es'), InMemoryUiLocaleStore('es')));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('APRENDIZAJE'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('Idioma de la aplicación'), 200);
    expect(find.text('Idioma de la aplicación'), findsOneWidget);
  });

  testWidgets('picker: choosing Español persists; System default clears',
      (WidgetTester tester) async {
    final InMemoryUiLocaleStore store = InMemoryUiLocaleStore();
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        uiLocaleStoreProvider.overrideWithValue(store),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();
    // The row lives below the fold of the lazy ListView — scroll first,
    // then fully align it (a partially-visible row is find-able but its
    // center misses hit-testing).
    await tester.scrollUntilVisible(find.text('App language'), 200);
    await tester.ensureVisible(find.text('App language'));
    await tester.pumpAndSettle();
    // Row subtitle starts on the system-default label.
    expect(find.text('System default'), findsOneWidget);
    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    expect(find.text('Español'), findsOneWidget);
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(store.current, 'es');
    // Sheet closed; the row subtitle now shows the endonym.
    expect(find.text('Español'), findsOneWidget);
    // Re-open and clear back to system default.
    await tester.ensureVisible(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System default'));
    await tester.pumpAndSettle();
    expect(store.current, isNull);
  });

  testWidgets('Arabic: app renders RTL with localized nav — 360 gauntlet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(InMemoryUiLocaleStore('ar')));
    await tester.pumpAndSettle();
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(
        Directionality.of(tester.element(find.byType(Scaffold).first)),
        TextDirection.rtl);
  });
}
