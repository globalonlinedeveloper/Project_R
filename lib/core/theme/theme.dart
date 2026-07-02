import 'package:flutter/material.dart';

import 'palette.dart';
import 'tokens.dart';
import 'world_theme.dart';

export 'palette.dart';
export 'tokens.dart';
export 'starfield.dart';
export 'world_theme.dart';
export 'world_registry.dart';

/// Builds the app's [ThemeData] from [RatelColors] / [RatelType] tokens.
///
/// Material 3, warm cream scaffold in light, warm charcoal in dark; Baloo 2 for
/// display/title/labels and Nunito Sans for body. Only this lib/core/theme layer
/// references raw tokens; widgets read everything back through
/// `Theme.of(context)`, the [RatelColors] accent tokens, or `context.palette`
/// for the theme-aware neutrals.
abstract final class RatelTheme {
  /// The warm LIGHT theme (the original design). Neutrals come from
  /// [RatelPalette.light]; values are unchanged from prior releases (§11).
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: RatelColors.teal,
      brightness: Brightness.light,
    ).copyWith(
      primary: RatelColors.teal,
      onPrimary: RatelColors.onColor,
      secondary: RatelColors.amber,
      onSecondary: RatelColors.onColor,
      tertiary: RatelColors.green,
      onTertiary: RatelColors.onColor,
      error: RatelColors.coral,
      onError: RatelColors.onColor,
      surface: RatelColors.white,
      onSurface: RatelColors.ink,
      onSurfaceVariant: RatelColors.muted,
      outline: RatelColors.border,
      outlineVariant: RatelColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: RatelColors.cream,
      fontFamily: RatelFont.body,
      textTheme: _textTheme(ink: RatelColors.ink, muted: RatelColors.muted),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      extensions: const <ThemeExtension<dynamic>>[RatelPalette.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: RatelColors.cream,
        foregroundColor: RatelColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: RatelColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// The warm DARK theme (S53). Brand accents are identical to light; only the
  /// neutrals flip, via [RatelPalette.dark] + a dark [ColorScheme] + a dark
  /// scaffold, app-bar and ink text. R-WT3 (persisted theme selection) / R-WT6
  /// (settings appearance surface).
  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: RatelColors.teal,
      brightness: Brightness.dark,
    ).copyWith(
      primary: RatelColors.teal,
      onPrimary: RatelColors.onColor,
      secondary: RatelColors.amber,
      onSecondary: RatelColors.onColor,
      tertiary: RatelColors.green,
      onTertiary: RatelColors.onColor,
      error: RatelColors.coral,
      onError: RatelColors.onColor,
      surface: RatelColors.darkSurface,
      onSurface: RatelColors.darkInk,
      onSurfaceVariant: RatelColors.darkMuted,
      outline: RatelColors.darkBorder,
      outlineVariant: RatelColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: RatelColors.darkBg,
      fontFamily: RatelFont.body,
      textTheme: _textTheme(ink: RatelColors.darkInk, muted: RatelColors.darkMuted),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      extensions: const <ThemeExtension<dynamic>>[RatelPalette.dark],
      appBarTheme: const AppBarTheme(
        backgroundColor: RatelColors.darkBg,
        foregroundColor: RatelColors.darkInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: RatelColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// The SPACE world-theme (R-WT2, S66 · G1) — a deep-space re-skin applied
  /// app-wide regardless of light/dark. A dark [ColorScheme] + the space
  /// [RatelPalette]; the scaffold + app-bar are TRANSLUCENT so the app-wide
  /// starfield (painted behind in `RatelApp`) shows through. Brand accents are
  /// unchanged.
  static ThemeData space() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: RatelColors.teal,
      brightness: Brightness.dark,
    ).copyWith(
      primary: RatelColors.teal,
      onPrimary: RatelColors.onColor,
      secondary: RatelColors.amber,
      onSecondary: RatelColors.onColor,
      tertiary: RatelColors.green,
      onTertiary: RatelColors.onColor,
      error: RatelColors.coral,
      onError: RatelColors.onColor,
      surface: RatelColors.spaceSurface,
      onSurface: RatelColors.spaceInk,
      onSurfaceVariant: RatelColors.spaceMuted,
      outline: RatelColors.spaceBorder,
      outlineVariant: RatelColors.spaceBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: RatelColors.spaceBg,
      fontFamily: RatelFont.body,
      textTheme: _textTheme(ink: RatelColors.spaceInk, muted: RatelColors.spaceMuted),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      extensions: const <ThemeExtension<dynamic>>[RatelPalette.space],
      appBarTheme: const AppBarTheme(
        backgroundColor: RatelColors.spaceBg,
        foregroundColor: RatelColors.spaceInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: RatelColors.spaceBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Any of the 29 non-shipped design worlds: a full [ThemeData] built from the
  /// world's ported 15-token palette (neutrals + per-world accents). light/space
  /// keep their hand-tuned [light]/[space] builders; this serves the rest.
  /// Backdrop painters are a later increment — the opaque `bg` scaffold renders
  /// the world correctly now.
  static ThemeData world(ThemeWorld w) {
    final WorldPalette wp = w.palette;
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: wp.accent,
      brightness: w.isDark ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: wp.accent,
      onPrimary: RatelColors.onColor,
      secondary: wp.gold,
      onSecondary: RatelColors.onColor,
      tertiary: wp.good,
      onTertiary: RatelColors.onColor,
      error: wp.bad,
      onError: RatelColors.onColor,
      surface: wp.surface,
      onSurface: wp.text,
      onSurfaceVariant: wp.muted,
      outline: wp.border,
      outlineVariant: wp.border,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: wp.bg,
      fontFamily: RatelFont.body,
      textTheme: _textTheme(ink: wp.text, muted: wp.muted),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      extensions: <ThemeExtension<dynamic>>[RatelPalette.fromWorld(w)],
      appBarTheme: AppBarTheme(
        backgroundColor: wp.bg,
        foregroundColor: wp.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: wp.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Baloo 2 = display/title/button labels; Nunito Sans = body. Sizes from the
  /// spec §2 scale; [ink]/[muted] are theme-dependent so the same scale serves
  /// both light and dark. Components override colour per surface as needed.
  static TextTheme _textTheme({required Color ink, required Color muted}) =>
      TextTheme(
        displayLarge: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.hero,
          fontWeight: RatelType.extraBold,
          color: ink,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: 28,
          fontWeight: RatelType.extraBold,
          color: ink,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.screenTitle,
          fontWeight: RatelType.extraBold,
          color: ink,
          height: 1.15,
        ),
        titleLarge: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: 19,
          fontWeight: RatelType.extraBold,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.bodyLg,
          fontWeight: RatelType.semiBold,
          color: ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: RatelFont.body,
          fontSize: RatelType.bodyLg,
          fontWeight: RatelType.regular,
          color: ink,
        ),
        bodyMedium: TextStyle(
          fontFamily: RatelFont.body,
          fontSize: RatelType.body,
          fontWeight: RatelType.regular,
          color: ink,
        ),
        bodySmall: TextStyle(
          fontFamily: RatelFont.body,
          fontSize: RatelType.small,
          fontWeight: RatelType.regular,
          color: muted,
        ),
        labelLarge: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.body,
          fontWeight: RatelType.extraBold,
          color: ink,
        ),
        labelMedium: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.small,
          fontWeight: RatelType.semiBold,
          color: ink,
        ),
        labelSmall: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.caption,
          fontWeight: RatelType.semiBold,
          color: muted,
          letterSpacing: 0.8,
        ),
      );
}
