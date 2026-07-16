/// Pure, clockless adventure-exploration arithmetic (L-4 — design §4.12
/// "districts + explored progress", screen-review B-10).
///
/// The owner's locked Adventures taxonomy (S153) is four NAMED districts —
/// **Café & Food / Market Square / On the Move / Making Friends** — in that
/// fixed order (superseding the old S131 "sample-data / group-by-CEFR-band"
/// note: fresh owner screenshots #29/#30 show the named places, so the named
/// districts win). Adventure content carries NO district field — only `world`
/// free-text (e.g. "a small café in town", "a colourful outdoor market", "a
/// busy street in a new city", "a quiet bus stop"). So the district is DERIVED
/// deterministically from that real authored signal by the feature layer (see
/// `adventures_screen.dart` `districtOf`) and handed to this engine as an
/// already-resolved [AdventureDistrictKind] on each [AdventureRef]. Nothing is
/// fabricated and no content is re-authored — the honest derive-don't-fabricate
/// pattern INC-4 established for roleplay categories.
///
/// Like the other `lib/services` engines this holds no clock, no I/O and no UI
/// types: callers pass lightweight refs plus the explored-id set and receive
/// the projected district list.
library;

/// The owner's four NAMED Adventures districts (S153), in FIXED render order.
/// Stable [id] strings key the design [ValueKey]s (`adventure-district-cafe`
/// …) and never change with content or locale. [cafe] is also the DEFAULT for
/// any scenario whose real text matches none of the other three (we keep to
/// the four owner-locked districts and never invent a fifth).
enum AdventureDistrictKind {
  cafe('cafe'),
  market('market'),
  move('move'),
  friends('friends');

  const AdventureDistrictKind(this.id);

  /// Stable district id — the [ValueKey] / progress-key suffix.
  final String id;
}

/// FIXED render order for the district cards (design #29/#30 top-to-bottom:
/// Café & Food · Market Square · On the Move · Making Friends). Only districts
/// that actually contain scenarios are rendered (empty districts stay hidden —
/// honest, content-gated).
const List<AdventureDistrictKind> kAdventureDistrictOrder =
    <AdventureDistrictKind>[
  AdventureDistrictKind.cafe,
  AdventureDistrictKind.market,
  AdventureDistrictKind.move,
  AdventureDistrictKind.friends,
];

/// A minimal reference to one authored adventure — its stable content id plus
/// the NAMED district it was derived into. Deliberately NOT the feature-layer
/// `CourseScenario` so the engine stays UI-free (services never import
/// features); the feature derives [kind] from the scenario's real text before
/// constructing the ref.
class AdventureRef {
  const AdventureRef({required this.id, required this.kind});

  /// Content `scenario_id` — the stable identifier explored-state keys on.
  final String id;

  /// The named district this adventure belongs to (derived, deterministic).
  final AdventureDistrictKind kind;

  @override
  bool operator ==(Object other) =>
      other is AdventureRef && other.id == id && other.kind == kind;

  @override
  int get hashCode => Object.hash(id, kind);
}

/// One projected district: its NAMED [kind], its adventures (data order), and
/// the explored progress the design's district header renders (`n/m explored`,
/// ✓ Done pill, current-district mascot).
class AdventureDistrict {
  const AdventureDistrict({
    required this.kind,
    required this.refs,
    required this.doneCount,
    required this.allDone,
    required this.isCurrent,
  });

  /// The named district identity (was the CEFR `band` pre-S153).
  final AdventureDistrictKind kind;

  /// Stable district id (`'cafe'`…) — the [ValueKey] suffix on the screen.
  String get id => kind.id;

  final List<AdventureRef> refs;

  /// How many of [refs] are explored.
  final int doneCount;

  /// Every adventure in the district is explored (design "✓ Done" pill).
  final bool allDone;

  /// The FIRST district (fixed order) that still has unexplored scenes — the
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

  /// Group [refs] by NAMED district and attach explored progress. Districts
  /// are emitted in [kAdventureDistrictOrder] (Café & Food … Making Friends);
  /// refs keep data order within a district. A district with no (derived)
  /// scenarios is omitted (honest empty projection — a course with no
  /// adventures projects to an empty list, keeping its honest empty state).
  List<AdventureDistrict> districts(
      List<AdventureRef> refs, Set<String> explored) {
    final Map<AdventureDistrictKind, List<AdventureRef>> byKind =
        <AdventureDistrictKind, List<AdventureRef>>{};
    for (final AdventureRef r in refs) {
      (byKind[r.kind] ??= <AdventureRef>[]).add(r);
    }
    bool firstOpen = true;
    final List<AdventureDistrict> out = <AdventureDistrict>[];
    for (final AdventureDistrictKind kind in kAdventureDistrictOrder) {
      final List<AdventureRef>? group = byKind[kind];
      if (group == null || group.isEmpty) continue; // hide empty district
      int done = 0;
      for (final AdventureRef r in group) {
        if (explored.contains(r.id)) done += 1;
      }
      final bool allDone = done == group.length;
      final bool isCurrent = firstOpen && !allDone;
      if (isCurrent) firstOpen = false;
      out.add(AdventureDistrict(
        kind: kind,
        refs: List<AdventureRef>.unmodifiable(group),
        doneCount: done,
        allDone: allDone,
        isCurrent: isCurrent,
      ));
    }
    return out;
  }
}
