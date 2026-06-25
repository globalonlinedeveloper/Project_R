import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/energy/energy_controller.dart';
import 'package:ratel/features/energy/energy_state.dart';
import 'package:ratel/features/streak/streak_controller.dart';
import 'package:ratel/features/home/home_screen.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// Space-world Home harness (mirrors home_space_test) for the C3 locate FAB.
Widget _app({bool reduceMotion = false, EnergyState? energy, StreakState? streak}) {
  final child = ProviderScope(
    overrides: [
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(const AppSettings(world: WorldThemeId.space))),
      if (energy != null)
        energyControllerProvider.overrideWith((ref) => EnergyController(energy)),
      if (streak != null)
        streakControllerProvider.overrideWith((ref) => StreakController(streak)),
    ],
    child: MaterialApp(theme: RatelTheme.space(), home: const HomeScreen()),
  );
  if (!reduceMotion) return child;
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: child,
  );
}

void main() {
  testWidgets('locate FAB is present on the galaxy home', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(find.byKey(const Key('locate-fab')), findsOneWidget);
  });

  testWidgets('locate FAB recenters without throwing (animateTo path)',
      (tester) async {
    await tester.pumpWidget(_app(
      energy: const EnergyState(lessonsCompleted: 4),
      streak: const StreakState(current: 2, longest: 4),
    ));
    await tester.pump();
    final fab = find.byKey(const Key('locate-fab'));
    expect(fab, findsOneWidget);
    // tap recenters on the active planet via animateTo (full motion)
    await tester.tap(fab);
    await tester.pump(); // kick the animation
    await tester.pump(const Duration(milliseconds: 400)); // past RatelMotion.slow
    expect(tester.takeException(), isNull);
  });

  testWidgets('locate FAB jumps without throwing under reduce-motion (static)',
      (tester) async {
    await tester.pumpWidget(_app(
      reduceMotion: true,
      energy: const EnergyState(lessonsCompleted: 4),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('locate-fab')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
