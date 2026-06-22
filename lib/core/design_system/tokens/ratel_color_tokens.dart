import 'package:flutter/material.dart';

/// Semantic color tokens (R-N6 / R-L16).
///
/// This file (and the design_system folder) is the ONLY place raw `Color(0x..)`
/// literals are allowed — the R-N6 token-lint fails the build on any raw color
/// in `lib/features`. Screens read colors via `Theme.of(context).extension<
/// RatelColorTokens>()` (see `context.tokens`). Every fg/bg pair here is WCAG
/// 2.2 AA contrast-safe by construction, asserted by the contrast test (R-K8).
@immutable
class RatelColorTokens extends ThemeExtension<RatelColorTokens> {
  const RatelColorTokens({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.success,
    required this.onSuccess,
    required this.danger,
    required this.onDanger,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color success;
  final Color onSuccess;
  final Color danger;
  final Color onDanger;

  /// Light scheme — deep teal primary, honey accent (distinct from Duolingo green).
  static const RatelColorTokens light = RatelColorTokens(
    brightness: Brightness.light,
    primary: Color(0xFF00665C),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFF2A900),
    onAccent: Color(0xFF1A1C1E),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1F4F6),
    onSurface: Color(0xFF1A1C1E),
    onSurfaceVariant: Color(0xFF44474A),
    outline: Color(0xFF6E7479),
    success: Color(0xFF1E7D34),
    onSuccess: Color(0xFFFFFFFF),
    danger: Color(0xFFC62828),
    onDanger: Color(0xFFFFFFFF),
  );

  /// Dark scheme — brighter teal for dark surfaces (OLED-friendly on cheap phones).
  static const RatelColorTokens dark = RatelColorTokens(
    brightness: Brightness.dark,
    primary: Color(0xFF4FD1C4),
    onPrimary: Color(0xFF00201C),
    accent: Color(0xFFFFC74D),
    onAccent: Color(0xFF211400),
    surface: Color(0xFF111416),
    surfaceVariant: Color(0xFF1C2023),
    onSurface: Color(0xFFE6E9EB),
    onSurfaceVariant: Color(0xFFB9BEC2),
    outline: Color(0xFF889096),
    success: Color(0xFF6FD68A),
    onSuccess: Color(0xFF00210A),
    danger: Color(0xFFFFB4AB),
    onDanger: Color(0xFF410002),
  );

  @override
  RatelColorTokens copyWith({
    Brightness? brightness,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? onAccent,
    Color? surface,
    Color? surfaceVariant,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? success,
    Color? onSuccess,
    Color? danger,
    Color? onDanger,
  }) {
    return RatelColorTokens(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
    );
  }

  @override
  RatelColorTokens lerp(ThemeExtension<RatelColorTokens>? other, double t) {
    if (other is! RatelColorTokens) return this;
    return RatelColorTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
    );
  }
}
