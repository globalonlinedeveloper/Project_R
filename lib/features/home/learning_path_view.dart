import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';

import 'economy_glyph.dart';
import 'path_connector.dart';
import 'path_node.dart';
import 'path_node_state.dart';
import 'path_traveller.dart';
import 'unit_banner.dart';

/// A section divider row on the path (`Ratel App.dc.html`:148-154). A hairline
/// gradient, a centred "SECTION n · NAME" label, and a mirrored hairline,
/// absolutely positioned at [y] on the stage.
///
/// Pure data — the integrating screen supplies [label] + [y] from its ported
/// `buildPath` geometry.
class PathSectionDivider {
  const PathSectionDivider({required this.label, required this.y});

  /// Full label text, e.g. "SECTION 1 · BASICS".
  final String label;

  /// Vertical centre of the divider row on the stage.
  final double y;
}

/// One economy stat for the header cluster (emoji + pre-formatted value + tap).
///
/// The integrating screen formats [value] with [formatCount] / [formatEnergy]
/// and resolves the themed [color] before constructing this.
class EconomyStat {
  const EconomyStat({
    required this.emoji,
    required this.value,
    this.color,
    this.onTap,
  });

  final String emoji;
  final String value;
  final Color? color;
  final VoidCallback? onTap;
}

/// Assembles the whole learning-path view: the sticky [UnitBanner], the dotted
/// connector trail, the absolutely-positioned [PathNode]s + section dividers,
/// and the bobbing [PathTraveller] by the active node — all from data passed in.
///
/// Faithful to the design's `pathStyle` stage (`width:390px; height:contentH`,
/// HTML:3495) with nodes/trail/traveller sharing one coordinate space so they
/// stay aligned. Wraps the stage in a scroll view; the sticky banner stays
/// pinned above it.
///
/// PURE: every field is a constructor param — no provider reads, no navigation
/// beyond simple `VoidCallback`s ([onGuide], per-node [onNodeTap], [onStatTap]
/// via [EconomyStat.onTap]). [reduceMotion] is threaded down to the node pulse
/// and the traveller bob. No horizontal overflow at 360px (the 390-wide stage
/// is centred and, if narrower than the design width, fits via [FittedBox]-free
/// horizontal centering; nodes never extend past the stage bounds).
class LearningPathView extends StatelessWidget {
  const LearningPathView({
    super.key,
    required this.nodes,
    required this.contentHeight,
    required this.bannerKicker,
    required this.bannerUnitTitle,
    this.sectionDividers = const [],
    this.economy = const [],
    this.trailColor,
    this.constellation = false,
    this.constellationColor,
    this.starColor,
    this.reduceMotion = false,
    this.stageWidth = 390,
    this.travellerSize = 58,
    this.onGuide,
    this.onNodeTap,
    this.scrollController,
    this.activeNodeKey,
  });

  /// All path nodes with resolved state + geometry (single source of truth for
  /// node, trail, and traveller coordinates).
  final List<PathNodeData> nodes;

  /// Total stage height in px (design `contentH`).
  final double contentHeight;

  /// Section dividers to lay onto the stage (may be empty).
  final List<PathSectionDivider> sectionDividers;

  /// Header economy stats (🔥/⚡/💎...). May be empty.
  final List<EconomyStat> economy;

  /// Banner: the authored kicker/section string (e.g. "SECTION 1 · LEVEL A1").
  final String bannerKicker;

  /// Banner: named unit title.
  final String bannerUnitTitle;

  /// Themed trail colour. Defaults to the active palette's muted colour
  /// (design `var(--muted)`).
  final Color? trailColor;

  /// Whether to paint the galaxy constellation overlay over completed nodes.
  final bool constellation;

  /// Constellation line / star colours (galaxy skin).
  final Color? constellationColor;
  final Color? starColor;

  /// Hard reduce-motion floor, threaded to node pulse + traveller bob.
  final bool reduceMotion;

  /// The design stage width (nodes' x are relative to this).
  final double stageWidth;

  /// Rendered badger width.
  final double travellerSize;

