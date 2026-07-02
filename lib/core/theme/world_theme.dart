import 'package:flutter/widgets.dart';

/// A full theme-world palette, ported VERBATIM from the authoritative design
/// `THEMES()` registry (`Apps/Ratel Learning App Development/Ratel App.dc.html`,
/// L2178-2242). Unlike [RatelPalette] (neutrals only, constant accents), a world
/// re-tints the ACCENTS (accent/accent2/good/bad/gold) per the design.
///
/// Raw `Color(0x…)` literals are permitted here — `lib/core/theme` is the token
/// home (token-lint scope). The registry in `world_registry.dart` is generated
/// from the design and is the single source of world palettes.
@immutable
class WorldPalette {
  const WorldPalette({
    required this.page,
    required this.bg,
    required this.bg2,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accent2,
    required this.ink,
    required this.border,
    required this.good,
    required this.bad,
    required this.gold,
    required this.shadow,
  });

  /// Deepest backdrop base (`--page`).
  final Color page;

  /// Scaffold background (`--bg`); may be translucent for backdrop worlds.
  final Color bg;

  /// Alt background (`--bg2`).
  final Color bg2;

  /// Card surface (`--surface`).
  final Color surface;

  /// Inset / secondary surface (`--surface2`).
  final Color surface2;

  /// Primary text (`--text`).
  final Color text;

  /// Secondary/muted text (`--muted`).
  final Color muted;

  /// Primary accent / brand (`--accent`).
  final Color accent;

  /// Accent gradient-end / pressed (`--accent2`).
  final Color accent2;

  /// On-accent ink (`--ink`).
  final Color ink;

  /// Hairline border (`--border`).
  final Color border;

  /// Positive / correct (`--good`).
  final Color good;

  /// Negative / wrong (`--bad`).
  final Color bad;

  /// Reward gold (`--gold`).
  final Color gold;

  /// Soft shadow (`--shadow`).
  final Color shadow;
}

/// One selectable theme world: id + display label + traveller vehicle + the
/// named animated backdrop + Pro/free gating + its 15-token palette. Mirrors a
/// single entry of the design `THEMES()` map (id = the map key).
@immutable
class ThemeWorld {
  const ThemeWorld({
    required this.id,
    required this.label,
    required this.vehicle,
    required this.backdrop,
    required this.isFree,
    required this.isDark,
    required this.palette,
  });

  /// Stable id (the THEMES() map key, e.g. `light`, `galaxy`, `ocean`).
  final String id;

  /// Human display name (e.g. "Daylight", "Space").
  final String label;

  /// Traveller vehicle shown on the learning path (e.g. "Scooter").
  final String vehicle;

  /// Named backdrop painter (e.g. `stars`, `bubbles`, `none`).
  final String backdrop;

  /// Free (no Pro) — the design ships exactly `light` + `savanna` free.
  final bool isFree;

  /// Dark-surface world (derived from the `--bg` luminance) — lets chrome pick
  /// light-on-dark treatment without re-reading raw colors.
  final bool isDark;

  /// The world's ported palette.
  final WorldPalette palette;
}
