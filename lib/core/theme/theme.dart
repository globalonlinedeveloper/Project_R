import 'package:flutter/material.dart';

import 'tokens.dart';

export 'tokens.dart';

/// Builds the app's [ThemeData] from [RatelColors] / [RatelType] tokens.
///
/// Material 3, warm cream scaffold, Baloo 2 for display/title/labels and
/// Nunito Sans for body. Only this lib/core/theme layer references raw tokens;
/// widgets read everything back through `Theme.of(context)` or the tokens.
abstract final class RatelTheme {
  /// The single light theme (the design is a warm light theme; a dark variant
  /// can land later as an additive token set).
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

    final TextTheme text = _textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: RatelColors.cream,
      fontFamily: RatelFont.body,
      textTheme: text,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
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

  /// Baloo 2 = display/title/button labels; Nunito Sans = body. Sizes from the
  /// spec §2 scale; ink text by default, components override per surface.
  static TextTheme _textTheme() => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.hero,
          fontWeight: RatelType.extraBold,
          color: RatelColors.ink,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: 28,
          fontWeight: RatelType.extraBold,
          color: RatelColors.ink,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.screenTitle,
          fontWeight: RatelType.extraBold,
          color: RatelColors.ink,
          height: 1.15,
        ),
        titleLarge: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: 19,
          fontWeight: RatelType.extraBold,
          color: RatelColors.ink,
        ),
        titleMedium: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.bodyLg,
          fontWeight: RatelType.semiBold,
          color: RatelColors.ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: RatelFont.body,
          fontSize: RatelType.bodyLg,
          fontWeight: RatelType.regular,
          color: RatelColors.ink,
        ),
        bodyMedium: TextStyle(
          fontFamily: RatelFont.body,
          fontSize: RatelType.body,
          fontWeight: RatelType.regular,
          color: RatelColors.ink,
        ),
        bodySmall: TextStyle(
          fontFamily: RatelFont.body,
          fontSize: RatelType.small,
          fontWeight: RatelType.regular,
          color: RatelColors.muted,
        ),
        labelLarge: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.body,
          fontWeight: RatelType.extraBold,
          color: RatelColors.ink,
        ),
        labelMedium: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.small,
          fontWeight: RatelType.semiBold,
          color: RatelColors.ink,
        ),
        /// Small-caps muted section labels — use with `.copyWith` + uppercase
        /// text (spec §2: ~10–11px, weight 700, letter-spaced, muted).
        labelSmall: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.caption,
          fontWeight: RatelType.semiBold,
          color: RatelColors.muted,
          letterSpacing: 0.8,
        ),
      );
}
