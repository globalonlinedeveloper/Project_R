import 'package:flutter/widgets.dart';

/// Type-scale tokens. Uses the platform default font (no bundled font = leaner
/// download for the cheap-phone beachhead, R-N1/R-N5). Sizes scale with the
/// OS text-scale factor (R-K8) because screens render through normal Text.
@immutable
class RatelType {
  const RatelType._();

  static const String? fontFamily = null; // platform default (Roboto / SF)

  static const TextStyle display =
      TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static const TextStyle headline =
      TextStyle(fontSize: 24, height: 1.2, fontWeight: FontWeight.w700);
  static const TextStyle title =
      TextStyle(fontSize: 18, height: 1.25, fontWeight: FontWeight.w600);
  static const TextStyle body =
      TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w400);
  static const TextStyle bodyStrong =
      TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600);
  static const TextStyle label =
      TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w600);
  static const TextStyle caption =
      TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w500);
}