  /// Guide-chip tap on the banner.
  final VoidCallback? onGuide;

  /// Per-node tap handler (given the node's data). Null disables node taps.
  final void Function(PathNodeData node)? onNodeTap;

  /// Optional external scroll controller for the path scroll view.
  final ScrollController? scrollController;

  /// Optional key applied to the ACTIVE node so the integrating screen / tests
  /// can find + tap the current node (e.g. `ValueKey('home-active-node')`).
  final Key? activeNodeKey;

  PathNodeData? get _activeNode {
    for (final n in nodes) {
      if (n.isActive) return n;
    }
    return null;
  }

  double _nodeSize(PathNodeData n) => n.isActive ? 64 : 56;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final trail = trailColor ?? palette.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UnitBanner(
          kicker: bannerKicker,
          unitTitle: bannerUnitTitle,
          onGuide: onGuide,
        ),
        if (economy.isNotEmpty) _EconomyRow(stats: economy),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Center(
              child: SizedBox(
                width: stageWidth,
                height: contentHeight,
                child: _buildStage(context, trail),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStage(BuildContext context, Color trail) {
    final active = _activeNode;

    final children = <Widget>[
      // z-index:1 — dotted trail (+ constellation) behind everything.
      Positioned.fill(
        child: CustomPaint(
          painter: PathConnectorPainter(
            nodes: nodes,
            trailColor: trail,
            constellation: constellation,
            constellationColor: constellationColor,
            starColor: starColor,
          ),
        ),
      ),
    ];

    // z-index:5 — section dividers.
    for (final d in sectionDividers) {
      children.add(
        Positioned(
          left: 20,
          right: 20,
          top: d.y - 8, // row is ~16px tall; centre it on d.y
          child: _SectionDividerRow(label: d.label),
        ),
      );
    }

    // z-index:6 — nodes, centred on their (x,y).
    for (final n in nodes) {
      final size = _nodeSize(n);
      // active node keeps room for its +5px pulse ring on each side.
      final box = n.isActive ? size + 10 : size;
      children.add(
        Positioned(
          left: n.x - box / 2,
          top: n.y - box / 2,
          width: box,
          height: box,
          child: Center(
            child: PathNode(
              key: n.isActive ? activeNodeKey : null,
              state: n.state,
              size: size,
              reduceMotion: reduceMotion,
              onTap: onNodeTap == null ? null : () => onNodeTap!(n),
            ),
          ),
        ),
      );
    }

    // z-index:8 — traveller, up-and-right of the active node (+44,-10), with
    // translate(-50%,-50%) — approximated by centering a fixed-size box.
    if (active != null) {
      const travellerBoxW = 72.0;
      const travellerBoxH = 84.0;
      final cx = active.x + 44;
      final cy = active.y - 10;
      children.add(
        Positioned(
          left: cx - travellerBoxW / 2,
          top: cy - travellerBoxH / 2,
          width: travellerBoxW,
          height: travellerBoxH,
          child: IgnorePointer(
            child: Center(
              child: PathTraveller(
                size: travellerSize,
                reduceMotion: reduceMotion,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: children);
  }
}

/// The header economy cluster — a right-aligned row of [EconomyGlyph]s.
class _EconomyRow extends StatelessWidget {
  const _EconomyRow({required this.stats});

  final List<EconomyStat> stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: 13),
            EconomyGlyph(
              emoji: stats[i].emoji,
              value: stats[i].value,
              color: stats[i].color,
              onTap: stats[i].onTap,
            ),
          ],
        ],
      ),
    );
  }
}

/// One in-path section divider: hairline gradient · label · mirrored hairline
/// (`Ratel App.dc.html`:148-154).
class _SectionDividerRow extends StatelessWidget {
  const _SectionDividerRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final border = context.palette.border;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [border.withValues(alpha: 0), border],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: context.palette.muted,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [border, border.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Traceability: [R-B3] Course→Section→Unit→Lesson path rendering (WS2 design-fidelity: serpentine geometry, 4 node states incl. end-of-unit checkpoint, dotted trail, bobbing traveller — SPEC_HOME_PATH).
