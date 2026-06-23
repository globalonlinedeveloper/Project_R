import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/energy/energy_controller.dart';
import 'package:ratel/features/energy/energy_state.dart';
import 'package:ratel/features/home/home_screen.dart';

Widget _home(EnergyState initial) {
  return ProviderScope(
    overrides: [
      energyControllerProvider.overrideWith((ref) => EnergyController(initial)),
    ],
    child: MaterialApp(theme: RatelTheme.light(), home: const HomeScreen()),
  );
}

void main() {
  testWidgets('empty tank: Start lesson opens the out-of-energy sheet; ad refills',
      (tester) async {
    await tester.pumpWidget(_home(const EnergyState(energy: 0, dailyFreeUsed: true)));
    await tester.pump();
    expect(find.text('0'), findsOneWidget); // HUD

    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    expect(find.text('Out of energy'), findsOneWidget);

    await tester.tap(find.text('Watch ad to refill'));
    await tester.pumpAndSettle();
    expect(find.text('Out of energy'), findsNothing); // sheet closed
    expect(find.text('1'), findsOneWidget); // refilled 0 -> 1
  });

  testWidgets('Pro shows an unlimited energy HUD', (tester) async {
    await tester.pumpWidget(_home(const EnergyState(isPro: true)));
    await tester.pump();
    expect(find.text('∞'), findsOneWidget);
  });
}
