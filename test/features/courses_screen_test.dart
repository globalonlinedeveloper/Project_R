import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/course_switch.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/components/ratel_top_bar.dart' show courseFlagEmoji;
import 'package:ratel/core/l10n.dart';
import 'package:ratel/features/courses/courses_screen.dart';
import 'package:ratel/features/learner/learner_controller.dart';

/// INC-12 — Courses catalog polish (UI-only, no per-course backend yet).
///
/// Covers: the 12-shipped-code flag + endonym catalog maps; the Duolingo
/// LEARNING(current+XP) / ADD(rest) split; browse/search over the REAL
/// `available` list; and a 360-width overflow gauntlet. All XP shown is the
/// current course's REAL [LearnerSnapshot.xpTotal] — non-current rows show no
/// XP (there is a single global learner state today, so per-course XP for the
/// others would be fabricated).

/// The 12 shipped course codes (bn,de,en,es,fr,hi,ja,ko,pt,ru,ta,zh).
const List<String> _shipped = <String>[
  'bn', 'de', 'en', 'es', 'fr', 'hi', 'ja', 'ko', 'pt', 'ru', 'ta', 'zh',
];

const String _badger = '\u{1F9A1}';

/// A minimal test controller returning a FIXED [LearnerSnapshot] so the screen
/// reads deterministic REAL data (mirrors inc8_unbuilt_screens_test).
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

Future<void> _pumpCourses(
  WidgetTester tester, {
  String current = 'es',
  List<String> available = const <String>['es', 'fr', 'de'],
  int xpTotal = 340,
  Size size = const Size(460, 2200),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  Widget app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const CoursesScreen(),
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
      learnerControllerProvider.overrideWith(() => _FixedLearner(_snap(xpTotal: xpTotal))),
    ],
    child: app,
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('catalog maps cover all 12 shipped codes', () {
    test('courseFlagEmoji + ratelCourseFlagEmoji return a non-badger flag', () {
      for (final String code in _shipped) {
        expect(courseFlagEmoji(code), isNot(_badger),
            reason: 'courseFlagEmoji($code) must be a real flag, not the badger');
        expect(ratelCourseFlagEmoji(code), isNot(_badger),
            reason: 'ratelCourseFlagEmoji($code) must be a real flag');
        // The two maps mirror each other.
        expect(courseFlagEmoji(code), ratelCourseFlagEmoji(code),
            reason: 'the top-bar + l10n flag maps must agree for $code');
      }
      // Unknown codes still fall back to the badger.
      expect(courseFlagEmoji('xx'), _badger);
      expect(ratelCourseFlagEmoji('xx'), _badger);
    });

    testWidgets('ratelCourseLanguageName returns a real name (not the '
        'upper-cased code) for all 12', (WidgetTester tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (BuildContext c) {
          ctx = c;
          return const SizedBox();
        }),
      ));
      for (final String code in _shipped) {
        final String name = ratelCourseLanguageName(ctx, code);
        expect(name, isNotEmpty);
        expect(name, isNot(code.toUpperCase()),
            reason: '$code must resolve to a real language name, not "${code.toUpperCase()}"');
      }
      // Unknown codes still degrade to the upper-cased code.
      expect(ratelCourseLanguageName(ctx, 'xx'), 'XX');
    });
  });

  group('LEARNING / ADD layout (Duolingo split)', () {
    testWidgets('LEARNING shows the current course + its REAL XP + Active; '
        'ADD shows the non-current courses', (WidgetTester tester) async {
      await _pumpCourses(tester,
          current: 'es',
          available: const <String>['es', 'fr', 'de'],
          xpTotal: 340);

      expect(find.byKey(const ValueKey<String>('screen-courses')),
          findsOneWidget);
      // Current course name + its real XP on the LEARNING card.
      expect(find.text('Spanish'), findsOneWidget);
      expect(find.text('⚡ 340 XP'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      // The other available courses appear in ADD with a Switch affordance.
      expect(find.text('French'), findsOneWidget);
      expect(find.text('German'), findsOneWidget);
      expect(find.text('Switch'), findsNWidgets(2));
      // No fabricated per-course level/XP for the others (honesty).
      expect(find.textContaining('1,240 XP'), findsNothing);
      expect(find.textContaining('Level A2'), findsNothing);
    });

    testWidgets('the honest shared-progress banner + no-fake-catalog note stay',
        (WidgetTester tester) async {
      await _pumpCourses(tester);
      expect(find.textContaining('streak & XP are shared across courses'),
          findsOneWidget);
      expect(find.textContaining('only lists courses it actually ships'),
          findsOneWidget);
    });
  });

  group('browse / search filters the ADD list', () {
    testWidgets('typing a name filters ADD to matching courses only',
        (WidgetTester tester) async {
      await _pumpCourses(tester,
          current: 'es',
          available: const <String>['es', 'fr', 'de', 'ja']);
      // Before searching: all non-current courses are present.
      expect(find.text('French'), findsOneWidget);
      expect(find.text('German'), findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);

      await tester.enterText(
          find.byKey(const ValueKey<String>('courses-search')), 'ger');
      await tester.pumpAndSettle();

      // Only German matches; the others drop out.
      expect(find.text('German'), findsOneWidget);
      expect(find.text('French'), findsNothing);
      expect(find.text('Japanese'), findsNothing);
      // The current course is never in the ADD list regardless of query.
      expect(find.text('Spanish'), findsOneWidget); // still on the LEARNING card
    });

    testWidgets('searching by CODE also matches; empty query shows all',
        (WidgetTester tester) async {
      await _pumpCourses(tester,
          current: 'es', available: const <String>['es', 'fr', 'de']);
      await tester.enterText(
          find.byKey(const ValueKey<String>('courses-search')), 'fr');
      await tester.pumpAndSettle();
      expect(find.text('French'), findsOneWidget);
      expect(find.text('German'), findsNothing);

      // Clearing the query restores the full ADD list.
      await tester.enterText(
          find.byKey(const ValueKey<String>('courses-search')), '');
      await tester.pumpAndSettle();
      expect(find.text('French'), findsOneWidget);
      expect(find.text('German'), findsOneWidget);
    });
  });

  testWidgets('360-width gauntlet: renders the full catalog without overflow',
      (WidgetTester tester) async {
    await _pumpCourses(tester,
        current: 'ta',
        available: _shipped,
        xpTotal: 1280,
        size: const Size(360, 5200));
    expect(find.byKey(const ValueKey<String>('screen-courses')),
        findsOneWidget);
    // Current = Tamil on the LEARNING card with its real XP.
    expect(find.text('⚡ 1280 XP'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    // No RenderFlex overflow was thrown during layout/paint.
    expect(tester.takeException(), isNull);
  });
}
