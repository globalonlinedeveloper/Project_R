import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Signature for a per-theme animated backdrop painter.
///
/// Ported from the authoritative design engine (`Ratel App.dc.html`,
/// `drawSky()` dispatch, L2985-3107): one `drawX(ctx,w,h,t)` method per
/// backdrop `kind`. Here each painter is a top-level `void` function.
///
/// * [canvas] / [size] — the full-bleed backdrop canvas (drawn behind the app).
/// * [p] — the active world palette (see [WorldPalette]); painters PREFER
///   palette colors (`p.accent`, `p.muted`, `p.gold`, …) and use raw literals
///   only where the design demands a specific tint (white snow, etc.).
/// * [t] — the animation phase in `[0, 1)` (one full loop per controller
///   period). Painters must derive ALL motion from [t] (wrap particle
///   positions by it) and be otherwise deterministic — particle positions are
///   seeded by index, never by RNG — so a frame is a pure function of
///   `(size, p, t)`. That makes them repaint-clean and test-safe, and lets the
///   reduce-motion floor paint a single static frame at `t = 0`.
typedef BackdropPaint = void Function(
  Canvas canvas,
  Size size,
  WorldPalette p,
  double t,
);
