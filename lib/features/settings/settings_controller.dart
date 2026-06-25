import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../../services/preferences/settings_store.dart';

/// The injectable settings store. Defaults to in-memory; `main` overrides it
/// with a [PrefsSettingsStore] for real on-device persistence.
final settingsStoreProvider =
    Provider<SettingsStore>((ref) => InMemorySettingsStore());

/// App-wide settings (world/theme, motion, a11y). Persists every change through
/// the [settingsStoreProvider]. The whole app watches this to re-skin instantly
/// when the world theme changes (Classic ⇄ Space), and the choice survives
/// relaunch via the persisted store.
class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._store) : super(_store.load());

  final SettingsStore _store;

  void _commit(AppSettings next) {
    state = next;
    _store.save(next);
  }

  void setWorld(WorldThemeId world) => _commit(state.copyWith(world: world));

  void toggleSpace() => setWorld(
      state.world == WorldThemeId.space ? WorldThemeId.classic : WorldThemeId.space);

  void setMotion(MotionPreference motion) =>
      _commit(state.copyWith(motion: motion));

  void setHighContrast(bool on) => _commit(state.copyWith(highContrast: on));

  void setSound(bool on) => _commit(state.copyWith(sound: on));

  void setHaptics(bool on) => _commit(state.copyWith(haptics: on));

  /// Daily XP goal picker (Casual 10 / Regular 20 / Serious 30).
  void setDailyGoal(int goal) => _commit(state.copyWith(dailyGoal: goal));
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>(
        (ref) => SettingsController(ref.watch(settingsStoreProvider)));

/// The active [WorldTheme] derived from settings — a thin selector the app and
/// screens watch.
final worldThemeProvider = Provider<WorldTheme>(
    (ref) => WorldTheme.of(ref.watch(settingsControllerProvider).world));
// Traceability: R-WT1 R-WT3 R-WT6
