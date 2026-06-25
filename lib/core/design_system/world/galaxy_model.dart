import 'dart:math' as math;

/// Bit-exact `mulberry32` PRNG — reproduces the approved `galaxy_home_v9.html`
/// stream EXACTLY (verified by a golden test against the prototype's Node
/// output). The planet layout + per-section palettes derive from this, so any
/// divergence would shift every planet/hue; 32-bit ops are masked accordingly.
class Mulberry32 {
  Mulberry32(int seed) : _a = seed & 0xFFFFFFFF;
  int _a;

  double next() {
    _a = (_a + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _a;
    t = _imul(t ^ (t >>> 15), 1 | t) & 0xFFFFFFFF;
    t = ((t + _imul(t ^ (t >>> 7), 61 | t)) ^ t) & 0xFFFFFFFF;
    t = (t ^ (t >>> 14)) & 0xFFFFFFFF;
    return t / 4294967296.0;
  }

  /// 32-bit signed multiply (`Math.imul`) via 16-bit split — avoids 64-bit
  /// overflow while keeping the low 32 bits identical to JS.
  static int _imul(int a, int b) {
    a &= 0xFFFFFFFF;
    b &= 0xFFFFFFFF;
    final aLo = a & 0xFFFF;
    final bLo = b & 0xFFFF;
    final aHi = a >>> 16;
    final bHi = b >>> 16;
    return ((aLo * bLo) + (((aHi * bLo + aLo * bHi) & 0xFFFFFFFF) << 16)) &
        0xFFFFFFFF;
  }
}

/// Golden-angle hue for section [i] (137.508° step, +208° phase), matching the
/// prototype's per-section non-repeating palette. Section sky/nebula/flame all
/// derive from this; individual planet hues are independent (see [GalaxyPlanet]).
double goldenHue(int i) => (i * 137.508 + 208) % 360;

enum PlanetArch { smooth, banded, icy }

/// One lesson node on the path. [x]/[y] are in the prototype's 344-wide content
/// space (centre/scale for 360px — never re-clamp; spec §17). [isCheckpoint] is
/// the last lesson of a unit (gold crown). [hue] is the planet's own surface hue.
class GalaxyPlanet {
  const GalaxyPlanet({
    required this.x,
    required this.y,
    required this.section,
    required this.ui,
    required this.isCheckpoint,
    required this.hue,
    required this.arch,
    required this.ring,
    required this.moon,
    required this.lessonNo,
    required this.lessons,
    required this.unitTitle,
  });

  final double x;
  final double y;
  final int section;
  final int ui;
  final bool isCheckpoint;
  final int hue;
  final PlanetArch arch;
  final bool ring;
  final bool moon;
  final int lessonNo;
  final int lessons;
  final String unitTitle;
}

class GalaxyBand {
  const GalaxyBand(this.section, this.y, this.name);
  final int section;
  final double y;
  final String name;
}

class GalaxyUnit {
  const GalaxyUnit({
    required this.ui,
    required this.y,
    required this.title,
    required this.section,
  });
  final int ui;
  final double y;
  final String title;
  final int section;
}

class GalaxyLayout {
  const GalaxyLayout({
    required this.planets,
    required this.bands,
    required this.units,
    required this.total,
  });
  final List<GalaxyPlanet> planets;
  final List<GalaxyBand> bands;
  final List<GalaxyUnit> units;
  final double total;
  int get count => planets.length;
}

const List<String> kSectionNames = <String>[
  'NEBULA REACH',
  'CRIMSON DRIFT',
  'AURORA EXPANSE',
  'VIOLET VOID',
  'EMBER BELT',
  'GLACIER RIFT',
];
const List<String> kUnitTitles = <String>[
  'Greetings',
  'Ordering food',
  'At the market',
  'Directions',
  'Small talk',
  'Travel plans',
  'Making friends',
  'Daily routine',
  'Weather talk',
  'Shopping',
];

/// Generates the galaxy layout — VERBATIM draw order from the prototype (spec
/// §3). Deterministic: per-section seed is `mulberry32(1000 + s*97)` and the
/// per-lesson r() consumption order (jitter → arch → hue → ring? → moon) and
/// short-circuits (`ring` skips r() on a checkpoint; `moon` always draws r())
/// are preserved so the Flutter layout is identical to the approved design.
GalaxyLayout generateGalaxy({int sections = 3}) {
  const double headroomSec = 52, headroomUnit = 50, startClear = 26, row = 78;
  var y = 18.0;
  var ui = 0;
  var unitTitleIdx = 0;
  final bands = <GalaxyBand>[];
  final planets = <GalaxyPlanet>[];
  final units = <GalaxyUnit>[];

  for (var s = 0; s < sections; s++) {
    bands.add(GalaxyBand(s, y, kSectionNames[s % 6]));
    y += headroomSec;
    final r = Mulberry32(1000 + s * 97);
    final unitsN = 2 + (r.next() * 2).floor();
    for (var u = 0; u < unitsN; u++) {
      final utitle = kUnitTitles[unitTitleIdx++ % 10];
      final lessons = 3 + (r.next() * 3).floor();
      units.add(GalaxyUnit(ui: ui, y: y, title: utitle, section: s));
      y += headroomUnit + startClear;
      for (var l = 0; l < lessons; l++) {
        final last = l == lessons - 1;
        final leftLane = l % 2 == 0;
        final jitter = r.next() * 38 - 19;
        var x = (leftLane ? 92.0 : 252.0) + jitter;
        x = math.max(66.0, math.min(278.0, x));
        final av = r.next();
        final arch = av < 0.5
            ? PlanetArch.smooth
            : (av < 0.8 ? PlanetArch.banded : PlanetArch.icy);
        final hue = (r.next() * 360).floor();
        final ring = !last && r.next() < 0.24;
        final moon = r.next() < 0.32 && !last;
        planets.add(GalaxyPlanet(
          x: x,
          y: y + 34,
          section: s,
          ui: ui,
          isCheckpoint: last,
          hue: hue,
          arch: arch,
          ring: ring,
          moon: moon,
          lessonNo: l + 1,
          lessons: lessons,
          unitTitle: utitle,
        ));
        y += row;
      }
      ui++;
      y += 6;
    }
    y += 14;
  }
  return GalaxyLayout(planets: planets, bands: bands, units: units, total: y + 30);
}
// Traceability: R-WT4
