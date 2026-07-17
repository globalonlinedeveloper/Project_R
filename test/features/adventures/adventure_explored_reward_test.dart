import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/adventures/adventure_player_screen.dart';
import 'package:ratel/features/adventures/adventure_progress_controller.dart';
import 'package:ratel/features/learner/learner_controller.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/l10n/generated/app_localizations.dart';

// L-4 (design 4.12): reaching an authored ENDING marks the adventure
// EXPLORED (device-local) and the FIRST exploration awards +15 XP / +5
// diamonds with the ADVENTURE COMPLETE dialog (owner-approved S131).
// Re-plays and pre-explored visits never re-award — honest once-per-adventure.

CourseSpine _spine() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      adventures: <CourseScenario>[
        CourseScenario(
          id: 'adv1',
          kind: 'adventure',
          title: 'The market',
          cefr: 'A1',
          scenes: <CourseScene>[
            CourseScene(
              sceneId: 'a1',
              speaker: 'narrator',
              line: 'You reach a fork.',
              choices: <CourseChoice>[
                CourseChoice(label: 'Go left', nextSceneId: 'a2'),
              ],
            ),
            CourseScene(
                sceneId: 'a2', speaker: 'narrator', line: 'You find a cafe.'),
          ],
        ),
      ],
    );

ProviderContainer _c({Set<String>? explored}) =>
    ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine()),
      if (explored != null)
        adventureProgressStoreProvider.overrideWithValue(
            InMemoryAdventureProgressStore(explored)),
    ]);

Future<void> _pump(WidgetTester tester, ProviderContainer c,
    {Locale? locale}) async {
  tester.view.physicalSize = const Size(460, 2600);
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
      home: const AdventurePlayerScreen(scenarioId: 'adv1'),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _walkToEnding(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey<String>('adventure-choice-0')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'first ending: explored persisted + 15 XP + 5 diamonds + the design '
      'dialog, en byte-identical', (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(c.read(learnerControllerProvider).diamonds, 0);
    await _walkToEnding(tester);

    // The ADVENTURE COMPLETE dialog (design copy, en byte-pins).
    expect(find.byKey(const ValueKey<String>('adventure-complete-dialog')),
        findsOneWidget);
    expect(find.text('ADVENTURE COMPLETE'), findsOneWidget);
    expect(find.text('The market ✓'), findsOneWidget);
    expect(
        find.text('Nicely done! +15 XP · +5 💎 earned — explore the next '
            'scene whenever you like.'),
        findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Real engine state moved: +15 XP, +5 adventure diamonds, explored
    // persisted. The +15 XP also crosses the streak_keeper daily quest (any XP)
    // once → +3 quest 💎 (INC-QR1), so the wallet reads 8. The dialog copy
    // above still surfaces the ADVENTURE's own +5 💎 reward.
    expect(c.read(learnerControllerProvider).xpToday, 15);
    expect(c.read(learnerControllerProvider).diamonds, 8); // 5 adventure + 3 quest
    expect(c.read(adventureProgressControllerProvider), <String>{'adv1'});

    // Continue dismisses; the honest ending card is beneath.
    await tester
        .tap(find.byKey(const ValueKey<String>('adventure-complete-continue')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('adventure-complete-dialog')),
        findsNothing);
    expect(find.byKey(const ValueKey<String>('adventure-ending')),
        findsOneWidget);
  });

  testWidgets('replay via Start over never re-awards or re-celebrates',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    await _walkToEnding(tester);
    await tester
        .tap(find.byKey(const ValueKey<String>('adventure-complete-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();
    await _walkToEnding(tester);
    expect(find.byKey(const ValueKey<String>('adventure-complete-dialog')),
        findsNothing);
    expect(c.read(learnerControllerProvider).xpToday, 15); // still one award
    // Replay re-earns no XP, so no adventure reward AND no re-completed quest:
    // the wallet stays at 8 (5 adventure + 3 streak_keeper quest, INC-QR1).
    expect(c.read(learnerControllerProvider).diamonds, 8);
  });

  testWidgets('pre-explored adventure (earlier visit): no dialog, no award',
      (WidgetTester tester) async {
    final ProviderContainer c = _c(explored: <String>{'adv1'});
    addTearDown(c.dispose);
    await _pump(tester, c);
    await _walkToEnding(tester);
    expect(find.byKey(const ValueKey<String>('adventure-complete-dialog')),
        findsNothing);
    expect(c.read(learnerControllerProvider).xpToday, 0);
    expect(c.read(learnerControllerProvider).diamonds, 0);
    expect(find.byKey(const ValueKey<String>('adventure-ending')),
        findsOneWidget);
  });

  testWidgets('bare harness ending card stays byte-identical English',
      (WidgetTester tester) async {
    final ProviderContainer c = _c(explored: <String>{'adv1'});
    addTearDown(c.dispose);
    await _pump(tester, c);
    await _walkToEnding(tester);
    expect(find.text('🏁 The End'), findsOneWidget);
    expect(find.text('Start over'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('de dialog renders the translated celebration',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c, locale: const Locale('de'));
    await _walkToEnding(tester);
    expect(find.text('ABENTEUER ABGESCHLOSSEN'), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
  });
}
