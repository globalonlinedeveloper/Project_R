import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/course_switch.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/l10n.dart';
import 'package:ratel/features/courses/courses_screen.dart';
import 'package:ratel/features/learner/learner_controller.dart';
import 'package:ratel/services/preferences/ui_locale.dart';
import 'package:ratel/services/preferences/ui_locale_store.dart';

/// INC-13 — the DISPLAY "Menu language" row is now the REAL app-shell language
/// control, INLINE on Courses (no `/settings` deep-link).
///
/// The row's subtitle shows the current menu language; tapping opens an
/// in-place modal bottom sheet over [kUiLanguageEndonyms] whose rows call the
/// REAL [UiLocaleController.setLocale] — the SAME control Settings uses, wired
/// to `MaterialApp.locale`. Selecting a language flips the locale restart-free
/// and updates the row. Modelled on `ui_locale_i18n_test.dart` (provider →
/// MaterialApp.locale chain) + `courses_screen_test.dart` (the CoursesScreen
/// harness). The old behaviour — a navigation to `/settings` — is gone: tapping
/// opens the sheet ON this screen instead.
///
/// Picker languages are exactly [kUiLanguageEndonyms] (10 real ARB chrome
/// locales — NOT Spanish, which ships as a COURSE but not a UI language). Tests
/// pick de ("Deutsch") / ja ("日本語"), whose endonyms never collide with the
/// ADD-course names in the chosen `available` list, and scope the row-subtitle
/// assertion to the row's own subtree to stay unambiguous.

/// A minimal test controller returning a FIXED [LearnerSnapshot] so the screen
/// reads deterministic REAL data (mirrors courses_screen_test).
class _FixedLearner extends Notifier<LearnerSnapshot>
    implements LearnerController {
  _FixedLearner(this._snap);
  final LearnerSnapshot _snap;
  @override
  LearnerSnapshot build() => _snap;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LearnerSnapshot _snap({int xpTotal = 0}) =>
    LearnerSnapshot(theta: 0, level: CefrLevel.a1, xpTotal: xpTotal);

final Finder _menuRow =
    find.byKey(const ValueKey<String>('courses-menu-language'));
final Finder _menuSheet =
    find.byKey(const ValueKey<String>('courses-menu-language-sheet'));

/// The endonym shown in the DISPLAY row's OWN subtitle (scoped to the row so an
/// identically-named ADD-course row can never satisfy the match).
Finder _rowSubtitle(String endonym) =>
    find.descendant(of: _menuRow, matching: find.text(endonym));

/// Pumps CoursesScreen inside a `MaterialApp` whose `locale:` is bound to
/// [uiLocaleControllerProvider] — the SAME binding `RatelApp` uses — so a
/// `setLocale` from the inline picker is observable on `MaterialApp.locale`.
Future<UiLocaleStore> _pumpCourses(
  WidgetTester tester, {
  String current = 'es',
  List<String> available = const <String>['es', 'ta'],
  int xpTotal = 340,
  Size size = const Size(460, 2200),
  UiLocaleStore? store,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final UiLocaleStore localeStore = store ?? InMemoryUiLocaleStore();

  Widget app = Consumer(
    builder: (BuildContext context, WidgetRef ref, _) => MaterialApp(
      locale: ref.watch(uiLocaleControllerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CoursesScreen(),
    ),
  );
  // CoursesScreen reads the CourseSwitchScope from ABOVE the app.
  app = CourseSwitchScope(
    current: current,
    available: available,
    switchCourse: (_) async {},
    child: app,
  );
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      learnerControllerProvider
          .overrideWith(() => _FixedLearner(_snap(xpTotal: xpTotal))),
      uiLocaleStoreProvider.overrideWithValue(localeStore),
    ],
    child: app,
  ));
  await tester.pumpAndSettle();
  return localeStore;
}

Locale? _appLocale(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).locale;

/// Opens the sheet and taps [endonym], scrolling it into view first (the sheet
/// ListView is the last Scrollable — same handling as the Settings picker test).
Future<void> _openAndPick(WidgetTester tester, String endonym) async {
  await tester.tap(_menuRow);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text(endonym), 120,
      scrollable: find.byType(Scrollable).last);
  await tester.ensureVisible(find.text(endonym));
  await tester.pumpAndSettle();
  await tester.tap(find.text(endonym));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'row starts on "System default" (null override) and does NOT deep-link '
      'to /settings — tapping opens an in-place sheet', (WidgetTester tester) async {
    await _pumpCourses(tester);

    expect(_menuRow, findsOneWidget);
    // Subtitle = the system-default label (null locale), scoped to the row.
    expect(_rowSubtitle('System default'), findsOneWidget);
    // The old subtitle copy (the /settings deep-link hint) is gone.
    expect(find.text("Set the app's interface language in Settings"),
        findsNothing);

    // Tapping opens the in-place picker sheet — we stay ON CoursesScreen
    // (the screen is still mounted; no navigation happened).
    await tester.tap(_menuRow);
    await tester.pumpAndSettle();
    expect(_menuSheet, findsOneWidget);
    expect(find.byKey(const ValueKey<String>('screen-courses')), findsOneWidget);
  });

  testWidgets(
      'selecting Deutsch flips MaterialApp.locale to de (real UiLocaleController) '
      'and updates the row', (WidgetTester tester) async {
    final UiLocaleStore store = await _pumpCourses(tester);
    expect(_appLocale(tester), isNull); // follows the device at first

    await _openAndPick(tester, 'Deutsch');

    // The REAL control fired: store persisted + MaterialApp.locale flipped.
    expect(store.load(), 'de');
    expect(_appLocale(tester), const Locale('de'));
    // Sheet closed; the row's OWN subtitle now shows the endonym.
    expect(_menuSheet, findsNothing);
    expect(_rowSubtitle('Deutsch'), findsOneWidget);
  });

  testWidgets(
      'selecting 日本語 flips MaterialApp.locale to ja; re-opening and picking '
      'System default clears back to device', (WidgetTester tester) async {
    final UiLocaleStore store = await _pumpCourses(tester);

    await _openAndPick(tester, '日本語');
    expect(store.load(), 'ja');
    expect(_appLocale(tester), const Locale('ja'));
    expect(_rowSubtitle('日本語'), findsOneWidget);

    // Re-open and clear back to system default. The sheet has re-localized to
    // Japanese, so the system-default row now reads the ja label (the app is
    // genuinely following the new locale — assert against the real ARB value).
    final String jaSystem =
        lookupAppLocalizations(const Locale('ja')).settingsAppLanguageSystem;
    await tester.tap(_menuRow);
    await tester.pumpAndSettle();
    await tester.tap(find.text(jaSystem));
    await tester.pumpAndSettle();
    expect(store.load(), isNull);
    expect(_appLocale(tester), isNull);
    // Back on the device locale (English in this harness): the row's subtitle
    // shows the English system-default label again.
    expect(_rowSubtitle('System default'), findsOneWidget);
  });

  testWidgets('360-width gauntlet: the DISPLAY row + picker render without '
      'overflow', (WidgetTester tester) async {
    await _pumpCourses(tester,
        current: 'ta',
        available: const <String>['ta', 'es'],
        xpTotal: 1280,
        size: const Size(360, 5200));
    expect(tester.takeException(), isNull);

    // Open the picker at narrow width and confirm it lays out cleanly.
    await tester.tap(_menuRow);
    await tester.pumpAndSettle();
    expect(_menuSheet, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
