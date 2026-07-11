import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/features/adventures/adventures_screen.dart';
import 'package:ratel/features/adventures/adventure_player_screen.dart';
import 'package:ratel/features/common/content_unavailable_card.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/features/roleplay/roleplay_player_screen.dart';

// M-3 (screen review 2026-07 §2): Adventures scene-preview sheet — long-press
// on a row opens the REAL authored opening scene (speaker + line + branching
// choice labels) in the same sheet grammar as the Home lesson preview, with a
// Start CTA that pushes the player. Fold-in: adventure + roleplay players now
// degrade to the shared honest ContentUnavailableCard (Q-2) instead of the old
// plain not-available text.

CourseSpine _spine() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      adventures: <CourseScenario>[
        CourseScenario(
          id: 'adv1',
          kind: 'adventure',
          title: 'The market',
          cefr: 'A1',
          goal: 'Buy fruit',
          scenes: <CourseScene>[
            CourseScene(
              sceneId: 'a1',
              speaker: 'narrator',
              line: 'You reach a fork.',
              choices: <CourseChoice>[
                CourseChoice(label: 'Go left', nextSceneId: 'a2'),
                CourseChoice(label: 'Go right', nextSceneId: 'a3'),
              ],
            ),
            CourseScene(
                sceneId: 'a2', speaker: 'narrator', line: 'You find a cafe.'),
            CourseScene(
                sceneId: 'a3', speaker: 'narrator', line: 'You find a park.'),
          ],
        ),
      ],
      roleplays: <CourseScenario>[],
    );

Future<void> _pumpList(WidgetTester tester) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final GoRouter router = GoRouter(routes: <RouteBase>[
    GoRoute(
        path: '/',
        builder: (BuildContext c, GoRouterState s) =>
            const AdventuresScreen()),
    GoRoute(
        path: '/adventure',
        builder: (BuildContext c, GoRouterState s) =>
            const Scaffold(body: Text('PLAYER-ROUTE'))),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(const AppSettings(reduceMotion: true))),
      courseSpineProvider.overrideWithValue(_spine()),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

Finder get _sheet =>
    find.byKey(const ValueKey<String>('adventure-preview-sheet'));

void main() {
  testWidgets('long-press opens the real scene-script preview sheet',
      (WidgetTester tester) async {
    await _pumpList(tester);
    expect(_sheet, findsNothing);

    await tester.longPress(
        find.byKey(const ValueKey<String>('adventure-row-adv1')));
    await tester.pumpAndSettle();

    expect(_sheet, findsOneWidget);
    expect(find.text('🗺️ ADVENTURE · A1'), findsOneWidget);
    expect(find.text('3 scenes · 1 choice point · Buy fruit'), findsOneWidget);
    expect(find.text('OPENING SCENE'), findsOneWidget);
    // The REAL authored script — speaker, line, and both branch labels.
    expect(find.text('narrator: You reach a fork.'), findsOneWidget);
    expect(find.text('› Go left'), findsOneWidget);
    expect(find.text('› Go right'), findsOneWidget);
  });

  testWidgets('Start adventure closes the sheet and pushes the player',
      (WidgetTester tester) async {
    await _pumpList(tester);
    await tester.longPress(
        find.byKey(const ValueKey<String>('adventure-row-adv1')));
    await tester.pumpAndSettle();

    await tester.tap(
        find.byKey(const ValueKey<String>('adventure-preview-start')));
    await tester.pumpAndSettle();

    expect(_sheet, findsNothing);
    expect(find.text('PLAYER-ROUTE'), findsOneWidget);
  });

  testWidgets(
      'fold-in: adventure player degrades to the shared unavailable card',
      (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(const AppSettings(reduceMotion: true))),
        courseSpineProvider.overrideWithValue(_spine()),
      ],
      child: const MaterialApp(
          home: AdventurePlayerScreen(scenarioId: 'nope')),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(ContentUnavailableCard), findsOneWidget);
    expect(find.text('Content unavailable'), findsOneWidget);
    expect(find.text('This adventure is not available.'), findsNothing);
  });

  testWidgets(
      'fold-in: roleplay player degrades to the shared unavailable card',
      (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(const AppSettings(reduceMotion: true))),
        courseSpineProvider.overrideWithValue(_spine()),
      ],
      child: const MaterialApp(
          home: RoleplayPlayerScreen(scenarioId: 'nope')),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(ContentUnavailableCard), findsOneWidget);
    expect(find.text('Content unavailable'), findsOneWidget);
    expect(find.text('This roleplay is not available.'), findsNothing);
  });
}
