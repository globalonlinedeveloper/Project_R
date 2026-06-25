import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/home/home_screen.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/settings_store.dart';

Widget _app(WorldThemeId world, {bool reduceMotion = false}) {
  final child = ProviderScope(
    overrides: [
      settingsStoreProvider
          .overrideWithValue(InMemorySettingsStore(AppSettings(world: world))),
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

  testWidgets('Space world renders the galaxy home with the Ratel pod',
      (tester) async {
    await tester.pumpWidget(_app(WorldThemeId.space));
    await tester.pump();
    expect(find.byKey(const Key('space-home')), findsOneWidget);
    expect(find.byType(RatelPod), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget); // gated CTA still present
  });

  testWidgets('Space home is safe under OS reduce-motion (hard floor)',
      (tester) async {
    await tester.pumpWidget(_app(WorldThemeId.space, reduceMotion: true));
    await tester.pump();
    expect(find.byKey(const Key('space-home')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Space home lays out at 360px width with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(WorldThemeId.space));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('space-home')), findsOneWidget);
  });
}
// Traceability: R-WT4
