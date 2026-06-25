import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../energy/energy_controller.dart';
import '../energy/energy_gate.dart';
import '../energy/energy_state.dart';
import '../settings/settings_controller.dart';
import '../../content/models/enums.dart';
import '../../services/learning/cold_start.dart';
import '../placement/placement_controller.dart';
import '../practice/practice_controller.dart';
import '../streak/streak_controller.dart';
import 'lesson_preview_sheet.dart';

/// The galaxy layout is deterministic, so build it once and share it.
final galaxyLayoutProvider = Provider<GalaxyLayout>((ref) => generateGalaxy());

/// Space "galaxy" Home: the scrollable planet path with the Ratel pod on the
/// current lesson, an animated-ready HUD overlay, and a course-progress / free-
/// review bottom bar. `activeIdx` is REAL (lessons completed); the energy gate +
/// free reviews are preserved. Whole-app dark-space re-skin follows the selected
/// world theme; galaxy chrome reads named [SpacePalette] colours (no raw
/// literals — R-N6).
///
/// Owns the galaxy [ScrollController] so the bottom-right locate FAB can
/// recenter the viewport on the active planet (`y - 230`, matching the auto-
/// scroll target). Recenter honors motion: it `jumpTo`s under a static tier
/// (OS reduce-motion floor / motion-off) and `animateTo`s otherwise.
class SpaceHomeScreen extends ConsumerStatefulWidget {
  const SpaceHomeScreen({super.key});

  @override
  ConsumerState<SpaceHomeScreen> createState() => _SpaceHomeScreenState();
}

class _SpaceHomeScreenState extends ConsumerState<SpaceHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Smooth-scroll (or jump, under a static motion tier) the galaxy to a content
  /// Y, clamped to the scroll extent. Shared by the locate FAB + course map.
  void _scrollToY(double y, MotionTier tier) {
    if (!_scrollController.hasClients) return;
    final target = y.clamp(0.0, _scrollController.position.maxScrollExtent);
    if (tier.isStatic) {
      _scrollController.jumpTo(target);
    } else {
      _scrollController.animateTo(target,
          duration: RatelMotion.slow, curve: RatelMotion.standard);
    }
  }

  /// Recenter the galaxy on the active planet (spec §13 — locate FAB).
  void _locateActive(GalaxyLayout layout, int active, MotionTier tier) {
    if (layout.count == 0) return;
    final a = layout.planets[active.clamp(0, layout.count - 1)];
    _scrollToY(a.y - 230, tier);
  }

  /// Course-map sheet (spec §7) — tap a section row to jump to its band.
  void _showCourseMap(GalaxyLayout layout, int active, MotionTier tier) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SpacePalette.phoneBg.withValues(alpha: 0),
      isScrollControlled: true,
      builder: (ctx) => _CourseMapSheet(
        layout: layout,
        active: active,
        onJump: (s) {
          Navigator.of(ctx).pop();
          _scrollToY(layout.bands[s].y - 40, tier);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final energy = ref.watch(energyControllerProvider);
    final streak = ref.watch(streakControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final layout = ref.watch(galaxyLayoutProvider);

    final active = energy.lessonsCompleted.clamp(0, layout.count - 1);
    final theta = ref.watch(placementControllerProvider).thetaGlobal;
    final band = const ColdStartModel().bandFor(theta) ?? CefrLevel.a1;
    final levelLabel = 'Lv ${band.name.toUpperCase()}';
    final sections = layout.bands.length;
    final activeSection =
        layout.count == 0 ? 0 : layout.planets[active].section;
    final coursePct =
        layout.count == 0 ? 0 : (active / layout.count * 100).round();
    final isNewUser =
        active == 0 && streak.current == 0 && energy.lessonsCompleted == 0;
    final tier = effectiveMotionTier(
      osReduceMotion: MediaQuery.maybeOf(context)?.disableAnimations ?? false,
      perfTier: PerfTier.high,
      motionPreference: settings.motion,
    );

    void onPlanetTap(GalaxyPlanet planet, int index) {
      final state = index < active
          ? PlanetState.done
          : (index == active ? PlanetState.active : PlanetState.locked);
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: SpacePalette.phoneBg.withValues(alpha: 0),
        isScrollControlled: true,
        builder: (sheetCtx) => LessonPreviewSheet(
          planet: planet,
          state: state,
          onStart: () {
            Navigator.of(sheetCtx).pop();
            maybeStartLesson(context, ref, review: false);
          },
          onReview: () {
            Navigator.of(sheetCtx).pop();
            maybeStartLesson(context, ref, review: true);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: SpacePalette.phoneBg,
      body: Stack(
        key: const Key('space-home'),
        children: [
          Positioned.fill(
            child: GalaxyView(
              controller: _scrollController,
              layout: layout,
              activeIdx: active,
              tier: tier,
              onPlanetTap: onPlanetTap,
            ),
          ),
          // top scrim so planets fade under the header (matches the prototype)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: IgnorePointer(child: _TopScrim()),
          ),
          // Header HUD + daily strip — fixed top overlay (spec §6/§8/§17),
          // positioned so the body Stack fills the viewport.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    RatelSpacing.lg, RatelSpacing.sm, RatelSpacing.lg, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SpaceHud(streak: streak.current, energy: energy),
                    const SizedBox(height: RatelSpacing.sm),
                    _CourseBar(
                      section: activeSection,
                      sections: sections,
                      pct: coursePct,
                      onTap: () => _showCourseMap(layout, active, tier),
                    ),
                    const SizedBox(height: RatelSpacing.sm),
                    const _DailyStrip(),
                  ],
                ),
              ),
            ),
          ),
          if (isNewUser)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 118,
              child: IgnorePointer(child: Center(child: _Coach())),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SpaceBottomBar(
              level: levelLabel,
              done: active,
              total: layout.count,
              lessons: energy.lessonsCompleted,
              onReview: () => maybeStartLesson(context, ref, review: true),
            ),
          ),
          // Bottom-right locate FAB — recenters on the active planet (spec §13).
          Positioned(
            right: 14,
            bottom: 130,
            child: _LocateFab(
              key: const Key('locate-fab'),
              onTap: () => _locateActive(layout, active, tier),
            ),
          ),
        ],
      ),
    );
  }
}

