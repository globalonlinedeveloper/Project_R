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

Widget _app(WorldThemeId world,
    {bool reduceMotion = false, EnergyState? energy, StreakState? streak}) {
  final child = ProviderScope(
    overrides: [
      settingsStoreProvider
          .overrideWithValue(InMemorySettingsStore(AppSettings(world: world))),
      if (energy != null)
        energyControllerProvider.overrideWith((ref) => EnergyController(energy)),
      if (streak != null)
        streakControllerProvider.overrideWith((ref) => StreakController(streak)),
    ],
    child: MaterialApp(
      theme: world == WorldThemeId.space
          ? RatelTheme.space()
          : RatelTheme.light(),
      home: const HomeScreen(),
    ),
  );
  if (!reduceMotion) return child;
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: child,
  );
}

void main() {
  testWidgets('Classic world renders the shipped dashboard', (tester) async {
    await tester.pumpWidget(_app(WorldThemeId.classic));
    await tester.pump();
    expect(find.byKey(const Key('home-screen')), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget);
    expect(find.byKey(const Key('space-home')), findsNothing);
  });

  testWidgets('Space world renders the scrollable galaxy with the Ratel pod',
      (tester) async {
    await tester.pumpWidget(_app(WorldThemeId.space));
    await tester.pump();
    expect(find.byKey(const Key('space-home')), findsOneWidget);
    expect(find.byType(GalaxyView), findsOneWidget);
    expect(find.byType(RatelPod), findsOneWidget);
    // free-review entry contract is preserved on the galaxy home
    expect(find.text('Review mistakes · free'), findsOneWidget);
  });

  testWidgets('Space home is safe under OS reduce-motion (static, no hang)',
      (tester) async {
    await tester.pumpWidget(_app(WorldThemeId.space, reduceMotion: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('space-home')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('galaxy bottom bar shows the real θ→CEFR level (Lv A1 default)',
      (tester) async {
    await tester.pumpWidget(_app(WorldThemeId.space));
    await tester.pump();
    expect(find.text('Lv A1'), findsOneWidget);
  });

  testWidgets('new user (no progress) sees the coach prompt', (tester) async {
    await tester.pumpWidget(_app(WorldThemeId.space));
    await tester.pump();
    expect(find.textContaining('Tap the glowing planet'), findsOneWidget);
  });

  testWidgets('returning user (lessons done) hides the coach', (tester) async {
    await tester.pumpWidget(_app(
      WorldThemeId.space,
      energy: const EnergyState(lessonsCompleted: 3),
      streak: const StreakState(current: 2, longest: 4),
    ));
    await tester.pump();
    expect(find.textContaining('Tap the glowing planet'), findsNothing);
  });

  testWidgets('Space home lays out at 360px width with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(WorldThemeId.space));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(GalaxyView), findsOneWidget);
  });
}
