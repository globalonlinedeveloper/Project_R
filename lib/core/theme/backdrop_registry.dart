import 'backdrop_paint.dart';
import 'backdrops/abyss.dart';
import 'backdrops/bamboo.dart';
import 'backdrops/beach.dart';
import 'backdrops/bubbles.dart';
import 'backdrops/cyberrain.dart';
import 'backdrops/dawn.dart';
import 'backdrops/dunes.dart';
import 'backdrops/dust.dart';
import 'backdrops/embers.dart';
import 'backdrops/fireflies.dart';
import 'backdrops/grid.dart';
import 'backdrops/jungle.dart';
import 'backdrops/lagoon.dart';
import 'backdrops/lavender.dart';
import 'backdrops/leaves.dart';
import 'backdrops/meadow.dart';
import 'backdrops/nebula.dart';
import 'backdrops/nlights.dart';
import 'backdrops/petals.dart';
import 'backdrops/rain.dart';
import 'backdrops/reef.dart';
import 'backdrops/sandstorm.dart';
import 'backdrops/snow.dart';
import 'backdrops/sprinkles.dart';
import 'backdrops/sunset.dart';
import 'backdrops/thunder.dart';

/// Maps a [ThemeWorld.backdrop] id to its [BackdropPaint] painter.
///
/// Wave-1 (dust/bubbles/sprinkles/snow/petals/grid) + Wave-2
/// (fireflies/rain/leaves/nlights/embers/sunset) + Wave-3 richer moderate
/// scenes (dunes/meadow/dawn/beach/lavender) + Wave-3B (reef/lagoon/sandstorm) +
/// Wave-4a (cyberrain/bamboo/nebula) + Wave-4b (jungle/abyss/thunder) animated backdrops, ported from the design engine. Ids not present here have
/// no animated painter yet -- callers (see `WorldBackdrop`) fall back to a solid
/// `page` fill. `none` (the static `light` world) and `stars` (the existing
/// static `StarfieldPainter`) are deliberately absent.
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
  // Wave-3 (richer moderate scenes).
  'dunes': paintDunes,
  'meadow': paintMeadow,
  'dawn': paintDawn,
  'beach': paintBeach,
  'lavender': paintLavender,
  // Wave-3B.
  'reef': paintReef,
  'lagoon': paintLagoon,
  'sandstorm': paintSandstorm,
  // Wave-4a (complex set, batch 1).
  'cyberrain': paintCyberRain,
  'bamboo': paintBamboo,
  'nebula': paintNebula,
  // Wave-4b (complex set, batch 2).
  'jungle': paintJungle,
  'abyss': paintAbyss,
  'thunder': paintThunder,
};
