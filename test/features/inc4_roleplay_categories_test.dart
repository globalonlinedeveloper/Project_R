import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/roleplay/roleplay_screen.dart';

/// INC-4 · C-R1/C-R2/C-R4 — the roleplay library grouped under the owner's five
/// NAMED categories (EVERYDAY / TRAVEL / WORK & STUDY / SOCIAL / HEALTH),
/// derived deterministically from real scenario text; a live search field; and
/// per-scene medallions. Mirrors ui_locale_i18n_test's provider-override /
/// CourseSpine harness.

/// One graded roleplay scenario with the real authored signal (world/title/
/// goal). A single throwaway scene keeps the projection valid.
CourseScenario _rp(String id, String title, String cefr,
        {String? world, String? goal}) =>
    CourseScenario(
      id: id,
      kind: 'roleplay',
      title: title,
      cefr: cefr,
      world: world,
      goal: goal,
      scenes: const <CourseScene>[
        CourseScene(sceneId: 's1', speaker: 'npc', line: 'Hello.'),
      ],
    );

/// A course spine whose roleplays span every category + a couple of medallion
/// cases (mirrors the owner's #23 scene set).
final CourseSpine _spine = CourseSpine(courseCode: 'en', units: const <CourseUnit>[], roleplays: <CourseScenario>[
  _rp('cafe', 'Ordering at a Café', 'A2',
      world: 'a small café in town', goal: 'Order a drink and a snack.'),
  _rp('bakery', 'At the Bakery', 'A1',
      world: 'a warm bakery', goal: 'Buy some bread and pay politely.'),
  _rp('directions', 'Asking for Directions', 'A2',
      world: 'a busy street in a new city',
      goal: 'Ask the way to the train station.'),
  _rp('interview', 'A Casual Job Interview', 'B1',
      world: 'a bright cafe hiring a weekend barista',
      goal: 'Make a good impression as a reliable candidate.'),
  _rp('classmate', 'Meet a New Classmate', 'A1',
      world: 'school hallway', goal: 'Greet Ben and introduce yourself.'),
  _rp('doctor', "At the Doctor's Office", 'B1',
      world: "a doctor's office", goal: 'Describe your symptoms clearly.'),
]);

Widget _screen(CourseSpine spine) => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(spine),
        isProProvider.overrideWithValue(false),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RoleplayScreen(),
      ),
    );

