import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../motion/ratel_motion_tier.dart';
import '../tokens/ratel_typography.dart';
import 'galaxy_model.dart';
import 'galaxy_painter.dart';
import 'galaxy_fx.dart';
import 'pod_painter.dart';
import 'space_palette.dart';

Color _hsl(double h, double s, double l) =>
    HSLColor.fromAHSL(1, h % 360, s, l).toColor();

/// The scrollable galaxy: dynamic backdrop + dashed planet path + procedurally
/// seeded planets + the Ratel pod on the current planet. The 344-wide design is
/// centred in the viewport (never re-clamped; spec §17). Tapping a planet calls
/// [onPlanetTap]. Motion: the backdrop is scroll-reactive (not looping), so it
/// is reduce-motion safe; [tier] gates the ion trail (and, later, FX).
class GalaxyView extends StatefulWidget {
  const GalaxyView({
    super.key,
    required this.layout,
    required this.activeIdx,
    required this.tier,
    required this.onPlanetTap,
    this.controller,
  });

  final GalaxyLayout layout;
  final int activeIdx;
  final MotionTier tier;
  final void Function(GalaxyPlanet planet, int index) onPlanetTap;
  final ScrollController? controller;

  @override
  State<GalaxyView> createState() => _GalaxyViewState();
}

class _GalaxyViewState extends State<GalaxyView> {
  ScrollController? _own;
  ScrollController get _sc => widget.controller ?? (_own ??= ScrollController());
  bool _jumped = false;

  int get _active =>
      widget.activeIdx.clamp(0, math.max(0, widget.layout.count - 1));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToActive());
  }

  void _jumpToActive() {
    if (_jumped || !_sc.hasClients || widget.layout.count == 0) return;
    final a = widget.layout.planets[_active];
    final target = (a.y - 230).clamp(0.0, _sc.position.maxScrollExtent);
    _sc.jumpTo(target);
    _jumped = true;
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  PlanetState _stateFor(int i) => i < _active
      ? PlanetState.done
      : (i == _active ? PlanetState.active : PlanetState.locked);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final dx = (w - 344) / 2;
        final planets = widget.layout.planets;
        final active = planets.isEmpty ? null : planets[_active];
        final showIon = widget.tier != MotionTier.none;

        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _sc,
                builder: (context, _) => CustomPaint(
                  painter: GalaxyBackdropPainter(
                    scrollY: _sc.hasClients ? _sc.offset : 0,
                    bands: widget.layout.bands,
                    total: widget.layout.total,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: GalaxyFxLayer(
                controller: _sc,
                size: Size(
                    w, constraints.maxHeight.isFinite ? constraints.maxHeight : 716),
                activePlanet:
                    active == null ? null : Offset(active.x + dx, active.y),
                bands: widget.layout.bands,
                tier: widget.tier,
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _sc,
                child: SizedBox(
                  height: widget.layout.total,
                  width: w,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: GalaxyTrailPainter(
                            planets: planets,
                            dx: dx,
                            activeIdx: _active,
                            showIon: showIon,
                          ),
                        ),
                      ),
                      for (final b in widget.layout.bands)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: b.y + 8,
                          child: Center(
                              child: _SectionPill(section: b.section, name: b.name)),
                        ),
                      for (var i = 0; i < planets.length; i++)
                        Positioned(
                          left: planets[i].x + dx - 28,
                          top: planets[i].y - 28,
                          child: GestureDetector(
                            key: ValueKey<String>('galaxy-planet-$i'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.onPlanetTap(planets[i], i),
                            child: _PlanetWidget(
                              planet: planets[i],
                              state: _stateFor(i),
                            ),
                          ),
                        ),
                      if (active != null) ...[
                        Positioned(
                          left: active.x + dx - 24,
                          top: active.y - 32,
                          child: const _StartLabel(),
                        ),
                        Positioned(
                          left: active.x + dx + 20 - 29,
                          top: active.y + 14 - 20,
                          child: const IgnorePointer(child: RatelPod()),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlanetWidget extends StatelessWidget {
  const _PlanetWidget({required this.planet, required this.state});
  final GalaxyPlanet planet;
  final PlanetState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(56, 56),
            painter: PlanetSurfacePainter(planet: planet, state: state),
          ),
          if (state == PlanetState.locked)
            const Icon(Icons.lock, size: 17, color: Color(0xFFDFE6F5))
          else if (state == PlanetState.done)
            const Icon(Icons.check_rounded, size: 20, color: SpacePalette.teal),
          if (planet.isCheckpoint && state != PlanetState.locked)
            const Positioned(
              top: -2,
              child: Icon(Icons.workspace_premium,
                  size: 16, color: SpacePalette.crownGold),
            ),
        ],
      ),
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({required this.section, required this.name});
  final int section;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x99060814),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SpacePalette.hudText.withValues(alpha: 0.12)),
      ),
      child: Text(
        'SECTION ${section + 1} · $name',
        style: RatelType.caption.copyWith(
          color: _hsl(goldenHue(section), 0.80, 0.86),
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StartLabel extends StatelessWidget {
  const _StartLabel();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: SpacePalette.teal,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
              color: SpacePalette.teal.withValues(alpha: 0.7), blurRadius: 10),
        ],
      ),
      child: Text('START',
          style: RatelType.caption
              .copyWith(color: SpacePalette.tealInk, fontWeight: FontWeight.w800)),
    );
  }
}
