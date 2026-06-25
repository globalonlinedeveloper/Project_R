import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/settings_store.dart';

void main() {
  test('defaults to Classic; toggleSpace flips the world', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(settingsControllerProvider).world, WorldThemeId.classic);
    container.read(settingsControllerProvider.notifier).toggleSpace();
    expect(container.read(settingsControllerProvider).world, WorldThemeId.space);
    expect(container.read(worldThemeProvider).isSpace, isTrue);
  });

  test('every change is persisted through the store (survives relaunch)', () {
    final store = InMemorySettingsStore();
    final container = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    final ctrl = container.read(settingsControllerProvider.notifier);
    ctrl.setWorld(WorldThemeId.space);
    ctrl.setMotion(MotionPreference.off);
    ctrl.setHighContrast(true);

    // The store captured the writes...
    expect(store.current.world, WorldThemeId.space);
    expect(store.current.motion, MotionPreference.off);
    expect(store.current.highContrast, isTrue);

    // ...so a fresh controller over the same store boots into the saved world.
    final relaunch = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(relaunch.dispose);
    expect(relaunch.read(settingsControllerProvider).world, WorldThemeId.space);
  });
}
// Traceability: R-WT3 R-WT6
