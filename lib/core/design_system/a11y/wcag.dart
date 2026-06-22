import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// WCAG 2.1/2.2 relative luminance + contrast ratio (R-K8). Pure functions —
/// used by the design-system contrast tests and any runtime a11y assertion.
double _linearize(double channel) {
  return channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

/// Relative luminance of [color] (0..1). Uses the Flutter 3.27+ float channels.
double relativeLuminance(Color color) {
  return 0.2126 * _linearize(color.r) +
      0.7152 * _linearize(color.g) +
      0.0722 * _linearize(color.b);
}

/// WCAG contrast ratio between two colors (1..21).
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// WCAG 2.2 AA thresholds.
const double kAaNormalText = 4.5;
const double kAaLargeTextOrUi = 3.0;
