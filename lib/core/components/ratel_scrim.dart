import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Shared "chrome scrim" floor (INC-10 FU-2).
///
/// Backdrop worlds paint their animated field app-wide and make the chrome
/// surfaces translucent so the field tints through (e.g. Ocean `surface`
/// alpha ~= 0.70, the progress-track `surface2` ~= 0.08, `border` ~= 0.13).
/// Muted text and — most visibly — "empty" progress tracks then lose contrast
/// over the moving field. This widget lays the palette's shared
/// [RatelPalette.scrim] token BENEATH [child] (clipped to [radius]) to restore
/// a consistent contrast floor.
///
/// It is ONE shared definition — never a per-widget raw color — and a no-op on
/// opaque (Daylight) surfaces: callers pass [active] the translucency test of
/// the surface they are backing (`context.palette.white.a < 1`), so when that
/// surface is already opaque the scrim is skipped and [child] renders verbatim.
class RatelScrim extends StatelessWidget {
  const RatelScrim({
    super.key,
    required this.active,
    required this.child,
    this.radius = 0,
  });

  /// Whether to paint the scrim floor. Callers pass the translucency test of the
  /// surface being backed (opaque surface -> `false` -> no-op).
  final bool active;

  /// Corner radius of the scrim floor; matches the backed surface.
  final double radius;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.palette.scrim,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
