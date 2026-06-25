/// Ratel design system — tokens + motion + a11y + theme + widget kit (Stage 2).
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
export 'widgets/ratel_button.dart';
export 'widgets/ratel_card.dart';
export 'widgets/ratel_celebration.dart';
export 'widgets/ratel_count_up.dart';
export 'widgets/ratel_fade_through.dart';
export 'widgets/ratel_progress_ring.dart';
export 'widgets/ratel_screen.dart';
export 'world/app_settings.dart';
export 'world/pod_painter.dart';
export 'world/space_backdrop.dart';
export 'world/space_palette.dart';
export 'world/world_theme.dart';
export 'world/galaxy_model.dart';
export 'world/galaxy_painter.dart';
export 'world/galaxy_view.dart';
export 'world/space_hud.dart';
export 'world/galaxy_fx.dart';
