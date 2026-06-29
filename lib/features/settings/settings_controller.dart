import 'package:flutter/material.dart' show ThemeMode;
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
/// high-contrast / sound / daily-goal / appearance are REAL and persisted; the
/// Settings screen drives these mutators.
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

  /// Appearance preference (System / Light / Dark — R-WT3, S53).
  Future<void> setThemeMode(ThemeMode value) =>
      _commit(state.copyWith(themeMode: value));

  /// Marks notification [ids] as read (R-L11 inbox). Persisted device-locally
  /// so the unread badge survives a relaunch; a no-op when nothing new is added.
  Future<void> addReadNotifications(Iterable<String> ids) {
    final Set<String> next = <String>{...state.readNotifications, ...ids};
    if (next.length == state.readNotifications.length) {
      return Future<void>.value();
    }
    return _commit(state.copyWith(readNotifications: next));
  }
}

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
        AppSettingsController.new);
