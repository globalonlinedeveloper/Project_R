import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// The persistence seam for [AppSettings]. Defaults to in-memory (tests +
/// keyless boots); `main` overrides it with a `PrefsSettingsStore` for real
/// on-device persistence (design spec §4.9 / §5 preferences).
final settingsStoreProvider =
    Provider<SettingsStore>((ref) => InMemorySettingsStore());

/// Bridges the `preferences` engine to the UI: loads [AppSettings] from the
/// store at build and writes every change back through it. Reduce-motion /
/// high-contrast / sound / daily-goal are REAL and persisted; the Settings
/// screen (P2) drives these mutators.
class AppSettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsStoreProvider).load();

  Future<void> _commit(AppSettings next) async {
    state = next;
    await ref.read(settingsStoreProvider).save(next);
  }

  Future<void> setHighContrast(bool value) =>
      _commit(state.copyWith(highContrast: value));

  Future<void> setSound(bool value) => _commit(state.copyWith(sound: value));

  Future<void> setHaptics(bool value) =>
      _commit(state.copyWith(haptics: value));

  /// Daily XP goal (Casual 10 / Regular 20 / Serious 30 — design spec §4.4).
  Future<void> setDailyGoal(int value) =>
      _commit(state.copyWith(dailyGoal: value));
}

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
        AppSettingsController.new);
