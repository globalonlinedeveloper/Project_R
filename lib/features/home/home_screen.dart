import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/home/economy_glyph.dart';
import 'package:ratel/features/home/galaxy_path.dart';
import 'package:ratel/features/home/learning_path_view.dart';
import 'package:ratel/features/home/path_geometry.dart';
import 'package:ratel/features/home/path_node_state.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart' show WorldTheme;

/// Home tab (🏠) — the learning path, design spec §4.1. A Duolingo-style winding
/// path of lesson nodes.
///
/// CONTENT-DRIVEN SPINE (queue #H): the units / lessons / exercise counts are
/// now projected from the authored `ContentBatch` (via [courseSpineProvider],
/// injected at app root from `lib/content`) — NOT a hand-written outline. The
/// node STATES (done / active / locked) stay 100% REAL: derived from
/// `lessonsCompleted` on the learner snapshot, so a fresh account has node 0
/// active and everything after it locked. Tapping the active node opens the
/// lesson-preview sheet (§4.6).
///
/// GALAXY HOME (R-WT4, S66 · G2): when the Space [WorldTheme] is active the same
/// real path re-skins into a galaxy — a [GalaxyPathPainter] orbital backdrop,
/// each node a [GalaxyPlanet], the current node carrying a [PodTraveller]. Only
/// the SKIN changes; states + positions are identical to Classic.
///
/// HONESTY (§6 / charter "don't fake depth"): every title + the per-lesson
/// exercise count is real authored content. If no course is wired (the bundled
/// batch failed to load) the path shows an honest empty state — never a
/// fabricated curriculum. Wiring each lesson's exercises INTO the runner is the
/// next increment (#H2); today "Start lesson" opens the adaptive runner.
/// [R-B3] Course→Section→Unit→Lesson containers & path rendering.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static List<_Node> _flatten(CourseSpine spine) {
    final List<_Node> out = <_Node>[];
    int gi = 0;
    for (int ui = 0; ui < spine.units.length; ui++) {
      final CourseUnit u = spine.units[ui];
      // S96: a section HEADER marks a section boundary; consecutive authored
      // units share a section, so only the first unit of a section starts one.
      final bool newSection =
          ui == 0 || spine.units[ui - 1].section != u.section;
      for (int i = 0; i < u.lessons.length; i++) {
        final CourseLesson l = u.lessons[i];
        out.add(_Node(
          id: l.id,
          section: u.section,
          unit: u.title,
          lesson: l.title,
          cefr: l.cefr,
          exercises: l.exerciseCount,
          globalIndex: gi,
          lessonNum: i + 1,
          lessonCount: u.lessons.length,
          inUnit: i,
          sectionStart: i == 0 && newSection,
          guideText: u.guideText,
        ));
        gi++;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final CourseSpine spine = ref.watch(courseSpineProvider);
    // R-L11 inbox surface: the Home top-bar bell + unread badge open the
    // in-app notifications feed (a real, learner-derived count — never faked).
    final int unread = ref.watch(unreadNotificationsCountProvider);
    // R-WT4 (S66 · G2): re-skin the path as a galaxy when Space is active.
    final bool galaxy = ref.watch(worldThemeProvider) == WorldTheme.space;

    if (spine.isEmpty) {
      return _emptyState(context, snap.streakDays, snap.diamonds,
          snap.streakFreezes, unread, snap.energy, ref.watch(isProProvider));
    }

    final List<_Node> nodes = _flatten(spine);
    final int active = snap.lessonsCompleted;
    final _Node current = nodes[active.clamp(0, nodes.length - 1)];
    // Honour the reduce-motion HARD floor from BOTH the app-wide MediaQuery
    // (RatelApp folds OS setting + toggle) AND the provider directly, so the
    // floor still holds when Home is hosted without RatelApp's MediaQuery
    // wrapper (e.g. router-only widget tests). SPEC_HOME_PATH Part C.
    final bool reduceMotion = MediaQuery.of(context).disableAnimations ||
        ref.watch(reduceMotionProvider);
    final PathGeometry geom =
        computePathGeometry(spine: spine, activeIndex: active);

    return Container(
      key: const ValueKey<String>('tab-home'),
      color: context.palette.cream,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                RatelTopBar(
                    flagEmoji: _flagFor(spine.courseCode),
                    langCode: _langFor(spine.courseCode),
                    streak: snap.streakDays,
                    energyLabel: formatEnergy(snap.energy,
                        unlimited: ref.watch(isProProvider)),
                    diamonds: formatCount(snap.diamonds),
                    streakFreeze:
                        snap.streakFreezes > 0 ? snap.streakFreezes : null,
                    unreadNotifications: unread,
                    onNotificationsTap: () => context.push('/notifications')),
                if (galaxy) _unitBanner(context, current),
                Expanded(
                  child: galaxy
                      ? ListView.builder(
                          padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                              RatelSpace.lg, RatelSpace.screen, 96),
                          itemCount: nodes.length,
                          itemBuilder: (BuildContext context, int i) =>
                              _pathRow(context, nodes, i, active, true),
                        )
                      : LearningPathView(
                          nodes: geom.nodes,
                          contentHeight: geom.contentHeight,
                          sectionDividers: <PathSectionDivider>[
                            for (final PathDivider d in geom.dividers)
                              PathSectionDivider(label: d.label, y: d.y),
                          ],
                          bannerKicker: current.section,
                          bannerUnitTitle: current.unit,
                          reduceMotion: reduceMotion,
                          onGuide: () => _onGuide(context, current),
                          onNodeTap: (PathNodeData pd) {
                            if (pd.state != PathNodeState.locked) {
                              _showPreview(context, nodes[pd.index]);
                            }
                          },
                          activeNodeKey:
                              const ValueKey<String>('home-active-node'),
                        ),
                ),
              ],
            ),
            Positioned(
              right: RatelSpace.lg,
              bottom: RatelSpace.lg,
              child: _tutorPill(context, ref.watch(isProProvider)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, int streak, int diamonds,
      int streakFreezes, int unread, int energy, bool isPro) {
    return Container(
      key: const ValueKey<String>('tab-home'),
      color: context.palette.cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RatelTopBar(
                flagEmoji: '🦡',
                langCode: '',
                streak: streak,
                energyLabel: formatEnergy(energy, unlimited: isPro),
                diamonds: formatCount(diamonds),
                streakFreeze: streakFreezes > 0 ? streakFreezes : null,
                unreadNotifications: unread,
                onNotificationsTap: () => context.push('/notifications')),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(RatelSpace.xl),
                  child: Column(
                    key: ValueKey<String>('home-empty'),
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('🦡', style: TextStyle(fontSize: 48)),
                      SizedBox(height: RatelSpace.md),
                      Text('Your course is getting ready',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: RatelFont.display,
                              fontWeight: RatelType.extraBold,
                              fontSize: RatelType.screenTitle,
                              color: context.palette.ink)),
                      SizedBox(height: RatelSpace.xs),
                      Text('Lessons will appear here once your course content loads.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: RatelFont.body,
                              fontSize: RatelType.body,
                              color: context.palette.muted)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitBanner(BuildContext context, _Node n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          RatelSpace.screen, RatelSpace.sm, RatelSpace.screen, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: RatelSpace.lg, vertical: RatelSpace.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: <Color>[RatelColors.teal, RatelColors.tealDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(RatelRadius.feature),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(n.section,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.caption,
                        fontWeight: RatelType.semiBold,
                        color: RatelColors.onColor)),
                Text(n.unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.cardTitle,
                        color: RatelColors.onColor)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _onGuide(context, n),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: RatelSpace.md, vertical: RatelSpace.xs),
              decoration: BoxDecoration(
                  color: RatelColors.onColor,
                  borderRadius: BorderRadius.circular(RatelRadius.pill)),
              child: const Text('📖 Guide',
                  style: TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.semiBold,
                      fontSize: RatelType.small,
                      color: RatelColors.tealDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pathRow(BuildContext context, List<_Node> nodes, int i, int active,
      bool galaxy) {
    final _Node n = nodes[i];
    final bool done = n.globalIndex < active;
    final bool isActive = n.globalIndex == active;
    final double ax = kGalaxyPath[n.inUnit % 8];

    final List<Widget> col = <Widget>[];
    if (n.sectionStart) {
      col.add(Padding(
        padding: const EdgeInsets.only(top: RatelSpace.sm, bottom: RatelSpace.sm),
        child: RatelSectionHeader(label: n.section),
      ));
    }
    final double nodeSize = isActive ? 84 : 64;
    // Galaxy planets carry a ring + pod, so their rows get a little more height.
    final double trackHeight =
        isActive ? (galaxy ? 140 : 132) : (galaxy ? 110 : 104);
    Widget track = SizedBox(
      height: trackHeight,
      child: Align(
        alignment: Alignment(ax, 0),
        child: galaxy
            ? _galaxyNode(context, n, done, isActive)
            : _nodeCircle(context, n, done, isActive),
      ),
    );
    if (galaxy) {
      // The orbital trail connects this planet to its neighbours; a new section
      // (with its header) starts a fresh arc, so suppress the trail across a
      // section boundary.
      final bool hasPrev = i > 0 && !n.sectionStart;
      final bool hasNext =
          i < nodes.length - 1 && !nodes[i + 1].sectionStart;
      final double prevAx = i > 0 ? kGalaxyPath[nodes[i - 1].inUnit % 8] : ax;
      final double nextAx =
          i < nodes.length - 1 ? kGalaxyPath[nodes[i + 1].inUnit % 8] : ax;
      track = CustomPaint(
        painter: GalaxyPathPainter(
          ax: ax,
          prevAx: prevAx,
          nextAx: nextAx,
          hasPrev: hasPrev,
          hasNext: hasNext,
          nodeSize: nodeSize,
          done: done,
          seed: n.globalIndex + 1,
        ),
        child: track,
      );
    }
    col.add(track);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: col);
  }

  Widget _startPill() => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: RatelSpace.md, vertical: 6),
        decoration: BoxDecoration(
            color: RatelColors.amber,
            borderRadius: BorderRadius.circular(RatelRadius.pill)),
        child: const Text('START',
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.small,
                color: RatelColors.onColor)),
      );

  /// The galaxy-skin node (R-WT4): a [GalaxyPlanet], with the active planet
  /// carrying the START pill + the [PodTraveller] marker. Same state + tap
  /// behaviour as [_nodeCircle], only re-skinned.
  Widget _galaxyNode(
      BuildContext context, _Node n, bool done, bool isActive) {
    final double size = isActive ? 84 : 64;
    // R-WT7 (G3): animate the pod only when the reduce-motion HARD FLOOR allows
    // it — MediaQuery.disableAnimations folds the OS setting + the in-app toggle.
    final bool motion = !MediaQuery.of(context).disableAnimations;
    final String glyph = done
        ? '✓'
        : isActive
            ? '▶'
            : '🔒';
    final Widget planet = GalaxyPlanet(
      color: galaxyPlanetColor(n.globalIndex),
      size: size,
      glyph: glyph,
      lit: done || isActive,
    );
    if (!isActive) {
      return planet;
    }
    return GestureDetector(
      key: const ValueKey<String>('home-active-node'),
      onTap: () => _showPreview(context, n),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _startPill(),
          const SizedBox(height: RatelSpace.xs),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              planet,
              Positioned(
                right: -4,
                top: -12,
                child: PodTraveller(motion: motion),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nodeCircle(
      BuildContext context, _Node n, bool done, bool isActive) {
    final double size = isActive ? 84 : 64;
    final Color fill = done
        ? RatelColors.teal
        : isActive
            ? RatelColors.teal
            : context.palette.cream3;
    final String glyph = done
        ? '✓'
        : isActive
            ? '▶'
            : '🔒';
    final Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(
            color: isActive || done ? RatelColors.tealDark : context.palette.border,
            width: 3),
        boxShadow: <BoxShadow>[
          BoxShadow(color: context.palette.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(glyph,
          style: TextStyle(
              fontSize: isActive ? 30 : 24,
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              color: done || isActive ? RatelColors.onColor : context.palette.muted)),
    );

    if (!isActive) {
      return Opacity(opacity: done ? 1 : 0.85, child: circle);
    }

    return GestureDetector(
      key: const ValueKey<String>('home-active-node'),
      onTap: () => _showPreview(context, n),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: RatelSpace.md, vertical: 6),
            decoration: BoxDecoration(
                color: RatelColors.amber,
                borderRadius: BorderRadius.circular(RatelRadius.pill)),
            child: const Text('START',
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.small,
                    color: RatelColors.onColor)),
          ),
          const SizedBox(height: RatelSpace.xs),
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              circle,
              const Positioned(
                right: -10,
                top: -6,
                child: Text('🦡', style: TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📖 Guide (design §4.1 · plan §3.2): when the CURRENT unit carries an
  /// authored guide (unit.guide_ref → gloss text — pre-generated content, no
  /// live AI), open it in a sheet. Units without one keep the historic Library
  /// fallback, so legacy courses behave exactly as before.
  void _onGuide(BuildContext context, _Node n) {
    final String? guide = n.guideText;
    if (guide == null || guide.isEmpty) {
      context.go('/library');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(RatelRadius.featureLg))),
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(RatelSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('📖 UNIT GUIDE',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.caption,
                    fontWeight: RatelType.semiBold,
                    color: sheetContext.palette.muted)),
            const SizedBox(height: 4),
            Text(n.unit,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.screenTitle,
                    color: sheetContext.palette.ink)),
            const SizedBox(height: RatelSpace.md),
            Flexible(
              child: SingleChildScrollView(
                child: Text(guide,
                    key: const ValueKey<String>('home-guide-text'),
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.body,
                        height: 1.45,
                        color: sheetContext.palette.ink)),
              ),
            ),
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
              label: 'Done',
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview(BuildContext context, _Node n) {
    final String exLabel =
        n.exercises == 1 ? '1 exercise' : '${n.exercises} exercises';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(RatelRadius.featureLg))),
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(RatelSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('UNIT · ${n.unit.toUpperCase()}',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.caption,
                    fontWeight: RatelType.semiBold,
                    color: context.palette.muted)),
            const SizedBox(height: 4),
            Text(n.lesson,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.screenTitle,
                    color: context.palette.ink)),
            const SizedBox(height: 4),
            Text('Lesson ${n.lessonNum} of ${n.lessonCount} · $exLabel · ${n.cefr}.',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.muted)),
            const SizedBox(height: RatelSpace.md),
            const RatelChip(
                label: '+20 XP', tone: RatelChipTone.green, filled: true),
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
              label: 'Start lesson',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push('/daily-quiz?lesson=${Uri.encodeComponent(n.id)}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tutorPill(BuildContext context, bool isPro) {
    return GestureDetector(
      onTap: () => context.push('/tutor'),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: RatelSpace.lg, vertical: RatelSpace.md),
        decoration: BoxDecoration(
          color: RatelColors.tealDark,
          borderRadius: BorderRadius.circular(RatelRadius.pill),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: context.palette.shadow, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🦡 Tutor',
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.body,
                    color: RatelColors.onColor)),
            if (!isPro) ...<Widget>[
              const SizedBox(width: RatelSpace.sm),
              RatelChip.pro(),
            ],
          ],
        ),
      ),
    );
  }

  static String _flagFor(String code) {
    switch (code) {
      case 'es':
        return '🇪🇸';
      case 'en':
        return '🇬🇧';
      case 'ja':
        return '🇯🇵';
      case 'ta':
        return '🇮🇳';
      default:
        return '🦡';
    }
  }

  static String _langFor(String code) => code.toUpperCase();
}

/// One lesson node on the path (authored content + REAL position).
class _Node {
  const _Node({
    required this.id,
    required this.section,
    required this.unit,
    required this.lesson,
    required this.cefr,
    required this.exercises,
    required this.globalIndex,
    required this.lessonNum,
    required this.lessonCount,
    required this.inUnit,
    required this.sectionStart,
    this.guideText,
  });

  final String id;
  final String section;
  final String unit;
  final String lesson;
  final String cefr;
  final int exercises;
  final int globalIndex;
  final int lessonNum;
  final int lessonCount;
  final int inUnit;
  final bool sectionStart;
  final String? guideText;
}
