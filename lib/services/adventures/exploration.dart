/// Pure, clockless adventure-exploration arithmetic (L-4 — design §4.12
/// "districts + explored progress", screen-review B-10).
///
/// The real course content authors adventures per CEFR band (2 per band on
/// the shipped courses), so the honest "district" projection groups by CEFR
/// band — the design mock's named districts (Café & Food …) were sample data
/// with no counterpart in the authored `scenario` table (owner-confirmed
/// mapping, S131). Like the other `lib/services` engines this holds no clock,
/// no I/O and no UI types: callers pass lightweight refs plus the explored-id
/// set and receive the projected district list.
library;

/// A minimal reference to one authored adventure — its stable content id plus
/// the CEFR band it belongs to. Deliberately NOT the feature-layer
/// `CourseScenario` so the engine stays UI-free (services never import
/// features).
class AdventureRef {
  const AdventureRef({required this.id, required this.band});

  /// Content `scenario_id` — the stable identifier explored-state keys on.
  final String id;

  /// CEFR band code ('A1'…'C2') — the district key.
  final String band;

  @override
  bool operator ==(Object other) =>
      other is AdventureRef && other.id == id && other.band == band;

  @override
  int get hashCode => Object.hash(id, band);
}

/// One projected district: a CEFR band, its adventures (data order), and the
/// explored progress the design's district header renders (`n/m explored`,
/// ✓ Done pill, current-district mascot).
class AdventureDistrict {
  const AdventureDistrict({
    required this.band,
    required this.refs,
    required this.doneCount,
    required this.allDone,
    required this.isCurrent,
  });

  final String band;
  final List<AdventureRef> refs;

  /// How many of [refs] are explored.
  final int doneCount;

  /// Every adventure in the district is explored (design "✓ Done" pill).
  final bool allDone;

  /// The FIRST district (band order) that still has unexplored scenes — the
  /// design marks it with the bobbing mascot. Mirrors the mock's
  /// `advFirstOpen && !allDone` walk; false everywhere once all are done.
  final bool isCurrent;

  /// The design header's progress line numerator/denominator.
  int get total => refs.length;
}

/// Projects adventures + the explored-id set into district cards.
class AdventureExplorationEngine {
  const AdventureExplorationEngine();

  /// Whether marking [id] explored would be a FIRST exploration — the
  /// once-per-adventure reward crossing (design: reward only when
  /// `!advDone[id]`).
  bool isNewlyExplored(Set<String> explored, String id) =>
      !explored.contains(id);

  /// Group [refs] by CEFR band (bands sorted ascending — A1…C2 — matching the
  /// current screen's level sort; refs keep data order within a band) and
  /// attach explored progress. Unknown/empty input projects to an empty list —
  /// a course with no adventures keeps its honest empty state.
  List<AdventureDistrict> districts(
      List<AdventureRef> refs, Set<String> explored) {
    final List<String> bands = <String>[];
    final Map<String, List<AdventureRef>> byBand =
        <String, List<AdventureRef>>{};
    for (final AdventureRef r in refs) {
      (byBand[r.band] ??= <AdventureRef>[]).add(r);
      if (!bands.contains(r.band)) bands.add(r.band);
    }
    bands.sort();
    bool firstOpen = true;
    final List<AdventureDistrict> out = <AdventureDistrict>[];
    for (final String band in bands) {
      final List<AdventureRef> group = byBand[band]!;
      int done = 0;
      for (final AdventureRef r in group) {
        if (explored.contains(r.id)) done += 1;
      }
      final bool allDone = done == group.length;
      final bool isCurrent = firstOpen && !allDone;
      if (isCurrent) firstOpen = false;
      out.add(AdventureDistrict(
        band: band,
        refs: List<AdventureRef>.unmodifiable(group),
        doneCount: done,
        allDone: allDone,
        isCurrent: isCurrent,
      ));
    }
    return out;
  }
}
