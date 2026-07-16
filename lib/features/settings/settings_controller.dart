import 'package:flutter/foundation.dart' show listEquals;
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

  /// World theme (Classic / Space — R-WT3, S66). Persisted; drives the
  /// app-wide Space re-skin + starfield.
  Future<void> setWorldTheme(WorldTheme value) =>
      _commit(state.copyWith(worldTheme: value));

  /// Reduce non-essential motion (HABITS · §4.9). Persisted; honored app-wide.
  Future<void> setReduceMotion(bool value) =>
      _commit(state.copyWith(reduceMotion: value));

  /// Enable/disable a notification [category] (push/streak/league/friend). The
  /// preference persists now; delivery activates with the push engine (§6).
  Future<void> setNotification(String category, bool enabled) {
    final Set<String> next = <String>{...state.mutedNotifications};
    if (enabled) {
      next.remove(category);
    } else {
      next.add(category);
    }
    return _commit(state.copyWith(mutedNotifications: next));
  }

  /// The learner's display name (Edit profile · §4.9). Device-local; trimmed.
  Future<void> setDisplayName(String value) =>
      _commit(state.copyWith(displayName: value.trim()));

  /// The learner's emoji avatar (Edit profile · §4.9 · design #60/#61).
  /// Device-local; empty ⇒ fall back to the equipped outfit emoji on the header.
  Future<void> setAvatarEmoji(String value) =>
      _commit(state.copyWith(avatarEmoji: value));

  /// The learner's short bio (Edit profile · §4.9 · design #60). Device-local;
  /// trimmed. Empty ⇒ nothing shown on the profile header.
  Future<void> setBio(String value) =>
      _commit(state.copyWith(bio: value.trim()));

  /// Marks notification [ids] as read (R-L11 inbox). Persisted device-locally
  /// so the unread badge survives a relaunch; a no-op when nothing new is added.
  Future<void> addReadNotifications(Iterable<String> ids) {
    final Set<String> next = <String>{...state.readNotifications, ...ids};
    if (next.length == state.readNotifications.length) {
      return Future<void>.value();
    }
    return _commit(state.copyWith(readNotifications: next));
  }

  /// Records a search [query] in the device-local recent list (R-L12 "recent").
  /// Most-recent-first, deduped case-insensitively, capped at 8, and persisted so
  /// it survives a relaunch; blank queries are ignored.
  Future<void> addRecentSearch(String query) {
    final String q = query.trim();
    if (q.isEmpty) return Future<void>.value();
    final List<String> next = <String>[
      q,
      for (final String s in state.recentSearches)
        if (s.toLowerCase() != q.toLowerCase()) s,
    ];
    const int cap = 8;
    final List<String> capped =
        next.length > cap ? next.sublist(0, cap) : next;
    if (listEquals(capped, state.recentSearches)) return Future<void>.value();
    return _commit(state.copyWith(recentSearches: capped));
  }

  /// Clears the device-local recent-search history (R-L12).
  Future<void> clearRecentSearches() {
    if (state.recentSearches.isEmpty) return Future<void>.value();
    return _commit(state.copyWith(recentSearches: const <String>[]));
  }
}

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
        AppSettingsController.new);
