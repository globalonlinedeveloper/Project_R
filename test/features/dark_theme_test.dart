import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// Dark theme (S53) — R-WT3 persisted theme selection · R-WT6 settings
/// appearance surface. Locks the warm-charcoal dark mode, the theme-aware
/// neutral palette, durable persistence, and the Settings picker.
void main() {
  group('RatelPalette', () {
    test('light is byte-identical to the original RatelColors neutrals (§11)',
        () {
      expect(RatelPalette.light.cream, RatelColors.cream);
      expect(RatelPalette.light.cream2, RatelColors.cream2);
      expect(RatelPalette.light.cream3, RatelColors.cream3);
      expect(RatelPalette.light.white, RatelColors.white);
      expect(RatelPalette.light.ink, RatelColors.ink);
      expect(RatelPalette.light.muted, RatelColors.muted);
      expect(RatelPalette.light.border, RatelColors.border);
      expect(RatelPalette.light.shadow, RatelColors.shadow);
      expect(RatelPalette.light.scrim, RatelColors.scrim);
    });

    test('dark differs from light and is a true high-contrast dark', () {
      expect(RatelPalette.dark.cream, isNot(RatelPalette.light.cream));
      expect(RatelPalette.dark.ink, isNot(RatelPalette.light.ink));
      // Background is near-black, ink is near-white → text reads on the surface.
      expect(RatelPalette.dark.cream.computeLuminance(), lessThan(0.05));
      expect(RatelPalette.dark.ink.computeLuminance(), greaterThan(0.6));
      expect(RatelPalette.dark.ink.computeLuminance(),
          greaterThan(RatelPalette.dark.cream.computeLuminance()));
      // Muted stays clearly above the background too (readable secondary text).
      expect(RatelPalette.dark.muted.computeLuminance(),
          greaterThan(RatelPalette.dark.cream.computeLuminance()));
    });

    test('lerp endpoints return the bounds', () {
      expect(RatelPalette.light.lerp(RatelPalette.dark, 0).ink,
          RatelPalette.light.ink);
      expect(RatelPalette.light.lerp(RatelPalette.dark, 1).ink,
          RatelPalette.dark.ink);
    });
  });

  group('RatelTheme', () {
    test('light/dark carry the right brightness + registered palette', () {
      final ThemeData light = RatelTheme.light();
      final ThemeData dark = RatelTheme.dark();
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(light.extension<RatelPalette>(), RatelPalette.light);
      expect(dark.extension<RatelPalette>(), RatelPalette.dark);
      expect(dark.scaffoldBackgroundColor, RatelColors.darkBg);
      // Brand accents are constant across modes.
      expect(dark.colorScheme.primary, RatelColors.teal);
      expect(light.colorScheme.primary, RatelColors.teal);
    });

    testWidgets('context.palette resolves per active theme, light fallback',
        (WidgetTester tester) async {
      Future<RatelPalette> readUnder(ThemeData theme) async {
        late RatelPalette p;
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Theme(
            data: theme,
            child: Builder(builder: (BuildContext c) {
              p = c.palette;
              return const SizedBox();
            }),
          ),
        ));
        return p;
      }

      expect(await readUnder(RatelTheme.dark()), RatelPalette.dark);
      expect(await readUnder(RatelTheme.light()), RatelPalette.light);
      // No Ratel extension present → safe light fallback (keeps bare-pumped
      // widget tests byte-identical to today).
      expect(await readUnder(ThemeData()), RatelPalette.light);
    });
  });

  group('themeMode persistence', () {
    test('AppSettings defaults to system + round-trips through the map', () {
      expect(const AppSettings().themeMode, ThemeMode.system);
      expect(const AppSettings(themeMode: ThemeMode.dark).toMap()['themeMode'],
          'dark');
      expect(
          AppSettings.fromMap(<String, Object?>{'themeMode': 'dark'}).themeMode,
          ThemeMode.dark);
      expect(
          AppSettings.fromMap(<String, Object?>{'themeMode': 'light'}).themeMode,
          ThemeMode.light);
      // Absent / unknown ⇒ follow the system.
      expect(AppSettings.fromMap(<String, Object?>{}).themeMode,
          ThemeMode.system);
      expect(
          AppSettings.fromMap(<String, Object?>{'themeMode': 'bogus'}).themeMode,
          ThemeMode.system);
    });

    test('setThemeMode writes through the store and themeModeProvider follows',
        () async {
      final InMemorySettingsStore store = InMemorySettingsStore();
      final ProviderContainer c = ProviderContainer(overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
      ]);
      addTearDown(c.dispose);

      expect(c.read(themeModeProvider), ThemeMode.system);
      await c
          .read(appSettingsControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      expect(c.read(themeModeProvider), ThemeMode.dark);
      // Durable: the choice reached the persistence store.
      expect(store.current.themeMode, ThemeMode.dark);
    });
  });

  testWidgets('Settings Appearance picker switches + persists the theme',
      (WidgetTester tester) async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[settingsStoreProvider.overrideWithValue(store)],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();

    // RatelSectionHeader uppercases → the header renders 'APPEARANCE'; assert
    // the row title + current label (RatelListRow text is verbatim).
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Match device'), findsOneWidget); // current label (default)

    await tester.ensureVisible(find.text('Theme'));
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    expect(find.text('Dark'), findsOneWidget); // picker option
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(store.current.themeMode, ThemeMode.dark);
  });
}
