/// RATEL design tokens — the SINGLE source of raw color / spacing / shape / type
/// values for the whole app.
///
/// Per the design-system charter this is the ONLY file permitted to contain raw
/// `Color(0x…)` literals. Every shared component (lib/core/components), every
/// screen (lib/features) and the app shell (lib/app) MUST reference these tokens
/// instead of hard-coding values. `test/core/token_lint_test.dart` enforces the
/// rule (a raw color literal anywhere outside lib/core/theme fails the build).
///
/// Exact hex sampled from the owner's design bundle — see
/// `Apps/RATEL/design_spec/RATEL_DESIGN_SPEC.md` §2.
library;

import 'package:flutter/widgets.dart';

/// Core + accent color tokens (spec §2). Raw hex lives ONLY here.
abstract final class RatelColors {
  // ── Core ────────────────────────────────────────────────────────────────
  /// Primary action, selection, active nav, brand; also splash bg.
  static const Color teal = Color(0xFF16A085);

  /// Primary gradient-end / pressed; dark feature cards (AI Tutor "Talk").
  static const Color tealDark = Color(0xFF0F7D68);

  /// Correct answer, promotion zone, "Continue", positive.
  static const Color green = Color(0xFF2BA66B);

  /// Accent, PRO, daily-goal card, gold/rewards, wordmark.
  static const Color amber = Color(0xFFE0972B);

  /// Darker amber for the DAILY GOAL gradient (design §4.4). Theme-only.
  static const Color amberDark = Color(0xFFC17E1F);

  /// Wrong answer, error, streak flame, demotion, destructive.
  static const Color coral = Color(0xFFE5573F);

  /// Warm app background.
  static const Color cream = Color(0xFFE4E0D5);

  /// Secondary surface / scrim.
  static const Color cream2 = Color(0xFFF6F3EC);

  /// Alt card / inset bg.
  static const Color cream3 = Color(0xFFF1EEE5);

  /// Card surface.
  static const Color white = Color(0xFFFFFFFF);

  /// Primary text.
  static const Color ink = Color(0xFF1B1D1F);

  /// Secondary text / small-caps section labels.
  static const Color muted = Color(0xFF76746C);

  /// Hairline card border (warm).
  static const Color border = Color(0xFFECE8DE);

  // ── Accent set — per-item tints (achievements, districts, leagues) ───────
  static const Color gold = Color(0xFFFFD36B);
  static const Color blue = Color(0xFF2A6FDB);
  static const Color purple = Color(0xFF9B59B6);
  static const Color cyan = Color(0xFF16E0FF);
  static const Color pink = Color(0xFFFF7AA0);
  static const Color lavender = Color(0xFFB89CFF);
  static const Color mint = Color(0xFF5FE0B0);
  static const Color redFlag = Color(0xFFC8102E);
  static const Color redFlagAlt = Color(0xFFC0392B);
  static const Color navy = Color(0xFF15324A);

