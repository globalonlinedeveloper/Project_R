import 'dart:ui' show PictureRecorder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// G1 evidence — the Space world-theme (R-WT1 / R-WT2 / R-WT3): a persisted
/// Classic/Space selection + a real app-wide re-skin. Honest: Space is opt-in
/// and OFF by default. Since wave-4d the galaxy field is the ANIMATED `stars`
/// painter mounted via `WorldBackdrop` (R-WT7); `StarfieldPainter` remains as
/// the reduce-motion static frame + is unit-tested below.
void main() {
  group('WorldTheme persistence', () {
    test('defaults to Classic + round-trips through the map', () {
      const AppSettings s = AppSettings();
      expect(s.worldTheme, WorldTheme.classic);
      final AppSettings space = s.copyWith(worldTheme: WorldTheme.space);
      expect(AppSettings.fromMap(space.toMap()).worldTheme, WorldTheme.space);
    });

    test('setWorldTheme writes through the store; provider follows', () async {
      final InMemorySettingsStore store = InMemorySettingsStore();
      final ProviderContainer c = ProviderContainer(overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
      ]);
      addTearDown(c.dispose);
      expect(c.read(worldThemeProvider), WorldTheme.classic);
      await c
          .read(appSettingsControllerProvider.notifier)
          .setWorldTheme(WorldTheme.space);
      expect(c.read(worldThemeProvider), WorldTheme.space);
      expect(store.current.worldTheme, WorldTheme.space); // durable
    });
  });

  group('StarfieldPainter', () {
    test('paints without error + repaints only on config change', () {
      const StarfieldPainter p = StarfieldPainter();
      final PictureRecorder rec = PictureRecorder();
      final Canvas canvas = Canvas(rec);
      p.paint(canvas, const Size(400, 800));
      p.paint(canvas, Size.zero); // empty size is a safe no-op
      expect(p.shouldRepaint(const StarfieldPainter()), isFalse);
      expect(p.shouldRepaint(const StarfieldPainter(seed: 9)), isTrue);
    });
  });

  testWidgets('Space mounts the animated galaxy backdrop; Classic does not',
      (WidgetTester tester) async {
    // reduce-motion ON → WorldBackdrop starts no ticker → pumpAndSettle ends.
    final InMemorySettingsStore store = InMemorySettingsStore(
        const AppSettings(worldTheme: WorldTheme.space, reduceMotion: true));
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      settingsStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(
        UncontrolledProviderScope(container: c, child: const RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byType(WorldBackdrop), findsOneWidget); // Space → animated field

    // Flip to Classic → no backdrop world (real opt-in, not always-on).
    await c
        .read(appSettingsControllerProvider.notifier)
        .setWorldTheme(WorldTheme.classic);
    await tester.pumpAndSettle();
    expect(find.byType(WorldBackdrop), findsNothing);
  });

  testWidgets('Settings exposes the World selector', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('World'), findsOneWidget);
  });
}
