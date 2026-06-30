import 'package:flutter/material.dart';

import 'tokens.dart';

/// Theme-aware semantic NEUTRALS — the only colours that flip between light and
/// dark. The brand ACCENTS (teal / amber / coral / green / gold / blue / …) stay
/// constant across both modes, so a `RatelColors.teal` reference is correct in
/// either theme; only backgrounds, surfaces, text-ink, muted and borders change.
///
/// Registered as a [ThemeExtension] on both `RatelTheme.light()` and
/// `RatelTheme.dark()` and read through `context.palette`. The getter falls back
/// to [light] when no extension is present, so a widget pumped WITHOUT the full
/// Ratel theme renders byte-identically to today's light theme — every existing
/// component/screen test stays green with no harness change (§11).
///
/// Requirements: R-WT3 (persisted theme selection — reborn as light/dark/system
/// in the post-S35 design system) · R-WT6 (settings appearance surface). The
/// galaxy/Space world-skin (R-WT2) stays a §6 no-engine owner item — NOT built.
@immutable
class RatelPalette extends ThemeExtension<RatelPalette> {
  const RatelPalette({
    required this.cream,
    required this.cream2,
    required this.cream3,
    required this.white,
    required this.ink,
    required this.muted,
    required this.border,
    required this.shadow,
    required this.scrim,
  });

  /// App background.
  final Color cream;

  /// Secondary surface / scrim base.
  final Color cream2;

  /// Alt card / inset background.
  final Color cream3;

  /// Card surface.
  final Color white;

  /// Primary text.
  final Color ink;

  /// Secondary text / small-caps labels.
  final Color muted;

  /// Hairline card border.
  final Color border;

  /// Soft card shadow.
  final Color shadow;

  /// Translucent modal scrim.
  final Color scrim;

  /// LIGHT — byte-identical to the original [RatelColors] neutrals, so light
  /// mode is visually unchanged (§11) and is the safe fallback.
  static const RatelPalette light = RatelPalette(
    cream: RatelColors.cream,
    cream2: RatelColors.cream2,
    cream3: RatelColors.cream3,
    white: RatelColors.white,
    ink: RatelColors.ink,
    muted: RatelColors.muted,
    border: RatelColors.border,
    shadow: RatelColors.shadow,
    scrim: RatelColors.scrim,
  );

  /// DARK — warm charcoal (not pure black) to match the app's warm character;
  /// high-contrast off-white ink (≈16:1 on the background), readable muted
  /// (≈7:1), subtle warm borders. Accents are reused unchanged.
  static const RatelPalette dark = RatelPalette(
    cream: RatelColors.darkBg,
    cream2: RatelColors.darkBg2,
    cream3: RatelColors.darkBg3,
    white: RatelColors.darkSurface,
    ink: RatelColors.darkInk,
    muted: RatelColors.darkMuted,
    border: RatelColors.darkBorder,
    shadow: RatelColors.darkShadow,
    scrim: RatelColors.darkScrim,
  );

  /// SPACE world-theme (R-WT2, S66) — deep-space neutrals. The scaffold
  /// [cream] is translucent so the app-wide starfield shows through; cards are
  /// opaque. Accents are reused unchanged.
  static const RatelPalette space = RatelPalette(
    cream: RatelColors.spaceBg,
    cream2: RatelColors.spaceBg2,
    cream3: RatelColors.spaceBg3,
    white: RatelColors.spaceSurface,
    ink: RatelColors.spaceInk,
    muted: RatelColors.spaceMuted,
    border: RatelColors.spaceBorder,
    shadow: RatelColors.spaceShadow,
    scrim: RatelColors.spaceScrim,
  );

  @override
  RatelPalette copyWith({
    Color? cream,
    Color? cream2,
    Color? cream3,
    Color? white,
    Color? ink,
    Color? muted,
    Color? border,
    Color? shadow,
    Color? scrim,
  }) =>
      RatelPalette(
        cream: cream ?? this.cream,
        cream2: cream2 ?? this.cream2,
        cream3: cream3 ?? this.cream3,
        white: white ?? this.white,
        ink: ink ?? this.ink,
        muted: muted ?? this.muted,
        border: border ?? this.border,
        shadow: shadow ?? this.shadow,
        scrim: scrim ?? this.scrim,
      );

  @override
  RatelPalette lerp(ThemeExtension<RatelPalette>? other, double t) {
    if (other is! RatelPalette) return this;
    return RatelPalette(
      cream: Color.lerp(cream, other.cream, t)!,
      cream2: Color.lerp(cream2, other.cream2, t)!,
      cream3: Color.lerp(cream3, other.cream3, t)!,
      white: Color.lerp(white, other.white, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RatelPalette &&
      other.cream == cream &&
      other.cream2 == cream2 &&
      other.cream3 == cream3 &&
      other.white == white &&
      other.ink == ink &&
      other.muted == muted &&
      other.border == border &&
      other.shadow == shadow &&
      other.scrim == scrim;

  @override
  int get hashCode => Object.hash(
      cream, cream2, cream3, white, ink, muted, border, shadow, scrim);
}

/// Ergonomic read of the active [RatelPalette]; light fallback when no Ratel
/// theme extension is in scope (bare-pumped widgets, default ThemeData).
extension RatelPaletteX on BuildContext {
  RatelPalette get palette =>
      Theme.of(this).extension<RatelPalette>() ?? RatelPalette.light;
}
