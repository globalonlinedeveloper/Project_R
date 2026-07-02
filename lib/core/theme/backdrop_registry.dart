import 'backdrop_paint.dart';
import 'backdrops/bubbles.dart';
import 'backdrops/dust.dart';
import 'backdrops/embers.dart';
import 'backdrops/fireflies.dart';
import 'backdrops/grid.dart';
import 'backdrops/leaves.dart';
import 'backdrops/nlights.dart';
import 'backdrops/petals.dart';
import 'backdrops/rain.dart';
import 'backdrops/snow.dart';
import 'backdrops/sprinkles.dart';
import 'backdrops/sunset.dart';

/// Maps a [ThemeWorld.backdrop] id to its [BackdropPaint] painter.
///
/// Wave-1 (dust/bubbles/sprinkles/snow/petals/grid) + Wave-2
/// (fireflies/rain/leaves/nlights/embers/sunset) animated backdrops, ported
/// from the design engine. Ids not present here have no animated painter yet --
/// callers (see `WorldBackdrop`) fall back to a solid `page` fill. `none` (the
/// static `light` world) and `stars` (the existing static `StarfieldPainter`)
/// are deliberately absent.
///
/// Realizes R-WT1 (the per-theme animated backdrop layer) app-wide; the
/// reduce-motion HARD floor (R-WT5) is enforced upstream by `WorldBackdrop`.
const Map<String, BackdropPaint> kBackdropPainters = <String, BackdropPaint>{
  // Wave-1.
  'dust': paintDust,
  'bubbles': paintBubbles,
  'sprinkles': paintSprinkles,
  'snow': paintSnow,
  'petals': paintPetals,
  'grid': paintGrid,
  // Wave-2.
  'fireflies': paintFireflies,
  'rain': paintRain,
  'leaves': paintLeaves,
  'nlights': paintNlights,
  'embers': paintEmbers,
  'sunset': paintSunset,
};