/// 44px circular "locate" control — taps recenter the galaxy on the current
/// planet. A non-directional `my_location` crosshair (always available), per the
/// owner's C3 spec (supersedes the prototype's off-screen-only directional arrow).
class _LocateFab extends StatelessWidget {
  const _LocateFab({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Locate current lesson',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SpacePalette.fabBg,
            shape: BoxShape.circle,
            border: Border.all(color: SpacePalette.teal.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                  color: SpacePalette.teal.withValues(alpha: 0.35),
                  blurRadius: 12),
            ],
          ),
          child: const Icon(Icons.my_location, size: 22, color: SpacePalette.teal),
        ),
      ),
    );
  }
}

class _TopScrim extends StatelessWidget {
  const _TopScrim();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SpacePalette.phoneBg,
            SpacePalette.phoneBg.withValues(alpha: 0),
          ],
          stops: const [0.55, 1],
        ),
      ),
    );
  }
}

class _SpaceHud extends StatelessWidget {
  const _SpaceHud({required this.streak, required this.energy});
  final int streak;
  final EnergyState energy;

  @override
  Widget build(BuildContext context) {
    final energyLabel = energy.isUnlimited ? '∞' : '${energy.energy}';
    return Row(
      children: [
        const _HudChip(icon: Icons.public, label: 'EN', tint: SpacePalette.teal),
        const Spacer(),
        _HudChip(
            icon: Icons.local_fire_department,
            label: '$streak',
            tint: SpacePalette.checkpoint),
        const SizedBox(width: RatelSpacing.sm),
        _HudChip(
            icon: Icons.bolt, label: energyLabel, tint: SpacePalette.energyGlow),
        const SizedBox(width: RatelSpacing.sm),
        const _HudChip(
            icon: Icons.diamond_outlined,
            label: 'soon',
            tint: SpacePalette.gemB,
            muted: true),
        const SizedBox(width: RatelSpacing.sm),
        const _HudChip(icon: Icons.notifications_none, tint: SpacePalette.langText),
      ],
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip(
      {required this.icon, this.label, required this.tint, this.muted = false});
  final IconData icon;
  final String? label;
  final Color tint;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.sm, vertical: RatelSpacing.xs),
      decoration: BoxDecoration(
        color: SpacePalette.hudText.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
        border: Border.all(color: SpacePalette.hudText.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          if (label != null) ...[
            const SizedBox(width: RatelSpacing.xs),
            Text(label!,
                style: RatelType.caption.copyWith(
                    color: muted ? SpacePalette.hudMuted : SpacePalette.hudText)),
          ],
        ],
      ),
    );
  }
}

