import 'package:flutter/widgets.dart';

/// Spacing, radius and sizing tokens. Screens use these instead of magic numbers.
@immutable
class RatelSpacing {
  const RatelSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
  static const double radiusPill = 999;

  /// WCAG 2.2 AA target size (2.5.8) — minimum interactive target (R-K8).
  static const double minTapTarget = 48;

  static const double gutter = 16;

  /// Beachhead = cheap phones; content centers within this on wide screens.
  static const double maxContentWidth = 520;
}
