import 'package:flutter/material.dart';
import 'motion/ratel_motion_tier.dart';
import 'tokens/ratel_color_tokens.dart';

/// Ergonomic accessors used across screens.
extension RatelContextX on BuildContext {
  /// Semantic color tokens for the active theme (falls back to light).
  RatelColorTokens get tokens =>
      Theme.of(this).extension<RatelColorTokens>() ?? RatelColorTokens.light;

  /// Resolved motion tier (R-N7) — OS reduce-motion is a hard floor.
  MotionTier get motionTier => motionTierOf(this);
}