class _SpaceBottomBar extends StatelessWidget {
  const _SpaceBottomBar({
    required this.level,
    required this.done,
    required this.total,
    required this.lessons,
    required this.onReview,
  });
  final String level;
  final int done;
  final int total;
  final int lessons;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            SpacePalette.phoneBg,
            SpacePalette.phoneBg.withValues(alpha: 0),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, RatelSpacing.md,
              RatelSpacing.lg, RatelSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _LvChip(level),
                  const SizedBox(width: RatelSpacing.sm),
                  Expanded(
                    child: Text('${(pct * 100).round()}% · galaxy',
                        overflow: TextOverflow.ellipsis,
                        style: RatelType.caption
                            .copyWith(color: SpacePalette.tealText)),
                  ),
                  const SizedBox(width: RatelSpacing.sm),
                  Flexible(
                    child: Text('$lessons lessons',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: RatelType.caption
                            .copyWith(color: SpacePalette.hudMuted)),
                  ),
                ],
              ),
              const SizedBox(height: RatelSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: SpacePalette.hudText.withValues(alpha: 0.12),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(SpacePalette.teal),
                ),
              ),
              const SizedBox(height: RatelSpacing.sm),
              TextButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.refresh_rounded,
                    size: 18, color: SpacePalette.tealText),
                label: Text('Review mistakes · free',
                    style: RatelType.label
                        .copyWith(color: SpacePalette.tealText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LvChip extends StatelessWidget {
  const _LvChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.sm, vertical: RatelSpacing.xs),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [SpacePalette.teal, SpacePalette.tealDeep]),
        borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
      ),
      child: Text(label,
          style: RatelType.caption.copyWith(
              color: SpacePalette.tealInk, fontWeight: FontWeight.w800)),
    );
  }
}

class _Coach extends StatelessWidget {
  const _Coach();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: RatelSpacing.xl),
      padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.lg, vertical: RatelSpacing.md),
      decoration: BoxDecoration(
        color: SpacePalette.tealDarker.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(RatelSpacing.radiusLg),
        border: Border.all(color: SpacePalette.teal.withValues(alpha: 0.6)),
      ),
      child: Text('Tap the glowing planet to begin ✦',
          textAlign: TextAlign.center,
          style: RatelType.bodyStrong.copyWith(color: SpacePalette.hudText)),
    );
  }
}

// ===== Daily strip (spec §8): goal ring · energy refill · due reviews =====

class _DailyStrip extends StatelessWidget {
  const _DailyStrip();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _GoalRingChip()),
        SizedBox(width: RatelSpacing.xs),
        Expanded(child: _EnergyRefillChip()),
        SizedBox(width: RatelSpacing.xs),
        Expanded(child: _DueChip()),
      ],
    );
  }
}

