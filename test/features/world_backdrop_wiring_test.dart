import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// WS3-C WIRING (this increment): the live app wraps a backdrop world in
/// `WorldBackdrop` and `RatelTheme.world()` renders a TRANSLUCENT scaffold so
/// the ported animated particles show through; non-backdrop worlds stay opaque
/// and the plain light world gets no backdrop. No dummy data — palettes are the
/// ported design registry.
void main() {
  group('RatelTheme.world translucency', () {
    test('backdrop world -> translucent chrome; non-backdrop -> opaque', () {
      // ocean uses the wave-1 'bubbles' painter -> chrome must be translucent
      // so the particle field bleeds through behind the app.
      final ThemeData ocean = RatelTheme.world(kThemeWorlds['ocean']!);
      expect(ocean.scaffoldBackgroundColor.a, lessThan(0.95));
      expect(ocean.appBarTheme.backgroundColor!.a, lessThan(0.95));
      // alpine has no ported painter yet (deferred to the final wave) -> opaque.
      final ThemeData alpine = RatelTheme.world(kThemeWorlds['alpine']!);
      expect(alpine.scaffoldBackgroundColor.a, greaterThan(0.99));
    });
  });

  testWidgets('a backdrop world (ocean) mounts WorldBackdrop app-wide',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      // reduce-motion ON -> WorldBackdrop starts no ticker -> pumpAndSettle ends
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(const AppSettings(reduceMotion: true))),
      activeWorldProvider.overrideWithValue(kThemeWorlds['ocean']!),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(
        UncontrolledProviderScope(container: c, child: const RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byType(WorldBackdrop), findsOneWidget);
    // The backdrop layer (page + particles) paints behind the app content.
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('the plain light world mounts no WorldBackdrop',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byType(WorldBackdrop), findsNothing);
  });
}
