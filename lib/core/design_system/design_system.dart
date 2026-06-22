/// Ratel design system — tokens + motion + a11y + theme (Stage 2).
///
/// Built fresh ("beat Duolingo"): the old 82-screen shell is reference only.
/// Screens import this barrel and consume tokens; raw color/motion literals in
/// `lib/features` fail the R-N6 token-lint.
library;

export 'a11y/wcag.dart';
export 'context_ext.dart';
export 'motion/ratel_motion_tier.dart';
export 'theme/ratel_theme.dart';
export 'tokens/ratel_color_tokens.dart';
export 'tokens/ratel_motion.dart';
export 'tokens/ratel_spacing.dart';
export 'tokens/ratel_typography.dart';
