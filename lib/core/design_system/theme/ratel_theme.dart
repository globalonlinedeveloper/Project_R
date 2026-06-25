import 'package:flutter/material.dart';
import '../tokens/ratel_color_tokens.dart';
import '../tokens/ratel_typography.dart';
import '../world/space_palette.dart';

/// Builds Material [ThemeData] from the Ratel tokens and attaches the semantic
/// [RatelColorTokens] extension so screens read one consistent token source.
class RatelTheme {
  const RatelTheme._();

  static ThemeData light() => fromTokens(RatelColorTokens.light);
  static ThemeData dark() => fromTokens(RatelColorTokens.dark);

  /// The Space world's app-wide ThemeData (deep-space dark surfaces + mint
  /// primary). Selecting Space re-skins EVERY screen through this.
  static ThemeData space() => fromTokens(SpacePalette.tokens);

  static ThemeData fromTokens(RatelColorTokens t) {
    final scheme = ColorScheme(
      brightness: t.brightness,
      primary: t.primary,
      onPrimary: t.onPrimary,
      secondary: t.accent,
      onSecondary: t.onAccent,
      error: t.danger,
      onError: t.onDanger,
      surface: t.surface,
      onSurface: t.onSurface,
      surfaceContainerHighest: t.surfaceVariant,
      onSurfaceVariant: t.onSurfaceVariant,
      outline: t.outline,
    );

    final textTheme = const TextTheme(
      displaySmall: RatelType.display,
      headlineMedium: RatelType.headline,
      titleMedium: RatelType.title,
      bodyLarge: RatelType.body,
      bodyMedium: RatelType.body,
      labelLarge: RatelType.label,
      bodySmall: RatelType.caption,
    ).apply(bodyColor: t.onSurface, displayColor: t.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: t.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.surface,
      textTheme: textTheme,
      fontFamily: RatelType.fontFamily,
      visualDensity: VisualDensity.standard,
      extensions: <ThemeExtension<dynamic>>[t],
    );
  }
}
