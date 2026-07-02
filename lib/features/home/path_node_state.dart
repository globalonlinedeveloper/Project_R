/// The four visual states a learning-path node can take, ported from the
/// authoritative design (`Ratel App.dc.html`, `nodeStatus` at HTML:3203 +
/// the orthogonal `isCp` checkpoint flag at HTML:2257).
///
/// In the design, base status is purely index-vs-active:
///   `i < activeIdx` -> done, `i === activeIdx` -> active, else -> locked.
/// A checkpoint (`isCp`, the last lesson of every 2nd unit) is an *orthogonal*
/// flag: a checkpoint that is still locked renders as an ordinary locked node
/// (`isCp: n.isCp && st !== 'lock'`, HTML:3232), and a *completed* checkpoint
/// shows the trophy rather than the check (`isDone: st==='done' && !n.isCp`).
///
/// This enum flattens that two-axis model into a single value: callers should
/// resolve a locked checkpoint to [PathNodeState.locked], and a done/active
/// checkpoint to [PathNodeState.checkpoint]. See [PathNodeData.resolveState].
enum PathNodeState {
  /// Completed, non-checkpoint lesson (teal circle + check glyph).
  done,

  /// The current lesson (teal circle + play glyph + pulsing ring).
  active,

  /// Not yet reachable (cream circle + lock glyph), OR a checkpoint that is
  /// still locked (renders as an ordinary locked node per the design).
  locked,

  /// A COMPLETED checkpoint (gold circle + trophy glyph) — the last lesson of a
  /// unit, once passed. The current node always shows as [active] (even on a
  /// checkpoint lesson); the trophy is the reward shown after completion.
  checkpoint,
}

/// A pure, immutable description of one node on the serpentine learning path.
///
/// Carries the geometry ([x], [y] on the design's 390-wide stage) plus the
/// resolved [state] and the banner metadata ([unitTitle], [unitNo]) that the
/// design's `buildPath` attaches to every node (HTML:2260).
///
/// This type holds NO providers and NO framework state — the integrating
/// screen builds a `List<PathNodeData>` from its own flattened course spine +
/// learner snapshot and hands it to the path widgets.
class PathNodeData {
  const PathNodeData({
    required this.index,
    required this.x,
    required this.y,
    required this.state,
    required this.unitTitle,
    required this.unitNo,
  });

  /// Global 0-based node index along the whole path (matches design `idx`).
  final int index;

  /// Horizontal centre on the design's 390px stage (lane 130/260 + wobble).
  final double x;

  /// Vertical centre on the stage (accumulated with 90 / 108-into-checkpoint
  /// spacing plus per-section gaps).
  final double y;

  /// Resolved visual state (checkpoint already folded in — see
  /// [resolveState]).
  final PathNodeState state;

  /// Named unit this node belongs to (e.g. "At the market"), for the banner.
  final String unitTitle;

  /// 1-based unit number within the course (matches design `unitNo`).
  final int unitNo;

  /// True when this node reads as a checkpoint (done/active checkpoint).
  bool get isCheckpoint => state == PathNodeState.checkpoint;

  /// True when this node is the current/active node (checkpoint or not).
  bool get isActive => state == PathNodeState.active;

  /// True when this node is completed (checkpoint or ordinary done node).
  bool get isDone =>
      state == PathNodeState.done || state == PathNodeState.checkpoint;

  /// Resolves the design's two-axis model into a single [PathNodeState].
  ///
  /// [index] vs [activeIndex] gives the base status; [isCheckpointFlag] is the
  /// orthogonal `isCp`. A COMPLETED checkpoint (index < activeIndex) becomes
  /// [PathNodeState.checkpoint] (gold trophy); the current node is always
  /// [PathNodeState.active]; later nodes are [PathNodeState.locked] (a locked
  /// checkpoint is just locked, matching `isCp: n.isCp && st!=='lock'`).
  static PathNodeState resolveState({
    required int index,
    required int activeIndex,
    required bool isCheckpointFlag,
  }) {
    if (index < activeIndex) {
      return isCheckpointFlag ? PathNodeState.checkpoint : PathNodeState.done;
    }
    if (index == activeIndex) {
      // The current node always renders as the actionable "active" node (teal
      // play + badger traveller), even when it is a checkpoint lesson — the gold
      // trophy is the reward shown once the checkpoint is COMPLETED
      // (index < activeIndex).
      return PathNodeState.active;
    }
    // index > activeIndex -> locked (a locked checkpoint is just locked).
    return PathNodeState.locked;
  }

  PathNodeData copyWith({
    int? index,
    double? x,
    double? y,
    PathNodeState? state,
    String? unitTitle,
    int? unitNo,
  }) {
    return PathNodeData(
      index: index ?? this.index,
      x: x ?? this.x,
      y: y ?? this.y,
      state: state ?? this.state,
      unitTitle: unitTitle ?? this.unitTitle,
      unitNo: unitNo ?? this.unitNo,
    );
  }
}
