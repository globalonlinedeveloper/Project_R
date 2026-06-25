import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../motion/ratel_motion_tier.dart';
import '../tokens/ratel_spacing.dart';
import '../tokens/ratel_typography.dart';
import 'space_palette.dart';

/// Animated header HUD (spec §6) — lively, tier-gated vector chips: a section-
/// tinted streak flame (palette-driven, e.g. blue-fire near NEBULA REACH), a
/// pulsing energy bolt, a glinting "soon" diamond (honest placeholder — no fake
/// balance), a globe language pill and a gently swinging bell.
///
/// Decorative loops run ONLY at [MotionTier.full] (R-N7 `allowsLooping`); every
/// lower tier paints the still final frame, so OS reduce-motion stays a HARD
/// floor. design_system is the sanctioned home for the raw Duration/Color
/// literals these animations need (R-N6 token-lint).
class SpaceHud extends StatelessWidget {
  const SpaceHud({
    super.key,
    required this.streak,
    required this.energyLabel,
    required this.flameHue,
    required this.tier,
  });

  final int streak;
  final String energyLabel;
  final double flameHue;
  final MotionTier tier;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _LangChip(),
        const Spacer(),
        _FlameChip(streak: streak, hue: flameHue, tier: tier),
        const SizedBox(width: RatelSpacing.xs),
        _BoltChip(label: energyLabel, tier: tier),
        const SizedBox(width: RatelSpacing.xs),
        _GemChip(tier: tier),
        const SizedBox(width: RatelSpacing.xs),
        _BellChip(tier: tier),
      ],
    );
  }
}

/// A repeating 0..1 driver, frozen at [staticT] when the tier can't loop. Keeps
/// every HUD animation pumpAndSettle-safe under reduce-motion (controller idle).
class _Loop extends StatefulWidget {
  const _Loop({
    required this.period,
    required this.tier,
    required this.builder,
    this.staticT = 0,
  });
  final Duration period;
  final MotionTier tier;
  final double staticT;
  final Widget Function(BuildContext, double) builder;
  @override
  State<_Loop> createState() => _LoopState();
}

class _LoopState extends State<_Loop> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _Loop old) {
    super.didUpdateWidget(old);
    if (old.tier != widget.tier) _sync();
  }

  void _sync() {
    if (widget.tier == MotionTier.full) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = widget.staticT;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c, builder: (ctx, _) => widget.builder(ctx, _c.value));
}

double _wave(double t) => math.sin(t * 2 * math.pi);

Widget _pill({required Widget child}) => Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.sm, vertical: RatelSpacing.xs),
      decoration: BoxDecoration(
        color: SpacePalette.hudText.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
        border: Border.all(color: SpacePalette.hudText.withValues(alpha: 0.12)),
      ),
      child: child,
    );

class _FlameChip extends StatelessWidget {
  const _FlameChip(
      {required this.streak, required this.hue, required this.tier});
  final int streak;
  final double hue;
  final MotionTier tier;
  @override
  Widget build(BuildContext context) {
    final color = HSLColor.fromAHSL(1, hue % 360, 0.85, 0.62).toColor();
    return _pill(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Loop(
            period: const Duration(milliseconds: 1600),
            tier: tier,
            builder: (ctx, t) {
              final s = _wave(t);
              return Transform.scale(
                scaleX: 1 + 0.06 * s,
                scaleY: 1 - 0.05 * s,
                child: Icon(Icons.local_fire_department, size: 16, color: color),
              );
            },
          ),
          const SizedBox(width: RatelSpacing.xs),
          Text('$streak',
              style: RatelType.caption.copyWith(
                  color: SpacePalette.hudText, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _BoltChip extends StatelessWidget {
  const _BoltChip({required this.label, required this.tier});
  final String label;
  final MotionTier tier;
  @override
  Widget build(BuildContext context) {
    return _pill(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Loop(
            period: const Duration(milliseconds: 1900),
            tier: tier,
            staticT: 0.25,
            builder: (ctx, t) {
              final glow = 0.3 + 0.55 * (0.5 + 0.5 * _wave(t));
              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                      opacity: glow,
                      child: const Icon(Icons.bolt,
                          size: 18, color: SpacePalette.energyGlow)),
                  const Icon(Icons.bolt, size: 14, color: SpacePalette.energyCore),
                ],
              );
            },
          ),
          const SizedBox(width: RatelSpacing.xs),
          Text(label,
              style: RatelType.caption.copyWith(
                  color: SpacePalette.hudText, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _GemChip extends StatelessWidget {
  const _GemChip({required this.tier});
  final MotionTier tier;
  @override
  Widget build(BuildContext context) {
    return _pill(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Loop(
            period: const Duration(milliseconds: 3400),
            tier: tier,
            builder: (ctx, t) {
              final flash = math.max(0.0, 1 - (t - 0.82).abs() / 0.05);
              return Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.diamond_outlined,
                      size: 16, color: SpacePalette.gemB),
                  if (flash > 0)
                    Opacity(
                        opacity: flash,
                        child: const Icon(Icons.diamond,
                            size: 16, color: SpacePalette.hudText)),
                ],
              );
            },
          ),
          const SizedBox(width: RatelSpacing.xs),
          _soonPill(),
        ],
      ),
    );
  }
}

Widget _soonPill() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: SpacePalette.hudText.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
        border: Border.all(color: SpacePalette.hudText.withValues(alpha: 0.14)),
      ),
      child: Text('soon',
          style: RatelType.caption.copyWith(
              color: SpacePalette.hudMuted, fontWeight: FontWeight.w800)),
    );

class _BellChip extends StatelessWidget {
  const _BellChip({required this.tier});
  final MotionTier tier;
  @override
  Widget build(BuildContext context) {
    return _pill(
      child: _Loop(
        period: const Duration(milliseconds: 4400),
        tier: tier,
        builder: (ctx, t) {
          // a gentle swing that intensifies near the end of each cycle
          final swing =
              (t > 0.86) ? math.sin((t - 0.86) / 0.14 * 2 * math.pi) * 0.22 : 0.0;
          return Transform.rotate(
            angle: swing,
            alignment: Alignment.topCenter,
            child: const Icon(Icons.notifications_none,
                size: 16, color: SpacePalette.langText),
          );
        },
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip();
  @override
  Widget build(BuildContext context) {
    return _pill(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public, size: 16, color: SpacePalette.teal),
          const SizedBox(width: RatelSpacing.xs),
          Text('EN',
              style: RatelType.caption.copyWith(
                  color: SpacePalette.langText, fontWeight: FontWeight.w800)),
          const Icon(Icons.arrow_drop_down, size: 14, color: SpacePalette.hudMuted),
        ],
      ),
    );
  }
}
