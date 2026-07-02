import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// WS3-B evidence — the registry-driven theme engine: selecting ANY of the 31
/// design worlds resolves its ported palette (activeWorldProvider) and builds a
/// real ThemeData (RatelTheme.world) from it. Palettes are the verbatim design
/// tokens (no dummy data); legacy 'classic'/'space' selections migrate cleanly.
void main() {
  group('registry-driven world selection', () {
    test('a non-shipped world (ocean) persists + round-trips', () {
      const AppSettings s = AppSettings();
      expect(s.worldTheme, WorldTheme.light); // default free world
      final AppSettings ocean = s.copyWith(worldTheme: WorldTheme.ocean);
      expect(AppSettings.fromMap(ocean.toMap()).worldTheme, WorldTheme.ocean);
    });

    test('legacy persisted names migrate (classic->light, space->galaxy)', () {
      expect(
          AppSettings.fromMap(<String, Object?>{'worldTheme': 'classic'})
              .worldTheme,
          WorldTheme.light);
      expect(
          AppSettings.fromMap(<String, Object?>{'worldTheme': 'space'})
              .worldTheme,
          WorldTheme.galaxy);
      expect(
          AppSettings.fromMap(<String, Object?>{'worldTheme': 'nope'})
              .worldTheme,
          WorldTheme.light); // unknown -> free default
    });

    test('activeWorldProvider resolves the selected world from the registry',
        () async {
      final InMemorySettingsStore store = InMemorySettingsStore();
      final ProviderContainer c = ProviderContainer(overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
      ]);
      addTearDown(c.dispose);
      expect(c.read(activeWorldProvider).id, 'light');
      await c
          .read(appSettingsControllerProvider.notifier)
          .setWorldTheme(WorldTheme.ocean);
      final ThemeWorld w = c.read(activeWorldProvider);
      expect(w.id, 'ocean');
      expect(w.isFree, isFalse); // ocean is a Pro world
      expect(w.backdrop, 'bubbles');
    });
  });

  group('RatelTheme.world builds ThemeData from the ported palette', () {
    test('scaffold + primary + brightness come from the world palette', () {
      final ThemeWorld ocean = kThemeWorlds['ocean']!;
      final ThemeData t = RatelTheme.world(ocean);
      // ocean has the wave-1 'bubbles' backdrop -> the scaffold is the palette
      // bg made TRANSLUCENT (80%) so the particle field shows through behind
      // the app; the RGB still comes verbatim from the palette bg.
      final Color sb = t.scaffoldBackgroundColor;
      expect(sb.r, ocean.palette.bg.r);
      expect(sb.g, ocean.palette.bg.g);
      expect(sb.b, ocean.palette.bg.b);
      expect(sb.a, lessThan(1.0));
      expect(t.colorScheme.primary, ocean.palette.accent);
      expect(t.brightness, Brightness.dark); // ocean is a dark world
      final RatelPalette? p = t.extension<RatelPalette>();
      expect(p, isNotNull);
      expect(p!.ink, ocean.palette.text);
    });

    test('a light world (candy) yields light brightness', () {
      expect(RatelTheme.world(kThemeWorlds['candy']!).brightness,
          Brightness.light);
    });
  });
}