Widget _dailyChip(
    {Key? key, required Widget child, required VoidCallback onTap}) {
  return GestureDetector(
    key: key,
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      padding:
          const EdgeInsets.symmetric(horizontal: RatelSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: SpacePalette.dchipBg,
        borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
        border: Border.all(color: SpacePalette.hudText.withValues(alpha: 0.13)),
      ),
      child: child,
    ),
  );
}

Widget _chipLabels(String main, String sub) {
  return Flexible(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(main,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RatelType.caption.copyWith(
                color: SpacePalette.hudText, fontWeight: FontWeight.w800)),
        Text(sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RatelType.caption
                .copyWith(color: SpacePalette.hudMuted, fontSize: 9)),
      ],
    ),
  );
}

String _fmtClock(int secs) {
  final m = secs ~/ 60;
  final s = (secs % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class _GoalRingChip extends ConsumerWidget {
  const _GoalRingChip();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(settingsControllerProvider.select((s) => s.dailyGoal));
    final xp = ref.watch(energyControllerProvider.select((e) => e.xpToday));
    final progress = goal == 0 ? 0.0 : (xp / goal).clamp(0.0, 1.0);
    return _dailyChip(
      key: const Key('goal-chip'),
      onTap: () => _showGoalSheet(context),
      child: Row(
        children: [
          RatelProgressRing(progress: progress, size: 26, stroke: 4),
          const SizedBox(width: RatelSpacing.xs),
          _chipLabels('$xp/$goal', 'XP today'),
        ],
      ),
    );
  }
}

class _EnergyRefillChip extends ConsumerStatefulWidget {
  const _EnergyRefillChip();
  @override
  ConsumerState<_EnergyRefillChip> createState() => _EnergyRefillChipState();
}

class _EnergyRefillChipState extends ConsumerState<_EnergyRefillChip> {
  Timer? _timer;

  /// Run a 1s tick ONLY while the tank is below full (so a full-tank home stays
  /// pumpAndSettle-safe). Each tick credits any real-time regen + refreshes the
  /// countdown read from the wall clock — never a faked decrement.
  void _sync(EnergyState e) {
    final need = !e.isUnlimited && e.energy < e.config.maxEnergy;
    if (need && _timer == null) {
      _timer = Timer.periodic(RatelMotion.secondTick, (_) {
        ref.read(energyControllerProvider.notifier).applyRegen();
        if (mounted) setState(() {});
      });
    } else if (!need && _timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = ref.watch(energyControllerProvider);
    _sync(e);
    final max = e.config.maxEnergy;
    final full = e.isUnlimited || e.energy >= max;
    final secs = full
        ? 0
        : e.remainingRefillSeconds(DateTime.now().millisecondsSinceEpoch);
    final main = e.isUnlimited ? '∞' : '${e.energy}/$max';
    final sub = full ? 'Full' : '+1 in ${_fmtClock(secs)}';
    return _dailyChip(
      key: const Key('energy-chip'),
      onTap: () => _showEnergySheet(context),
      child: Row(
        children: [
          const Icon(Icons.bolt, size: 16, color: SpacePalette.energyGlow),
          const SizedBox(width: RatelSpacing.xs),
          _chipLabels(main, sub),
        ],
      ),
    );
  }
}

class _DueChip extends ConsumerWidget {
  const _DueChip();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(practiceControllerProvider.select((p) => p.dueCount));
    final has = due > 0;
    return _dailyChip(
      key: const Key('due-chip'),
      onTap: () => maybeStartLesson(context, ref, review: true),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded,
              size: 16, color: SpacePalette.tealText),
          const SizedBox(width: RatelSpacing.xs),
          _chipLabels(
              has ? '$due due' : 'All clear', has ? 'Practice now' : 'Nothing due'),
        ],
      ),
    );
  }
}

void _showGoalSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: SpacePalette.phoneBg.withValues(alpha: 0),
    isScrollControlled: true,
    builder: (ctx) => const _GoalPickerSheet(),
  );
}

