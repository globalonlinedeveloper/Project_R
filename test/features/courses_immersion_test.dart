import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/course_switch.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/components/ratel_toggle.dart';
import 'package:ratel/core/l10n.dart';
import 'package:ratel/features/courses/courses_screen.dart';
import 'package:ratel/features/learner/learner_controller.dart';
import 'package:ratel/services/preferences/immersion_mode_store.dart';
import 'package:ratel/services/preferences/ui_locale.dart';
import 'package:ratel/services/preferences/ui_locale_store.dart';

/// INC-14 — the DISPLAY "Immersion mode" row (second row, below Menu language)
/// is a REAL toggle (honest partial).
///
/// SUPPORTED: the current course target is one of the 10 translated chrome
/// locales ([kUiLanguageEndonyms]) — e.g. `de`. The toggle is ENABLED; turning
/// it ON drives the SAME restart-free control INC-13 uses
/// ([UiLocaleController.setLocale]) so `MaterialApp.locale` flips to the target,
/// and persists `immersion=true` in the store. OFF returns the locale to null
/// (follow device) and persists `immersion=false`.
///
/// UNSUPPORTED (the honesty crux): the target is a shipped COURSE with NO
/// translated interface — es (Spanish) / ta (Tamil). The toggle is DISABLED
/// (non-interactive) and an honest reason is shown; tapping it does NOT change
/// `MaterialApp.locale`. Immersion is NEVER faked for an untranslated target.
///
/// Modelled on `courses_display_menu_language_test.dart`: the CoursesScreen
/// harness + a `Consumer` binding `MaterialApp.locale` to
/// [uiLocaleControllerProvider], with the immersion + ui-locale stores overridden
/// by in-memory impls.

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

final Finder _immersionRow =
    find.byKey(const ValueKey<String>('courses-immersion'));

/// The RatelToggle inside the immersion row (scoped to the row).
Finder get _immersionToggle =>
    find.descendant(of: _immersionRow, matching: find.byType(RatelToggle));

Locale? _appLocale(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).locale;

/// Pumps CoursesScreen inside a `MaterialApp` whose `locale:` is bound to
/// [uiLocaleControllerProvider] (the SAME binding `RatelApp` uses), with both
/// the immersion and ui-locale stores overridden by in-memory impls so the
/// toggle's real effects (locale flip + persistence) are observable.
Future<(InMemoryImmersionModeStore, InMemoryUiLocaleStore)> _pumpCourses(
  WidgetTester tester, {
  required String current,
  required List<String> available,
  int xpTotal = 340,
  Size size = const Size(460, 2200),
  bool immersionSeed = false,
  String? localeSeed,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final InMemoryImmersionModeStore immersionStore =
      InMemoryImmersionModeStore(immersionSeed);
  final InMemoryUiLocaleStore localeStore = InMemoryUiLocaleStore(localeSeed);

  Widget app = Consumer(
    builder: (BuildContext context, WidgetRef ref, _) => MaterialApp(
      locale: ref.watch(uiLocaleControllerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CoursesScreen(),
    ),
  );
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
      immersionModeStoreProvider.overrideWithValue(immersionStore),
      uiLocaleStoreProvider.overrideWithValue(localeStore),
    ],
    child: app,
  ));
  await tester.pumpAndSettle();
  return (immersionStore, localeStore);
}

void main() {
  testWidgets(
      'SUPPORTED (de): the immersion toggle is ENABLED; ON flips '
      'MaterialApp.locale to de + persists immersion=true; OFF clears both',
      (WidgetTester tester) async {
    final (InMemoryImmersionModeStore immersion, InMemoryUiLocaleStore locale) =
        await _pumpCourses(tester,
            current: 'de', available: const <String>['de', 'es']);

    // The row exists and starts OFF, following the device (null locale).
    expect(_immersionRow, findsOneWidget);
    expect(_appLocale(tester), isNull);
    expect(immersion.current, isFalse);
    // Enabled ⇒ the toggle's onChanged is non-null.
    RatelToggle toggle = tester.widget<RatelToggle>(_immersionToggle);
    expect(toggle.value, isFalse);
    expect(toggle.onChanged, isNotNull,
        reason: 'de is a translated chrome locale — immersion is enabled');

    // Turn it ON: the REAL UiLocaleController fires (MaterialApp.locale → de)
    // and the immersion flag persists true.
    await tester.tap(_immersionToggle);
    await tester.pumpAndSettle();
    expect(_appLocale(tester), const Locale('de'));
    expect(immersion.current, isTrue);
    expect(locale.load(), 'de');
    // The toggle now reads ON.
    toggle = tester.widget<RatelToggle>(_immersionToggle);
    expect(toggle.value, isTrue);

    // Turn it OFF: locale returns to null (follow device), flag persists false.
    await tester.tap(_immersionToggle);
    await tester.pumpAndSettle();
    expect(_appLocale(tester), isNull);
    expect(immersion.current, isFalse);
    expect(locale.load(), isNull);
  });

  testWidgets(
      'UNSUPPORTED (es): the toggle is DISABLED with the honest reason; tapping '
      'does NOT change MaterialApp.locale', (WidgetTester tester) async {
    final (InMemoryImmersionModeStore immersion, InMemoryUiLocaleStore locale) =
        await _pumpCourses(tester,
            current: 'es', available: const <String>['es', 'ta']);

    expect(_immersionRow, findsOneWidget);
    // Disabled ⇒ onChanged is null (non-interactive, visually muted).
    final RatelToggle toggle = tester.widget<RatelToggle>(_immersionToggle);
    expect(toggle.onChanged, isNull,
        reason: 'Spanish has no translated chrome — immersion is disabled');
    expect(toggle.value, isFalse);

    // The honest reason (with the real language name) is present in the row.
    expect(
      find.descendant(
        of: _immersionRow,
        matching: find.textContaining("Immersion isn't available for Spanish"),
      ),
      findsOneWidget,
    );

    // Tapping the disabled toggle changes nothing: locale stays null, no persist.
    await tester.tap(_immersionToggle, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(_appLocale(tester), isNull);
    expect(immersion.current, isFalse);
    expect(locale.load(), isNull);
  });

  testWidgets(
      'UNSUPPORTED (ta): Tamil is likewise disabled with its own honest reason',
      (WidgetTester tester) async {
    await _pumpCourses(tester,
        current: 'ta', available: const <String>['ta', 'es']);

    final RatelToggle toggle = tester.widget<RatelToggle>(_immersionToggle);
    expect(toggle.onChanged, isNull);
    expect(
      find.descendant(
        of: _immersionRow,
        matching: find.textContaining("Immersion isn't available for Tamil"),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      '360-width gauntlet: the immersion row renders without overflow in both '
      'the enabled (de) and disabled (es) states', (WidgetTester tester) async {
    // Enabled state, narrow.
    await _pumpCourses(tester,
        current: 'de',
        available: const <String>['de', 'es'],
        xpTotal: 1280,
        size: const Size(360, 5200));
    expect(tester.takeException(), isNull);
    expect(_immersionRow, findsOneWidget);

    // Disabled state, narrow (the longer honest-reason subtitle must wrap
    // cleanly).
    await _pumpCourses(tester,
        current: 'es',
        available: const <String>['es', 'ta'],
        xpTotal: 1280,
        size: const Size(360, 5200));
    expect(tester.takeException(), isNull);
    expect(_immersionRow, findsOneWidget);
  });
}
