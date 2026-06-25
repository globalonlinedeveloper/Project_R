import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/energy/energy_controller.dart';
import 'package:ratel/features/energy/energy_state.dart';
import 'package:ratel/features/profile/profile_screen.dart';
import 'package:ratel/features/saved_words/saved_words_controller.dart';
import 'package:ratel/features/streak/streak_controller.dart';

Widget _host(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: RatelTheme.light(), home: const ProfileScreen()),
    );

Finder _valueIn(String tileKey, String value) => find.descendant(
      of: find.byKey(Key(tileKey)),
      matching: find.text(value),
    );

void main() {
  testWidgets('stats grid surfaces live streak / lessons / saved-words values',
      (tester) async {
    await tester.pumpWidget(_host([
      streakControllerProvider.overrideWith(
          (ref) => StreakController(const StreakState(current: 3, longest: 7))),
      energyControllerProvider.overrideWith(
          (ref) => EnergyController(const EnergyState(lessonsCompleted: 12))),
      savedWordsControllerProvider.overrideWith((ref) {
        final c = SavedWordsController();
        c.save('es-en', 'hola');
        c.save('es-en', 'adios');
        return c;
      }),
    ]));
    await tester.pump();

    expect(find.byKey(const Key('profile-stats')), findsOneWidget);
    expect(_valueIn('stat-streak', '3'), findsOneWidget);
    expect(_valueIn('stat-best-streak', '7'), findsOneWidget);
    expect(_valueIn('stat-lessons', '12'), findsOneWidget);
    expect(_valueIn('stat-saved', '2'), findsOneWidget);
    expect(find.text('Day streak'), findsOneWidget);
    expect(find.text('Best streak'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('Saved words'), findsOneWidget);
  });

  testWidgets('zero-state renders zeros without crashing', (tester) async {
    await tester.pumpWidget(_host(const []));
    await tester.pump();
    expect(_valueIn('stat-streak', '0'), findsOneWidget);
    expect(_valueIn('stat-lessons', '0'), findsOneWidget);
    expect(_valueIn('stat-saved', '0'), findsOneWidget);
  });

  testWidgets('stats grid renders without overflow at 360px', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host(const []));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('profile-stats')), findsOneWidget);
  });
}
