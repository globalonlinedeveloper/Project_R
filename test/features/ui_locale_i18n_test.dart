import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/features/library/library_screen.dart';
import 'package:ratel/features/onboarding/onboarding_screen.dart';
import 'package:ratel/features/profile/profile_screen.dart';
import 'package:ratel/features/quests/quests_screen.dart';
import 'package:ratel/features/practice/practice_hub_screen.dart';
import 'package:ratel/features/progress/progress_screen.dart';
import 'package:ratel/features/tutor/ai_tutor_screen.dart';
import 'package:ratel/features/auth/welcome_screen.dart';
import 'package:ratel/services/achievements/achievements.dart';
import 'package:ratel/services/leagues/leagues.dart';
import 'package:ratel/services/notifications/notifications.dart';
import 'package:ratel/services/quests/quests.dart';
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

  test('ICU plurals + placeholders resolve per locale (I2)', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    expect(en.homeQuickExercises(1), '1 quick exercise');
    expect(en.homeQuickExercises(3), '3 quick exercises');
    expect(en.homeLessonMeta(2, 5, '3 quick exercises'),
        'Lesson 2 of 5 · 3 quick exercises.');
    expect(en.commonLevel('A1'), 'Level A1');
    final AppLocalizations ru = lookupAppLocalizations(const Locale('ru'));
    expect(ru.homeQuickExercises(1), contains('быстрое'));
    expect(ru.homeQuickExercises(3), contains('быстрых'));
    final AppLocalizations ar = lookupAppLocalizations(const Locale('ar'));
    expect(ar.homeQuickExercises(2), isNotEmpty);
  });

  test('lesson chrome keys: en output BYTE-IDENTICAL to the old literals '
      '(sentinels + summary), es localized (I3)', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    expect(en.lessonNicelyDone, '✓ Nicely done!');
    expect(en.lessonNotQuite, '✕ Not quite');
    expect(en.lessonCompleteKicker, 'LESSON COMPLETE');
    expect(en.lessonCompleteTitle, 'Lesson complete!');
    expect(en.lessonCompleteSummary(3, 4, 'A1'), '3 of 4 correct \u00b7 now A1');
    expect(en.lessonAnswerReveal('hola'), 'Answer: hola');
    expect(en.lessonTypeWhatYouHear, 'Type what you hear');
    expect(en.lessonTapWhatYouHear, 'Tap what you hear');
    expect(en.lessonTranslateSentence, 'Translate this sentence');
    final AppLocalizations es = lookupAppLocalizations(const Locale('es'));
    expect(es.lessonNicelyDone, '✓ ¡Bien hecho!');
    expect(es.lessonCheck, 'Comprobar');
    expect(es.lessonCompleteSummary(3, 4, 'A1'), contains('3 de 4'));
  });

  testWidgets('Library in Spanish (delegates installed): chrome localized',
      (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_testSpine),
      ],
      child: const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LibraryScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Tutor de IA'), findsOneWidget);
    expect(find.text('Centro de práctica'), findsOneWidget);
  });

  testWidgets('Library English fallback: bare MaterialApp renders English',
      (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_testSpine),
      ],
      child: const MaterialApp(home: LibraryScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('AI Tutor'), findsOneWidget);
    expect(find.text('Practice hub'), findsOneWidget);
  });

  test('I5 en byte-identity pins (apostrophes + composed rows)', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    expect(en.onboardingWelcomeTitle, "Hi, I'm Ratel!");
    expect(en.onboardingBrandNew, "I'm brand new");
    expect(en.profileTodaysGoal(15, 20), "Today's goal · 15/20 XP");
    expect(en.settingsGoalRow('Casual', 20), 'Casual · 20 XP/day');
    expect(en.onboardingXpPerDay(30), '30 XP / day');
    expect(en.onboardingPlacementBody('Spanish'),
        'New to Spanish, or do you know some already?');
  });

  test('I6 en byte-identity pins (quests/leagues/notifications)', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    expect(en.questsResetsIn(10, 53), 'Resets in 10h 53m');
    expect(en.questsDailyQuests(1, 2), 'Daily quests · 1/2');
    expect(en.questsXpToday(15, 20), '15/20 XP today');
    expect(en.leaguesTopClimb(7, 3), 'Top 7 climb each week · ends in 3 days');
    expect(en.leaguesTopClimb(7, 1), 'Top 7 climb each week · ends in 1 day');
    expect(en.leaguesPromoteRelegate(7, 5),
        'Top 7 promote · bottom 5 relegate when the week ends.');
    expect(en.leaguesYouAreHere, "You're here");
    expect(en.leaguesViewAllTiers, '🏆 View all 10 tiers ›');
    final AppLocalizations es = lookupAppLocalizations(const Locale('es'));
    expect(es.leaguesTopClimb(7, 1), contains('1 día'));
    expect(es.questsGoalReached, contains('🎉'));
  });

  test('I7 en byte-identity pins (shop/paywall)', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    expect(en.shopOwned(1, 2), 'Owned 1/2');
    expect(en.shopBuyFor(200), 'Buy for 200 💎');
    expect(en.shopFreezeAtCap(2), 'You already hold the most freezes (2).');
    expect(en.shopStreakDays(7), '🔥 7-day streak');
    expect(en.shopActiveLeft(14), 'Active · 14m left');
    expect(en.paywallGoPro('US\u00244.99'), 'Go Pro — US\u00244.99/mo');
    expect(en.paywallTrialDay7Desc('US\u002429.99'),
        'US\u002429.99/yr begins unless you cancel.');
    expect(en.paywallFinePrint('IN/BD'),
        'Cancel anytime in Settings. Prices shown for IN/BD; '
        'your local price is set by your app store.');
    final AppLocalizations es = lookupAppLocalizations(const Locale('es'));
    expect(es.shopBuyFor(200), contains('200 💎'));
    expect(es.paywallStartTrial, contains('7'));
  });

  testWidgets('Onboarding in Spanish: welcome step localized',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('¡Hola, soy Ratel!'), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);
    expect(find.text('Ya tengo una cuenta'), findsOneWidget);
  });

  testWidgets('Profile in Spanish: chrome localized (guest state)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Logros'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Amigos'), 200);
    expect(find.text('Amigos'), findsOneWidget);
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

  // ── S130 · engine-string render maps (quests / notifications /
  //    achievements / league tiers / CEFR level names) ──────────────────────

  testWidgets(
      'engine render maps: bare harness renders the full catalogues '
      'byte-identical English, and unknown ids/labels pass through',
      (WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (BuildContext c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    for (final Quest q in QuestsEngine.catalogue) {
      expect(ratelQuestTitle(ctx, q.id, q.title), q.title);
      expect(ratelQuestDescription(ctx, q.id, q.description), q.description);
    }
    for (final NotificationDef d in NotificationsEngine.catalogue) {
      expect(ratelNotificationTitle(ctx, d.id, d.title), d.title);
      expect(ratelNotificationBody(ctx, d.id, d.body), d.body);
    }
    for (final Achievement a in AchievementsEngine.catalogue) {
      expect(ratelAchievementTitle(ctx, a.id, a.title), a.title);
    }
    for (final LeagueTier t in LeagueTier.values) {
      expect(ratelLeagueTierName(ctx, t.label), t.label);
    }
    for (final String n in <String>[
      'Beginner',
      'Elementary',
      'Intermediate',
      'Upper intermediate',
      'Advanced',
      'Proficient',
    ]) {
      expect(ratelCefrLevelDisplayName(ctx, n), n);
    }
    // Unknown ids/labels degrade honestly to the engine's own text.
    expect(ratelQuestTitle(ctx, 'mystery_quest', 'Mystery'), 'Mystery');
    expect(ratelQuestDescription(ctx, 'mystery_quest', 'Do it'), 'Do it');
    expect(ratelNotificationTitle(ctx, 'gems:1', 'First gem'), 'First gem');
    expect(ratelNotificationBody(ctx, 'gems:1', 'Shiny.'), 'Shiny.');
    expect(ratelAchievementTitle(ctx, 'polyglot', 'Polyglot'), 'Polyglot');
    expect(ratelLeagueTierName(ctx, 'Titanium'), 'Titanium');
    expect(ratelCefrLevelDisplayName(ctx, 'Native'), 'Native');
  });

  test('leagues/profile leftover chrome keys: en byte-pins', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    expect(en.leaguesTierLeague('Bronze'), 'Bronze League');
    expect(
        en.leaguesYoureIn('Bronze'), "You're in Bronze · top 7 climb each week");
    expect(en.leaguesZonePromotion, '⬆ PROMOTION ZONE');
    expect(en.leaguesZoneDemotion, '⬇ DEMOTION ZONE');
    expect(en.profileAchievementsSummary(2, 6), '2 of 6 unlocked · real progress');
    expect(
        en.profileRealStateNote,
        'Level, XP, lessons, streak and saved words are real engine '
        'state — they start at zero on a fresh account.');
  });

  test('engine-map keys: es spot-checks', () {
    final AppLocalizations es = lookupAppLocalizations(const Locale('es'));
    expect(es.questTitlePowerSession, 'Sesión intensa');
    expect(es.notifTitleStreak7, '¡Racha de 7 días!');
    expect(es.achTitleFirstSteps, 'Primeros pasos');
    expect(es.leagueTierGold, 'Oro');
    expect(es.cefrNameBeginner, 'Principiante');
    expect(es.leaguesTierLeague('Oro'), 'Liga de Oro');
  });

  testWidgets('Quests in Spanish: engine-generated quest cards localized',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: QuestsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Sesión intensa'), 200);
    expect(find.text('Sesión intensa'), findsOneWidget);
    expect(find.text('Power session'), findsNothing);
  });

  // ── S130 · practice + progress chrome ─────────────────────────────────────

  test('practice/progress keys: en byte-pins (plurals + composed tails)', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    expect(en.practiceReviewWords(1), 'Review 1 word');
    expect(en.practiceReviewWords(2), 'Review 2 words');
    expect(en.practiceSavedWordsCount(2), '2 saved words');
    expect(en.practiceCaughtUp(''), 'All caught up — nothing due right now.');
    expect(en.practiceCaughtUp(en.practiceNextTail(en.practiceRelTomorrow)),
        'All caught up — nothing due right now · next tomorrow.');
    expect(en.practiceWordOf(1, 2), 'Word 1 of 2');
    expect(en.practiceReviewedSummary(2),
        'You reviewed 2 words. They are rescheduled by FSRS.');
    expect(en.practiceRelInDays(3), 'in 3 days');
    expect(en.practiceRelInHours(5), 'in 5h');
    expect(en.progressWeekTotal(20), '20 XP · last 7 days');
    expect(en.progressRetentionDetail(1),
        'predicted 1-day recall · 1 item this session');
    expect(en.progressRetentionDetail(3),
        'predicted 1-day recall · 3 items this session');
    expect(en.progressAbilityLine('0.00'), 'Ability θ 0.00 · real estimate');
    expect(
        en.progressShareText('A1', 'Beginner', 3, 120, 4),
        '🦡 RATEL · Level A1 (Beginner)\n'
        '🔥 3-day streak · ⚡ 120 XP · 📘 4 lessons\n'
        'Learning at learnwithratel.com');
    expect(en.commonDowMon, 'Mo');
  });

  test('practice/progress keys: es spot-checks', () {
    final AppLocalizations es = lookupAppLocalizations(const Locale('es'));
    expect(es.practiceTitle, 'Práctica');
    expect(es.practiceReviewWords(2), 'Repasar 2 palabras');
    expect(es.practiceGradeEasy, 'Fácil');
    expect(es.progressTitle, 'Progreso');
    expect(es.progressStatSavedWords, 'Palabras guardadas');
    expect(es.commonDowMon, 'Lu');
  });

  testWidgets('Practice hub in Spanish: empty state localized',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PracticeHubScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Práctica'), findsOneWidget);
    expect(find.text('Aún no hay palabras guardadas'), findsOneWidget);
    expect(find.text('No saved words yet'), findsNothing);
  });

  testWidgets('Progress in Spanish: hero + stats localized (zero state)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProgressScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Progreso'), findsOneWidget);
    expect(find.text('Nivel A1 · Principiante'), findsOneWidget);
    expect(find.text('Palabras guardadas'), findsOneWidget);
  });

  // ── S130 · search / themes / tutor / adventures chrome ────────────────────

  test('search/themes/tutor/adventures keys: en byte-pins', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    // The adventure sheet meta line composes byte-identically (test-pinned
    // downstream as '3 scenes · 1 choice point · Buy fruit').
    expect('${en.adventureScenesCount(3)} · ${en.adventureChoicePoints(1)}',
        '3 scenes · 1 choice point');
    expect(en.adventureChoicePoints(2), '2 choice points');
    expect(en.adventureSheetKicker('A1'), '🗺️ ADVENTURE · A1');
    expect(en.searchNoMatches('café'), 'No matches for “café”');
    expect(en.searchLessonSubtitle('Basics'), 'Basics · Lesson');
    expect(en.tutorScenesCount(3), '3 scenes');
    expect(en.themesVehicle('Fox'), 'Vehicle · Fox');
    expect(en.tutorAnnounceNeedsPro, 'RATEL PRO unlocks live AI tutoring.');
  });

  test('search/themes/tutor/adventures keys: es spot-checks', () {
    final AppLocalizations es = lookupAppLocalizations(const Locale('es'));
    expect(es.searchTitle, 'Buscar');
    expect(es.searchDestPracticeHub, 'Centro de práctica');
    expect(es.themesTitle, 'Temas');
    expect(es.tutorTalkTitle, 'Habla con Ratel');
    expect(es.adventureStart, 'Empezar aventura');
    expect(es.adventureChoicePoints(1), '1 punto de decisión');
  });

  testWidgets('AI Tutor in Spanish: header, cards and status localized',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AiTutorScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Practica una conversación real'), findsOneWidget);
    expect(find.text('Habla con Ratel'), findsOneWidget);
    expect(find.text('Practice a real conversation'), findsNothing);
  });

  // ── S130 · auth chrome ─────────────────────────────────────────────────────

  test('auth keys: en byte-pins (incl. the curly-apostrophe banner)', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    expect(en.authWelcomeTitle, 'Welcome to Ratel');
    expect(en.authWelcomeSubtitle,
        'Lessons, stories, podcasts and more —\npick how you want to start.');
    expect(en.authResetSent('a@b.co'),
        'We sent a password-reset link to a@b.co. Open it to '
        'choose a new password.');
    expect(en.authConfirmSent('a@b.co'),
        'We sent a confirmation link to a@b.co. Tap it to activate '
        'your account, then come back to log in.');
    expect(
        en.authUnavailableNote,
        'Accounts aren’t available in this build yet — you can keep learning as '
        'a guest. Sign-in turns on when the backend is configured.');
    expect(en.authNewToRatel, 'New to Ratel? ');
    expect(en.liveMute, 'Mute');
    expect(en.liveUnmute, 'Unmute');
  });

  test('auth keys: es spot-checks', () {
    final AppLocalizations es = lookupAppLocalizations(const Locale('es'));
    expect(es.authWelcomeTitle, 'Bienvenido a Ratel');
    expect(es.authCreateFreeAccount, 'Crear cuenta gratis');
    expect(es.authLogIn, 'Iniciar sesión');
    expect(es.authForgotPassword, '¿Olvidaste tu contraseña?');
    expect(es.authOr, 'o');
  });

  testWidgets('Welcome screen in Spanish: chrome localized',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WelcomeScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido a Ratel'), findsOneWidget);
    expect(find.text('Crear cuenta gratis'), findsOneWidget);
    expect(find.text('Continuar como invitado'), findsOneWidget);
    expect(find.text('Welcome to Ratel'), findsNothing);
  });

  test('micro-unit keys: en byte-pins + es spot-check', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
    expect(en.commonDurSeconds(45), '45s');
    expect(en.commonDurMinutes(5), '5m');
    expect(en.commonDurHours(2), '2h');
    expect(en.commonDurHoursMinutes(2, 5), '2h 5m');
    expect(en.practiceGradeInterval('Easy', 4), 'Easy · 4d');
    final AppLocalizations es = lookupAppLocalizations(const Locale('es'));
    expect(es.practiceGradeInterval('Fácil', 4), 'Fácil · 4 d');
  });
}
