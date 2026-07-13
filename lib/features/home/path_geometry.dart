import 'dart:math' as math;

import 'package:ratel/features/learning_path/course_spine.dart';

import 'path_node_state.dart';

/// A section-divider row derived by [computePathGeometry] — the label plus its
/// vertical centre on the stage.
class PathDivider {
  const PathDivider({required this.label, required this.y});

  /// Full label text (the authored unit `section`, e.g. "SECTION 1 · LEVEL A1").
  final String label;

  /// Vertical centre of the divider row on the stage.
  final double y;
}

/// The laid-out learning path: absolutely-positioned nodes, section dividers,
/// and the total stage height. A faithful port of the design's `buildPath`
/// math (SPEC_HOME_PATH §A3, `Ratel App.dc.html`:2245-2270) onto the REAL
/// course spine — a single source of truth so the trail, nodes and traveller
/// all agree on coordinates.
class PathGeometry {
  const PathGeometry({
    required this.nodes,
    required this.dividers,
    required this.contentHeight,
  });

  final List<PathNodeData> nodes;
  final List<PathDivider> dividers;
  final double contentHeight;
}

// --- design constants (SPEC_HOME_PATH §A3 / Ratel App.dc.html buildPath) ---
const double _kStartY = 46; // start y (HTML:2249)
const double _kLaneLeft = 130; // left lane centre (HTML:2255)
const double _kLaneRight = 260; // right lane centre
const double _kWobbleAmp = 14; // sin wobble amplitude ±14px (HTML:2257)
const double _kWobbleFreq = 0.95; // sin phase per node
const double _kDy = 90; // vertical spacing between nodes (HTML:2259)
const double _kDyIntoCheckpoint = 108; // spacing out of a checkpoint node
const double _kDividerGap = 58; // gap after a section divider (HTML:2251)
const double _kUnitGap = 22; // gap after each unit/section (HTML:2263)
const double _kTailPadding = 130; // contentH = y + 130 (HTML:2267)

/// The design stage width the lane centres are authored against (HTML:3495).
const double kPathStageWidth = 390;

/// Ports the design's `buildPath` onto the REAL [spine]: walks each
/// [CourseUnit] in order, emitting a section divider then its lesson nodes on
/// alternating lanes (130 / 260) with a per-node sin wobble, advancing y by 90
/// (108 out of a checkpoint). The LAST lesson of each unit is a checkpoint
/// (owner rule, S79) — surfaced as [PathNodeState.checkpoint] once reached, an
/// ordinary locked node until then.
///
/// [activeIndex] is the learner's real `lessonsCompleted`; every node's state
/// is derived purely from index-vs-active plus the checkpoint flag (see
/// [PathNodeData.resolveState]). No fabricated positions or states.
PathGeometry computePathGeometry({
  required CourseSpine spine,
  required int activeIndex,
  String Function(CourseUnit unit)? sectionLabel,
  String Function(CourseUnit unit)? unitTitleLabel,
}) {
  String sectionOf(CourseUnit u) =>
      sectionLabel != null ? sectionLabel(u) : u.section;
  String titleOf(CourseUnit u) =>
      unitTitleLabel != null ? unitTitleLabel(u) : u.title;
  final nodes = <PathNodeData>[];
  final dividers = <PathDivider>[];
  double y = _kStartY;
  int gi = 0;
  int unitNo = 0;

  // S96: a divider marks a SECTION boundary. With authored curriculum rows
  // several consecutive units share one section, so emit the divider only when
  // the label CHANGES (legacy band-units always differ -> behaviour unchanged).
  String? prevSection;
  for (final unit in spine.units) {
    unitNo++;
    if (unit.section != prevSection) {
      dividers.add(PathDivider(label: sectionOf(unit), y: y));
      y += _kDividerGap;
      prevSection = unit.section;
    }

    final lessons = unit.lessons;
    for (int l = 0; l < lessons.length; l++) {
      final isCheckpoint = l == lessons.length - 1; // last lesson of the unit
      final lane = (l % 2 == 0) ? _kLaneLeft : _kLaneRight;
      final wobble = math.sin(gi * _kWobbleFreq) * _kWobbleAmp;
      final state = PathNodeData.resolveState(
        index: gi,
        activeIndex: activeIndex,
        isCheckpointFlag: isCheckpoint,
      );
      nodes.add(PathNodeData(
        index: gi,
        x: lane + wobble,
        y: y,
        state: state,
        unitTitle: titleOf(unit),
        unitNo: unitNo,
      ));
      y += isCheckpoint ? _kDyIntoCheckpoint : _kDy;
      gi++;
    }
    y += _kUnitGap;
  }

  return PathGeometry(
    nodes: nodes,
    dividers: dividers,
    contentHeight: y + _kTailPadding,
  );
}

// Traceability: [R-B3] Course→Section→Unit→Lesson path rendering (WS2 design-fidelity: serpentine geometry, 4 node states incl. end-of-unit checkpoint, dotted trail, bobbing traveller — SPEC_HOME_PATH).