void _showEnergySheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: SpacePalette.phoneBg.withValues(alpha: 0),
    isScrollControlled: true,
    builder: (ctx) => const _EnergySheet(),
  );
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SpacePalette.sheetTop, SpacePalette.sheetBottom],
        ),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(RatelSpacing.radiusLg)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(RatelSpacing.xl, RatelSpacing.md,
              RatelSpacing.xl, RatelSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SpacePalette.hudText.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: RatelSpacing.lg),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

Widget _sheetEyebrow(String t) => Text(t,
    style: RatelType.caption.copyWith(
        color: SpacePalette.hudMuted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w800));

class _SheetButton extends StatelessWidget {
  const _SheetButton(
      {required this.label, required this.onPressed, this.primary = true});
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled && primary
                  ? const LinearGradient(
                      colors: [SpacePalette.teal, SpacePalette.tealDeep])
                  : null,
              color: enabled && primary
                  ? null
                  : SpacePalette.hudText.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
            ),
            padding: const EdgeInsets.symmetric(vertical: RatelSpacing.md),
            child: Center(
              child: Text(label,
                  style: RatelType.label.copyWith(
                      color: enabled && primary
                          ? SpacePalette.tealInk
                          : SpacePalette.tealText,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalPickerSheet extends ConsumerWidget {
  const _GoalPickerSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(settingsControllerProvider.select((s) => s.dailyGoal));
    final xp = ref.watch(energyControllerProvider.select((e) => e.xpToday));
    final left = ((goal - xp) / 20).ceil();
    final sub = xp >= goal
        ? 'Goal smashed — nice!'
        : '${left < 1 ? 1 : left} more lesson(s) to hit it';
    const options = <(String, int)>[
      ('Casual', 10),
      ('Regular', 20),
      ('Serious', 30),
    ];
    return _SheetShell(
      children: [
        _sheetEyebrow('DAILY GOAL'),
        const SizedBox(height: RatelSpacing.xs),
        Text('$xp / $goal XP today',
            style: RatelType.headline.copyWith(color: SpacePalette.hudText)),
        const SizedBox(height: RatelSpacing.xs),
        Text(sub, style: RatelType.body.copyWith(color: SpacePalette.hudMuted)),
        const SizedBox(height: RatelSpacing.lg),
        for (final o in options)
          _GoalOption(
            label: o.$1,
            xp: o.$2,
            selected: goal == o.$2,
            onTap: () =>
                ref.read(settingsControllerProvider.notifier).setDailyGoal(o.$2),
          ),
        const SizedBox(height: RatelSpacing.sm),
        _SheetButton(
            label: 'Done',
            primary: false,
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class _GoalOption extends StatelessWidget {
  const _GoalOption(
      {required this.label,
      required this.xp,
      required this.selected,
      required this.onTap});
  final String label;
  final int xp;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpacing.lg, vertical: RatelSpacing.md),
          decoration: BoxDecoration(
            color: SpacePalette.hudText.withValues(alpha: selected ? 0.10 : 0.04),
            borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
            border: Border.all(
                color: selected
                    ? SpacePalette.teal
                    : SpacePalette.hudText.withValues(alpha: 0.12),
                width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: RatelType.label.copyWith(
                        color: SpacePalette.hudText,
                        fontWeight: FontWeight.w800)),
              ),
              Text('$xp XP / day',
                  style: RatelType.caption
                      .copyWith(color: SpacePalette.hudMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnergySheet extends ConsumerWidget {
  const _EnergySheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = ref.watch(energyControllerProvider);
    final max = e.config.maxEnergy;
    final full = e.isUnlimited || e.energy >= max;
    final secs = full
        ? 0
        : e.remainingRefillSeconds(DateTime.now().millisecondsSinceEpoch);
    final sub = e.isUnlimited
        ? 'Unlimited energy with Pro.'
        : (full
            ? 'Your tank is full — go learn!'
            : 'Next +1 in ${_fmtClock(secs)} · refills 1 every 25 min.');
    return _SheetShell(
      children: [
        _sheetEyebrow('ENERGY'),
        const SizedBox(height: RatelSpacing.xs),
        Text(e.isUnlimited ? '∞ energy' : '${e.energy} / $max energy',
            style: RatelType.headline.copyWith(color: SpacePalette.hudText)),
        const SizedBox(height: RatelSpacing.xs),
        Text(sub, style: RatelType.body.copyWith(color: SpacePalette.hudMuted)),
        const SizedBox(height: RatelSpacing.lg),
        if (!e.isUnlimited)
          _SheetButton(
            label: 'Watch ad +1',
            onPressed: full
                ? null
                : () {
                    ref.read(energyControllerProvider.notifier).refill(1);
                    Navigator.of(context).pop();
                  },
          ),
        const SizedBox(height: RatelSpacing.sm),
        _SheetButton(
            label: 'Done',
            primary: false,
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

// ===== Course-progress bar + section map (spec §7) =====

class _CourseBar extends StatelessWidget {
  const _CourseBar(
      {required this.section,
      required this.sections,
      required this.pct,
      required this.onTap});
  final int section;
  final int sections;
  final int pct;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('course-bar'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Text('SECTION ${section + 1} / $sections',
              style: RatelType.caption.copyWith(
                  color: SpacePalette.hudMuted,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: RatelSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
              child: SizedBox(
                height: 5,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ColoredBox(
                          color: SpacePalette.hudText.withValues(alpha: 0.13)),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (pct / 100).clamp(0.0, 1.0),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [SpacePalette.tealDeep, SpacePalette.teal]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: RatelSpacing.sm),
          Text('$pct%',
              style: RatelType.caption.copyWith(
                  color: SpacePalette.tealText, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _CourseMapSheet extends StatelessWidget {
  const _CourseMapSheet(
      {required this.layout, required this.active, required this.onJump});
  final GalaxyLayout layout;
  final int active;
  final void Function(int section) onJump;
  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var s = 0; s < layout.bands.length; s++) {
      final idxs = <int>[
        for (var i = 0; i < layout.planets.length; i++)
          if (layout.planets[i].section == s) i
      ];
      if (idxs.isEmpty) continue;
      final first = idxs.first;
      final last = idxs.last;
      final total = idxs.length;
      final done = idxs.where((i) => i < active).length;
      final status =
          active < first ? 'Locked' : (active > last ? 'Done' : 'In progress');
      rows.add(_MapRow(
        title: 'Section ${s + 1} · ${layout.bands[s].name}',
        sub: '$done/$total lessons · $status',
        locked: status == 'Locked',
        onTap: () => onJump(s),
      ));
    }
    return _SheetShell(
      children: [
        _sheetEyebrow('YOUR JOURNEY'),
        const SizedBox(height: RatelSpacing.xs),
        Text('Course map',
            style: RatelType.headline.copyWith(color: SpacePalette.hudText)),
        const SizedBox(height: RatelSpacing.xs),
        Text('${layout.bands.length} sections · tap to jump.',
            style: RatelType.body.copyWith(color: SpacePalette.hudMuted)),
        const SizedBox(height: RatelSpacing.lg),
        ...rows,
      ],
    );
  }
}

class _MapRow extends StatelessWidget {
  const _MapRow(
      {required this.title,
      required this.sub,
      required this.locked,
      required this.onTap});
  final String title;
  final String sub;
  final bool locked;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: locked ? 0.5 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: RatelSpacing.lg, vertical: RatelSpacing.md),
            decoration: BoxDecoration(
              color: SpacePalette.hudText.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
              border:
                  Border.all(color: SpacePalette.hudText.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: RatelType.label.copyWith(
                              color: SpacePalette.hudText,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(sub,
                          style: RatelType.caption
                              .copyWith(color: SpacePalette.hudMuted)),
                    ],
                  ),
                ),
                Icon(locked ? Icons.lock : Icons.chevron_right,
                    size: 18, color: SpacePalette.hudMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Traceability: R-WT4
