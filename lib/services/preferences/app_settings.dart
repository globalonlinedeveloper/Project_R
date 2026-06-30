import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

/// Minimal, neutral persisted user settings.
///
/// Pure + immutable so it serialises cleanly to any settings store. Holds the
/// a11y toggles, the daily XP goal, and (S53) the [themeMode] appearance
/// preference (System / Light / Dark — R-WT3 persisted theme selection).
@immutable
class AppSettings {
  const AppSettings({
    this.highContrast = false,
    this.sound = true,
    this.haptics = true,
    this.dailyGoal = 20,
    this.themeMode = ThemeMode.system,
    this.readNotifications = const <String>{},
    this.recentSearches = const <String>[],
  });

  final bool highContrast;
  final bool sound;
  final bool haptics;

  /// Daily XP goal (Casual 10 / Regular 20 / Serious 30).
  final int dailyGoal;

  /// Appearance preference: follow the OS (default), force light, or force dark.
  final ThemeMode themeMode;

  /// Ids of in-app notifications the learner has marked read (R-L11 inbox).
  /// Device-local read-state; absent ⇒ nothing read yet.
  final Set<String> readNotifications;

  /// The learner's recent search queries, most-recent-first (R-L12 "recent").
  /// Device-local history; absent ⇒ no searches yet. Order is significant.
  final List<String> recentSearches;

  AppSettings copyWith({
    bool? highContrast,
    bool? sound,
    bool? haptics,
    int? dailyGoal,
    ThemeMode? themeMode,
    Set<String>? readNotifications,
    List<String>? recentSearches,
  }) =>
      AppSettings(
        highContrast: highContrast ?? this.highContrast,
        sound: sound ?? this.sound,
        haptics: haptics ?? this.haptics,
        dailyGoal: dailyGoal ?? this.dailyGoal,
        themeMode: themeMode ?? this.themeMode,
        readNotifications: readNotifications ?? this.readNotifications,
        recentSearches: recentSearches ?? this.recentSearches,
      );

  Map<String, Object> toMap() => <String, Object>{
        'highContrast': highContrast,
        'sound': sound,
        'haptics': haptics,
        'dailyGoal': dailyGoal,
        'themeMode': themeMode.name,
        'readNotifications': (readNotifications.toList()..sort()).join(','),
        'recentSearches': recentSearches.map(Uri.encodeComponent).join(','),
      };

  static AppSettings fromMap(Map<String, Object?> m) => AppSettings(
        highContrast: m['highContrast'] as bool? ?? false,
        sound: m['sound'] as bool? ?? true,
        haptics: m['haptics'] as bool? ?? true,
        dailyGoal: (m['dailyGoal'] as int?) ?? 20,
        themeMode: _themeModeFromName(m['themeMode'] as String?),
        readNotifications: _readNotifsFromCsv(m['readNotifications'] as String?),
        recentSearches: _recentsFromCsv(m['recentSearches'] as String?),
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.highContrast == highContrast &&
      other.sound == sound &&
      other.haptics == haptics &&
      other.dailyGoal == dailyGoal &&
      other.themeMode == themeMode &&
      setEquals(other.readNotifications, readNotifications) &&
      listEquals(other.recentSearches, recentSearches);

  @override
  int get hashCode =>
      Object.hash(highContrast, sound, haptics, dailyGoal, themeMode,
          Object.hashAllUnordered(readNotifications), Object.hashAll(recentSearches));
}

/// Parse a persisted read-notifications CSV into a set; null/empty ⇒ none.
Set<String> _readNotifsFromCsv(String? csv) {
  if (csv == null || csv.isEmpty) return const <String>{};
  return csv.split(',').where((String s) => s.isNotEmpty).toSet();
}

/// Parse a persisted recent-search CSV (URL-encoded items) into an ordered list;
/// null/empty ⇒ none. Encoding keeps commas/newlines in a query safe (R-L12).
List<String> _recentsFromCsv(String? csv) {
  if (csv == null || csv.isEmpty) return const <String>[];
  return <String>[
    for (final String e in csv.split(','))
      if (e.isNotEmpty) Uri.decodeComponent(e),
  ];
}

/// Parse a persisted [ThemeMode] name; unknown/absent ⇒ follow the system.
ThemeMode _themeModeFromName(String? name) {
  switch (name) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}