  // -- League tier badges (design spec 4.3 ladder, Bronze -> Diamond) -------
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFF9AA7B2);
  static const Color tierGold = Color(0xFFE0972B);
  static const Color tierSapphire = Color(0xFF2A6FDB);
  static const Color tierRuby = Color(0xFFC0392B);
  static const Color tierEmerald = Color(0xFF1F8A5B);
  static const Color tierAmethyst = Color(0xFF7D3CC9);
  static const Color tierPearl = Color(0xFF9AA0A6);
  static const Color tierObsidian = Color(0xFF3A3A44);
  static const Color tierDiamond = Color(0xFF16A085);

  // ── Derived neutrals ─────────────────────────────────────────────────────
  /// Text / icon on a saturated (teal/green/amber/coral) surface.
  static const Color onColor = Color(0xFFFFFFFF);

  /// Soft shadow for the near-flat cards (~8% black).
  static const Color shadow = Color(0x14000000);

  /// Translucent scrim behind bottom sheets / modals (~45% black).
  static const Color scrim = Color(0x73000000);

  // ── Dark-theme neutrals (S53) — warm charcoal; the accents above are reused
  // unchanged in dark mode. Surfaced via RatelPalette.dark (lib/core/theme).
  /// Dark app background (warm near-black).
  static const Color darkBg = Color(0xFF15140F);

  /// Dark secondary surface.
  static const Color darkBg2 = Color(0xFF1C1A14);

  /// Dark inset / alt background.
  static const Color darkBg3 = Color(0xFF222019);

  /// Dark card surface (subtly lifted off the background).
  static const Color darkSurface = Color(0xFF24221B);

  /// Dark primary text (warm off-white, ~16:1 on darkBg).
  static const Color darkInk = Color(0xFFF3F0E7);

  /// Dark secondary text (~7:1 on darkBg).
  static const Color darkMuted = Color(0xFFA8A496);

  /// Dark hairline border.
  static const Color darkBorder = Color(0xFF34312A);

  /// Dark card shadow (deeper than the light ~8%).
  static const Color darkShadow = Color(0x33000000);

  /// Dark modal scrim (~60% black).
  static const Color darkScrim = Color(0x99000000);

  // ── SPACE world-theme (R-WT1/WT2, S66) — deep-space neutrals; the brand
  // accents (teal/amber/coral/green/gold) are reused unchanged. ──────────────
  /// Solid deep-space backdrop painted behind the starfield.
  static const Color spaceBackdrop = Color(0xFF070A16);

  /// Star colour.
  static const Color spaceStar = Color(0xFFFFFFFF);

  /// Scaffold background — TRANSLUCENT so the app-wide starfield shows through.
  static const Color spaceBg = Color(0xCC0C1226);

  /// Card surface (opaque deep blue).
  static const Color spaceBg2 = Color(0xFF141C36);

  /// Raised surface.
  static const Color spaceBg3 = Color(0xFF1B2547);

  static const Color spaceSurface = Color(0xFF1B2547);
  static const Color spaceInk = Color(0xFFEDF0FF);
  static const Color spaceMuted = Color(0xFFA6B0D8);
  static const Color spaceBorder = Color(0x33A6B0D8);
  static const Color spaceShadow = Color(0x66000000);
  static const Color spaceScrim = Color(0x99000510);

  /// Galaxy pod hull (R-WT4, G2) — metallic light + shaded hull.
  static const Color spacePodLight = Color(0xFFE9EDFF);

  /// Galaxy pod hull shade.
  static const Color spacePodHull = Color(0xFFB9C2E8);

  /// Near-black planet shade (dark side of a galaxy planet).
  static const Color spacePlanetShade = Color(0xFF04060E);
}

/// Spacing scale (spec §2: 4 / 8 / 12 / 16 / 20 / 24).
abstract final class RatelSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  /// Screen horizontal padding (inner content ≈390 of 430).
  static const double screen = 20;
  static const double xl = 24;

  /// Default inter-card gap.
  static const double cardGap = 12;

  /// Default card inner padding.
  static const double cardPad = 16;
}

/// Corner radii (spec §2).
abstract final class RatelRadius {
  static const double chip = 12;
  static const double card = 16;
  static const double feature = 20;
  static const double featureLg = 24;

  /// Pills & full-width buttons.
  static const double pill = 999;
}

/// Bundled font families (variable TTFs declared in pubspec `fonts:`).
abstract final class RatelFont {
  /// Dominant display + UI font (rounded, friendly). Weight 800 for headings,
  /// titles, buttons, numbers.
  static const String display = 'Baloo 2';

  /// Body / longer text + subtitles.
  static const String body = 'Nunito Sans';
}

/// Type scale in logical px + the weight tokens (spec §2).
abstract final class RatelType {
  static const double caption = 11; // section labels / tiny
  static const double small = 13;
  static const double body = 15;
  static const double bodyLg = 16;
  static const double cardTitle = 18;
  static const double screenTitle = 24;
  static const double hero = 32;
  static const double bigNumber = 76;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w600;
  static const FontWeight semiBold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

/// Motion durations — light, playful (spec §2). Honor reduce-motion at the call
/// site (a hard floor returns [Duration.zero]); these are the full-motion values.
abstract final class RatelMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}
