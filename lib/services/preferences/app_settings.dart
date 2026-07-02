import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

/// The selectable WORLD theme — one of the 31 design worlds (`THEMES()`), keyed
/// by the SAME id as `kThemeWorlds` (lib/core/theme/world_registry.dart). The
/// design ships 2 free (light, savanna) + 29 Pro. `classic`/`space` remain as
/// back-compat aliases for the two originally-shipped worlds.
enum WorldTheme {
  light, galaxy, savanna, ocean, forest, candy, neon, storm, snow, sakura,
  autumn, aurora, volcano, sunset, desert, reef, meadow, dawn, beach, mars,
  jungle, cyberrain, abyss, alpine, lavender, bamboo, lagoon, thunder, nebula,
  sandstorm, cherrynight;

  /// Back-compat alias: the original "Classic" skin is the `light` world.
  static const WorldTheme classic = WorldTheme.light;

  /// Back-compat alias: the original "Space" skin is the `galaxy` world.
  static const WorldTheme space = WorldTheme.galaxy;
}

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
    this.reduceMotion = false,
    this.mutedNotifications = const <String>{},
    this.displayName = '',
    this.worldTheme = WorldTheme.classic,
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

  /// Whether the learner asked to reduce non-essential motion/animation
  /// (HABITS · §4.9 · R-WT5 motion preference). Honored app-wide via
  /// MediaQuery.disableAnimations; the OS
  /// reduce-motion setting stays a hard floor on top.
  final bool reduceMotion;

  /// Notification categories the learner has MUTED (push/streak/league/friend).
  /// Empty ⇒ all on. The preference persists now; delivery activates with the
  /// push engine (§6).
  final Set<String> mutedNotifications;

  /// Whether a notification [category] is enabled (i.e. not muted).
  bool notifyEnabled(String category) => !mutedNotifications.contains(category);

  /// The learner's chosen display name (Edit profile · §4.9). Device-local;
  /// empty ⇒ fall back to "Learner"/"Guest" on the profile header.
  final String displayName;

  /// The selected world theme (Classic / Space — R-WT3 persisted opt-in).
  final WorldTheme worldTheme;

  AppSettings copyWith({
    bool? highContrast,
    bool? sound,
    bool? haptics,
    int? dailyGoal,
    ThemeMode? themeMode,
    Set<String>? readNotifications,
    List<String>? recentSearches,
    bool? reduceMotion,
    Set<String>? mutedNotifications,
    String? displayName,
    WorldTheme? worldTheme,
  }) =>
      AppSettings(
        highContrast: highContrast ?? this.highContrast,
        sound: sound ?? this.sound,
        haptics: haptics ?? this.haptics,
        dailyGoal: dailyGoal ?? this.dailyGoal,
        themeMode: themeMode ?? this.themeMode,
        readNotifications: readNotifications ?? this.readNotifications,
        recentSearches: recentSearches ?? this.recentSearches,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        mutedNotifications: mutedNotifications ?? this.mutedNotifications,
        displayName: displayName ?? this.displayName,
        worldTheme: worldTheme ?? this.worldTheme,
      );

  Map<String, Object> toMap() => <String, Object>{
        'highContrast': highContrast,
        'sound': sound,
        'haptics': haptics,
        'dailyGoal': dailyGoal,
        'themeMode': themeMode.name,
        'readNotifications': (readNotifications.toList()..sort()).join(','),
        'recentSearches': recentSearches.map(Uri.encodeComponent).join(','),
        'reduceMotion': reduceMotion,
        'mutedNotifications': (mutedNotifications.toList()..sort()).join(','),
        'displayName': displayName,
        'worldTheme': worldTheme.name,
      };

  static AppSettings fromMap(Map<String, Object?> m) => AppSettings(
        highContrast: m['highContrast'] as bool? ?? false,
        sound: m['sound'] as bool? ?? true,
        haptics: m['haptics'] as bool? ?? true,
        dailyGoal: (m['dailyGoal'] as int?) ?? 20,
        themeMode: _themeModeFromName(m['themeMode'] as String?),
        readNotifications: _readNotifsFromCsv(m['readNotifications'] as String?),
        recentSearches: _recentsFromCsv(m['recentSearches'] as String?),
        reduceMotion: m['reduceMotion'] as bool? ?? false,
        mutedNotifications: _mutedFromCsv(m['mutedNotifications'] as String?),
        displayName: m['displayName'] as String? ?? '',
        worldTheme: _worldThemeFromName(m['worldTheme'] as String?),
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
      listEquals(other.recentSearches, recentSearches) &&
      other.reduceMotion == reduceMotion &&
      setEquals(other.mutedNotifications, mutedNotifications) &&
      other.displayName == displayName &&
      other.worldTheme == worldTheme;

  @override
  int get hashCode =>
      Object.hash(highContrast, sound, haptics, dailyGoal, themeMode,
          Object.hashAllUnordered(readNotifications), Object.hashAll(recentSearches),
          reduceMotion, Object.hashAllUnordered(mutedNotifications), displayName,
          worldTheme);
}

/// Parse a persisted read-notifications CSV into a set; null/empty ⇒ none.
Set<String> _readNotifsFromCsv(String? csv) {
  if (csv == null || csv.isEmpty) return const <String>{};
  return csv.split(',').where((String s) => s.isNotEmpty).toSet();
}

/// Parse a persisted muted-notifications CSV into a set; null/empty ⇒ none muted.
Set<String> _mutedFromCsv(String? csv) {
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

/// Parse a persisted [WorldTheme] name; legacy 'classic'/'space' map to the
/// light/galaxy worlds; an unknown/absent value ⇒ light (the free default).
WorldTheme _worldThemeFromName(String? name) {
  if (name == null || name.isEmpty) return WorldTheme.light;
  if (name == 'classic') return WorldTheme.classic; // == light
  if (name == 'space') return WorldTheme.space; // == galaxy
  for (final WorldTheme w in WorldTheme.values) {
    if (w.name == name) return w;
  }
  return WorldTheme.light;
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
