import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';

import 'path_node_state.dart';

/// Paints the learning path's dotted trail — and, optionally, the galaxy-skin
/// constellation overlay — through the node centres.
///
/// Faithful to `Ratel App.dc.html`:140-146 + 3237-3242:
///  * **Trail** (`trailD`): a single straight point-to-point polyline through
///    every node centre in order, stroked with the themed [trailColor] at
///    reduced opacity, width 4, dash pattern `2 / 11` (dot-gap), round caps.
///    The "wobble" comes from the nodes' x-jitter, not from curve smoothing —
///    so this is deliberately NOT a bezier.
///  * **Constellation** ([constellation] = true, galaxy only): a second faint
///    polyline linking ONLY the completed nodes, plus a small star dot at each
///    completed node centre. Ported from the design's `constelD` / `constelStars`.
///
/// This painter is motion-free in both the design and this port, so there is no
/// reduce-motion branch to gate — it paints identically either way.
///
/// Pure: consumes a `List<PathNodeData>` and plain [Color]s. No providers.
class PathConnectorPainter extends CustomPainter {
  PathConnectorPainter({
    required this.nodes,
    required this.trailColor,
    this.constellation = false,
    this.constellationColor,
    this.starColor,
    this.trailWidth = 4,
    this.trailOpacity = 0.4,
    this.dashOn = 2,
    this.dashOff = 11,
  });

  /// All path nodes, in path order. Their [PathNodeData.x] / y are the trail
  /// vertices. Completed nodes ([PathNodeData.isDone]) drive the constellation.
  final List<PathNodeData> nodes;

  /// Themed trail stroke colour (design: `var(--muted)` — the integrating
  /// screen passes `context.palette.muted`, or a world's connector colour).
  final Color trailColor;

  /// Whether to additionally paint the galaxy constellation overlay.
  final bool constellation;

  /// Constellation line colour (design: rgba(180,210,255,.5)). Falls back to a
  /// translucent white when null.
  final Color? constellationColor;

  /// Constellation star-dot colour (design: #eaf3ff). Falls back to white.
  final Color? starColor;

  final double trailWidth;
  final double trailOpacity;

  /// Dash pattern: [dashOn] px drawn, [dashOff] px gap (design "2 11").
  final double dashOn;
  final double dashOff;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length < 2) return;

    // --- Trail: dotted straight polyline through every node centre. ---
    final trailPaint = Paint()
      ..color = trailColor.withValues(alpha: trailOpacity)
      ..strokeWidth = trailWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    for (var i = 0; i < nodes.length - 1; i++) {
      _drawDashedSegment(
        canvas,
        Offset(nodes[i].x, nodes[i].y),
        Offset(nodes[i + 1].x, nodes[i + 1].y),
        trailPaint,
      );
    }

    // --- Constellation overlay (galaxy only): links completed nodes. ---
    if (!constellation) return;
    final done = nodes.where((n) => n.isDone).toList(growable: false);
    if (done.isEmpty) return;

    final lineColor =
        constellationColor ?? RatelColors.onColor.withValues(alpha: 0.5);
    final dotColor = starColor ?? RatelColors.onColor;

    if (done.length >= 2) {
      final constelPaint = Paint()
        ..color = lineColor
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;
      final path = Path()..moveTo(done.first.x, done.first.y);
      for (var i = 1; i < done.length; i++) {
        path.lineTo(done[i].x, done[i].y);
      }
      canvas.drawPath(path, constelPaint);
    }

    // Star dot (r = 2.4) at each completed node centre.
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    for (final n in done) {
      canvas.drawCircle(Offset(n.x, n.y), 2.4, dotPaint);
    }
  }

  /// Draws a single dashed straight segment from [a] to [b] using the on/off
  /// dash lengths. Mirrors the design's `stroke-dasharray:"2 11"` over the
  /// point-to-point `trailD` polyline.
  void _drawDashedSegment(Canvas canvas, Offset a, Offset b, Paint paint) {
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    final step = dashOn + dashOff;
    var dist = 0.0;
    while (dist < total) {
      final start = a + dir * dist;
      final endDist = math.min(dist + dashOn, total);
      final end = a + dir * endDist;
      canvas.drawLine(start, end, paint);
      dist += step;
    }
  }

  @override
  bool shouldRepaint(covariant PathConnectorPainter old) {
    return old.nodes != nodes ||
        old.trailColor != trailColor ||
        old.constellation != constellation ||
        old.constellationColor != constellationColor ||
        old.starColor != starColor ||
        old.trailWidth != trailWidth ||
        old.trailOpacity != trailOpacity ||
        old.dashOn != dashOn ||
        old.dashOff != dashOff;
  }
}
