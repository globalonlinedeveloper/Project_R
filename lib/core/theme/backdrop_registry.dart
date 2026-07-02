import 'backdrop_paint.dart';
import 'backdrops/bubbles.dart';
import 'backdrops/dust.dart';
import 'backdrops/grid.dart';
import 'backdrops/petals.dart';
import 'backdrops/snow.dart';
import 'backdrops/sprinkles.dart';

/// Maps a [ThemeWorld.backdrop] id to its [BackdropPaint] painter.
///
/// This is the first batch (Wave-1) of animated backdrops, ported from the
/// design engine. Ids not present here have no animated painter yet — callers
/// (see `WorldBackdrop`) fall back to a solid `page` fill. `none` (the static
/// `light` world) and `stars` (the existing static `StarfieldPainter`) are
/// deliberately absent.
const Map<String, BackdropPaint> kBackdropPainters = <String, BackdropPaint>{
  'dust': paintDust,
  'bubbles': paintBubbles,
  'sprinkles': paintSprinkles,
  'snow': paintSnow,
  'petals': paintPetals,
  'grid': paintGrid,
};
