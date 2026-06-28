import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';

/// Home tab (🏠) — the learning path, design spec §4.1. A Duolingo-style winding
/// path of lesson nodes. The node STATES (done / active / locked) are 100% REAL:
/// derived from `lessonsCompleted` on the learner snapshot — a fresh account has
/// node 0 active and everything after it locked. Tapping the active node opens
/// the lesson-preview sheet (§4.6).
///
/// HONESTY: the curriculum OUTLINE below (unit + lesson names) is authored
/// starter course content — NOT fabricated user progress. The full content-
/// driven spine (units/lessons served from the `lib/content` seed batch through
/// the content layer) is a follow-up; it needs the codegen content models, which
/// are intentionally kept out of this locally-gated feature layer for now.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<({String section, String unit, List<String> lessons})>
      _outline = <({String section, String unit, List<String> lessons})>[
    (
      section: 'SECTION 1 · BASICS',
      unit: 'Greetings',
      lessons: <String>['Hello & goodbye', 'Introduce yourself', 'Polite words']
    ),
    (
      section: 'SECTION 1 · BASICS',
      unit: 'At the café',
      lessons: <String>['Order a drink', 'Numbers 1–10', 'Pay the bill']
    ),
    (
      section: 'SECTION 2 · GETTING AROUND',
      unit: 'At the market',
      lessons: <String>['Fruit & veg', 'How much is it?', 'Colours']
    ),
    (
      section: 'SECTION 2 · GETTING AROUND',
      unit: 'Directions',
      lessons: <String>['Left & right', 'Where is…?', 'On the metro']
    ),
  ];

  static List<_Node> _flatten() {
    final List<_Node> out = <_Node>[];
    int gi = 0;
    String? lastSection;
    for (final ({String section, String unit, List<String> lessons}) u
        in _outline) {
      final bool sectionStart = u.section != lastSection;
      lastSection = u.section;
      for (int i = 0; i < u.lessons.length; i++) {
        out.add(_Node(
          section: u.section,
          unit: u.unit,
          lesson: u.lessons[i],
          globalIndex: gi,
          lessonNum: i + 1,
          lessonCount: u.lessons.length,
          inUnit: i,
          unitStart: i == 0,
          sectionStart: sectionStart && i == 0,
        ));
        gi++;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final List<_Node> nodes = _flatten();
    final int active = snap.lessonsCompleted;
    final _Node current = nodes[active.clamp(0, nodes.length - 1)];

    return Container(
      key: const ValueKey<String>('tab-home'),
      color: RatelColors.cream,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                RatelTopBar(
                    flagEmoji: '🇪🇸', langCode: 'ES', streak: snap.streakDays),
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
            : RatelColors.cream3;
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
            color: isActive || done ? RatelColors.tealDark : RatelColors.border,
            width: 3),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: RatelColors.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(glyph,
          style: TextStyle(
              fontSize: isActive ? 30 : 24,
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              color: done || isActive ? RatelColors.onColor : RatelColors.muted)),
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: RatelColors.white,
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
                style: const TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.caption,
                    fontWeight: RatelType.semiBold,
                    color: RatelColors.muted)),
            const SizedBox(height: 4),
            Text(n.lesson,
                style: const TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.screenTitle,
                    color: RatelColors.ink)),
            const SizedBox(height: 4),
            Text(
                'Lesson ${n.lessonNum} of ${n.lessonCount} · 8 quick exercises.',
                style: const TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: RatelColors.muted)),
            const SizedBox(height: RatelSpace.md),
            const RatelChip(
                label: '+20 XP', tone: RatelChipTone.green, filled: true),
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
              label: 'Start lesson',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push('/daily-quiz');
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
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: RatelColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
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
}

/// One lesson node on the path (authored outline + REAL position).
class _Node {
  const _Node({
    required this.section,
    required this.unit,
    required this.lesson,
    required this.globalIndex,
    required this.lessonNum,
    required this.lessonCount,
    required this.inUnit,
    required this.unitStart,
    required this.sectionStart,
  });

  final String section;
  final String unit;
  final String lesson;
  final int globalIndex;
  final int lessonNum;
  final int lessonCount;
  final int inUnit;
  final bool unitStart;
  final bool sectionStart;
}