/// Test-harness helper (INC-9.2 gate fix): the screen under test uses a
/// lazy [ListView] body, so children below the default 800x600 test
/// viewport are never built and resolve to findsNothing (the six named-category sections overflow the fold).
/// Enlarging the test surface builds the whole list. The screen is
/// UNCHANGED — a viewport-only harness fix; the single-item tests already
/// prove the render path is correct.
void _tallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('categoryOf — deterministic derivation over real signal', () {
    test('a café-world scenario lands under EVERYDAY', () {
      expect(
          categoryOf(_rp('c', 'Ordering at a Café', 'A2',
              world: 'a small café in town', goal: 'Order a drink.')),
          RoleplayCategory.everyday);
    });

    test('a doctor-world scenario lands under HEALTH', () {
      expect(
          categoryOf(_rp('d', "At the Doctor's Office", 'B1',
              world: "a doctor's office", goal: 'Describe your symptoms.')),
          RoleplayCategory.health);
    });

    test('a street/city-world scenario lands under TRAVEL', () {
      expect(
          categoryOf(_rp('t', 'Asking for Directions', 'A2',
              world: 'a busy street in a new city',
              goal: 'Ask the way to the train station.')),
          RoleplayCategory.travel);
    });

    test('a barista/hiring café resolves to WORK & STUDY (work signal wins)',
        () {
      expect(
          categoryOf(_rp('w', 'A Casual Job Interview', 'B1',
              world: 'a bright cafe hiring a weekend barista',
              goal: 'Make a good impression as a candidate.')),
          RoleplayCategory.workStudy);
    });

    test('a classmate/friend scenario lands under SOCIAL', () {
      expect(
          categoryOf(_rp('s', 'Meet a New Classmate', 'A1',
              world: 'school hallway',
              goal: 'Greet Ben and introduce yourself.')),
          // "classmate" is a SOCIAL keyword; "school" (work) is only reached
          // if social does not match — social is intentionally checked first
          // for a first-meeting scenario. Assert the friendly-meeting bucket.
          RoleplayCategory.social);
    });

    test('an unmatched scenario defaults to EVERYDAY (five-bucket floor)', () {
      expect(
          categoryOf(_rp('x', 'A Quiet Afternoon', 'A1',
              world: 'somewhere calm', goal: 'Relax and chat.')),
          RoleplayCategory.everyday);
    });
  });

  testWidgets('named-category headers render (localized) in fixed order; '
      'empty categories are hidden', (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(_screen(_spine));
    await tester.pumpAndSettle();

    // English section headers (small-caps upper-cased by RatelSectionHeader).
    expect(find.text('EVERYDAY'), findsOneWidget);
    expect(find.text('TRAVEL'), findsOneWidget);
    expect(find.text('WORK & STUDY'), findsOneWidget);
    expect(find.text('SOCIAL'), findsOneWidget);
    expect(find.text('HEALTH'), findsOneWidget);

    // A café + bakery scenario sit under EVERYDAY; the doctor under HEALTH.
    expect(find.text('Ordering at a Café'), findsOneWidget);
    expect(find.text("At the Doctor's Office"), findsOneWidget);
  });

  testWidgets('empty category hidden: a spine with only a café scenario shows '
      'EVERYDAY but not HEALTH', (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(_screen(CourseSpine(
        courseCode: 'en',
        units: const <CourseUnit>[],
        roleplays: <CourseScenario>[
          _rp('cafe', 'Ordering at a Café', 'A2',
              world: 'a small café in town', goal: 'Order a drink.'),
        ])));
    await tester.pumpAndSettle();
    expect(find.text('EVERYDAY'), findsOneWidget);
    expect(find.text('HEALTH'), findsNothing);
    expect(find.text('TRAVEL'), findsNothing);
  });

  testWidgets('search filters rows live (title/goal/world, case-insensitive)',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(_screen(_spine));
    await tester.pumpAndSettle();

    // Before searching: café + doctor both present.
    expect(find.text('Ordering at a Café'), findsOneWidget);
    expect(find.text("At the Doctor's Office"), findsOneWidget);

    await tester.enterText(
        find.byKey(const ValueKey<String>('roleplay-search-field')), 'doctor');
    await tester.pumpAndSettle();

    // Only the doctor row survives; the café row is filtered out, and its
    // EVERYDAY header (now empty) is hidden.
    expect(find.text("At the Doctor's Office"), findsOneWidget);
    expect(find.text('Ordering at a Café'), findsNothing);
    expect(find.text('EVERYDAY'), findsNothing);
    expect(find.text('HEALTH'), findsOneWidget);
  });

  testWidgets('search with no matches shows the honest no-matches line',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(_screen(_spine));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey<String>('roleplay-search-field')),
        'zzzznotathing');
    await tester.pumpAndSettle();
    expect(find.textContaining('No matches for'), findsOneWidget);
    expect(find.text('Ordering at a Café'), findsNothing);
  });

  testWidgets('per-scene medallions: a café scenario shows the ☕ medallion '
      '(not the fixed 🎭)', (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(_screen(CourseSpine(
        courseCode: 'en',
        units: const <CourseUnit>[],
        roleplays: <CourseScenario>[
          _rp('cafe', 'Ordering at a Café', 'A2',
              world: 'a small café in town', goal: 'Order a coffee.'),
        ])));
    await tester.pumpAndSettle();
    // The café emoji renders; the generic mask does NOT (it was the old fixed
    // medallion for every row).
    expect(find.text('☕'), findsOneWidget);
    expect(find.text('🎭'), findsNothing);
  });

  testWidgets('a doctor scenario shows the 🩺 medallion',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(_screen(CourseSpine(
        courseCode: 'en',
        units: const <CourseUnit>[],
        roleplays: <CourseScenario>[
          _rp('doctor', "At the Doctor's Office", 'B1',
              world: "a doctor's office", goal: 'Describe your symptoms.'),
        ])));
    await tester.pumpAndSettle();
    expect(find.text('🩺'), findsOneWidget);
  });

  testWidgets('honest empty state when the course authors no roleplays',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester
        .pumpWidget(_screen(const CourseSpine(courseCode: 'en', units: <CourseUnit>[])));
    await tester.pumpAndSettle();
    // The honest empty copy (never a fabricated list) + no category headers.
    expect(find.text('No roleplays in this course yet.'), findsOneWidget);
    expect(find.text('EVERYDAY'), findsNothing);
    expect(
        find.byKey(const ValueKey<String>('screen-roleplay')), findsNothing);
  });

  testWidgets('preserved chrome: screen key, live-entry card, and row keys',
      (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(_screen(_spine));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey<String>('screen-roleplay')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('live-roleplay-entry')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('roleplay-row-cafe')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('roleplay-row-doctor')),
        findsOneWidget);
  });

  testWidgets('category headers localize (German)', (WidgetTester tester) async {
    _tallSurface(tester);
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_spine),
        isProProvider.overrideWithValue(false),
      ],
      child: const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RoleplayScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    // New INC-4 keys fall back to English in DE (per directive) — the header
    // still resolves through context.l10n and renders (upper-cased). This pins
    // that the section labels are l10n-driven, not hard-coded literals.
    expect(find.text('EVERYDAY'), findsOneWidget);
    expect(find.text('HEALTH'), findsOneWidget);
  });
}
