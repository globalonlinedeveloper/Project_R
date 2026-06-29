import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';

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
    for (final CourseUnit u in spine.units) {
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
          sectionStart: i == 0,
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

    if (spine.isEmpty) {
      return _emptyState(context, snap.streakDays, snap.diamonds, snap.streakFreezes, unread);
    }

    final List<_Node> nodes = _flatten(spine);
    final int active = snap.lessonsCompleted;
    final _Node current = nodes[active.clamp(0, nodes.length - 1)];

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
                    diamonds: '${snap.diamonds}',
                    streakFreeze:
                        snap.streakFreezes > 0 ? snap.streakFreezes : null,
                    unreadNotifications: unread,
                    onNotificationsTap: () => context.push('/notifications')),
                _unitBanner(context, current),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, 96),
                    itemCount: nodes.length,
                    itemBuilder: (BuildContext context, int i) =>
                        _pathRow(context, nodes[i], active),
                  ),
                ),
              ],
            ),
            Positioned(
              right: RatelSpace.lg,
              bottom: RatelSpace.lg,
              child: _tutorPill(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, int streak, int diamonds, int streakFreezes, int unread) {
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
                diamonds: '$diamonds',
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
            onTap: () => context.go('/library'),
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

  Widget _pathRow(BuildContext context, _Node n, int active) {
    final bool done = n.globalIndex < active;
    final bool isActive = n.globalIndex == active;
    final double ax =
        const <double>[0.0, 0.5, 0.8, 0.5, 0.0, -0.5, -0.8, -0.5][n.inUnit % 8];

    final List<Widget> col = <Widget>[];
    if (n.sectionStart) {
      col.add(Padding(
        padding: const EdgeInsets.only(top: RatelSpace.sm, bottom: RatelSpace.sm),
        child: RatelSectionHeader(label: n.section),
      ));
    }
    col.add(SizedBox(
      height: isActive ? 132 : 104,
      child: Align(
        alignment: Alignment(ax, 0),
        child: _nodeCircle(context, n, done, isActive),
      ),
    ));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: col);
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

  Widget _tutorPill(BuildContext context) {
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
        child: const Text('🦡 Tutor',
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.body,
                color: RatelColors.onColor)),
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
}
