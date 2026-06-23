import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/energy/energy_controller.dart';
import 'package:ratel/features/energy/energy_state.dart';
import 'package:ratel/features/streak/streak_controller.dart';
import 'package:ratel/features/home/home_screen.dart';

Widget _home({StreakState? streak, EnergyState? energy}) {
  return ProviderScope(
    overrides: [
      streakControllerProvider
          .overrideWith((ref) => StreakController(streak ?? const StreakState())),
      energyControllerProvider
          .overrideWith((ref) => EnergyController(energy ?? const EnergyState())),
    ],
    child: MaterialApp(theme: RatelTheme.light(), home: const HomeScreen()),
  );
}

void main() {
  testWidgets('streak banner shows the current streak + best (R-L8)', (tester) async {
    await tester.pumpWidget(_home(streak: const StreakState(current: 3, longest: 5)));
    await tester.pump();
    expect(find.text('3 day streak'), findsOneWidget);
    expect(find.text('Best: 5 days'), findsOneWidget);
  });

  testWidgets('zero streak invites the user to start', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();
    expect(find.text('Start your streak'), findsOneWidget);
  });

  testWidgets('home offers an always-free review entry (R-L8)', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();
    expect(find.text('Practice your mistakes'), findsOneWidget);
    expect(find.text('Review mistakes'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget); // daily lesson still here
  });
}
