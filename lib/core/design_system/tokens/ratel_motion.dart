import 'package:flutter/widgets.dart';

/// Motion tokens (R-L16): the single source of durations + curves. The R-N6
/// token-lint fails the build on a raw `Duration`/`Curve` literal in a screen
/// file — motion comes from here exactly as colors come from the color tokens.
/// All motion must additionally honor the resolved [MotionTier] (R-N7).
@immutable
class RatelMotion {
  const RatelMotion._();

  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);
  static const Duration celebrate = Duration(milliseconds: 700);

  /// Real-time clock tick (energy countdown refresh) — sourced here so screen
  /// code never writes a raw Duration literal (R-N6 token-lint).
  static const Duration secondTick = Duration(seconds: 1);

  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;

  // Named, intent-revealing aliases used by the widget kit.
  static const Duration press = fast;
  static const Duration pageTransition = normal;
  static const Duration crossFade = normal;
}
