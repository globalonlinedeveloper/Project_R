import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/course_switch.dart';
import 'package:ratel/core/core.dart';

/// Courses screen (🌍) — design #7/#8 / lane A-C (`/courses`).
///
/// A real, dedicated Courses list. The switchable courses + the switch action
/// come from [CourseSwitchScope] (the same manifest-derived source the Settings
/// course-picker uses, `settings_screen.dart` `_pickCourse`) — so this screen
/// reuses the REAL restart-free switch logic, not a new mechanism.
///
/// HONEST decisions:
///  * Per-course "Level A2 · 1,240 XP" rows are NOT shown. XP and streak are
///    GLOBAL / shared across courses (there is no per-course progress model,
///    §9.5 "needs modeling"), so faking a per-course level/XP would be a lie.
///    Instead the design's own amber reassurance banner — "streak & XP are
///    shared across courses" (A-C3) — carries the honest message.
///  * "ADD A COURSE" + "Browse all languages · 50+ courses" is NOT a live
///    catalog: RATEL only ships the bundled courses, so an honest note stands
///    in for a fake catalog / count.
///  * Menu language / Immersion mode: the interface-language control lives in
///    Settings (real); this screen links there rather than duplicating it, and
///    does not invent an Immersion toggle that has no backend.
///
/// Reached from Settings (the Course row) and any future Home entry.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseSwitchScope? course = CourseSwitchScope.maybeOf(context);

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: RatelSpace.md),
          child: GestureDetector(
            key: const ValueKey<String>('courses-back'),
            onTap: () => context.pop(),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: context.palette.white,
              child: Icon(RatelIcons.arrowBack,
                  color: context.palette.ink, size: 20),
            ),
          ),
        ),
        title: Text(
          context.l10n.coursesTitle,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const ValueKey<String>('screen-courses'),
          padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.md,
              RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: RatelSpace.sm, bottom: RatelSpace.sm),
              child: RatelSectionHeader(
                  label: context.l10n.coursesLearningHeader),
            ),
            if (course != null)
              for (final String code in course.available) ...<Widget>[
                _courseRow(context, course, code),
                const SizedBox(height: RatelSpace.sm),
              ],
            const SizedBox(height: RatelSpace.sm),
            _sharedProgressBanner(context),
            const SizedBox(height: RatelSpace.lg),
            Padding(
              padding: const EdgeInsets.only(
                  left: RatelSpace.sm, bottom: RatelSpace.sm),
              child:
                  RatelSectionHeader(label: context.l10n.coursesAddHeader),
            ),
            RatelCard(
              color: context.palette.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('🌐', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: RatelSpace.md),
                  Expanded(
                    child: Text(
                      context.l10n.coursesAddHonest,
                      style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        height: 1.35,
                        color: context.palette.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RatelSpace.lg),
            Padding(
              padding: const EdgeInsets.only(
                  left: RatelSpace.sm, bottom: RatelSpace.sm),
              child: RatelSectionHeader(
                  label: context.l10n.coursesDisplayHeader),
            ),
            RatelListRow(
              leadingEmoji: '🗣️',
              title: context.l10n.coursesMenuLanguage,
              subtitle: context.l10n.coursesMenuLanguageSub,
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseRow(
      BuildContext context, CourseSwitchScope course, String code) {
    final bool active = code == course.current;
    return RatelListRow(
      leadingEmoji: courseFlagEmoji(code),
      title: ratelCourseLanguageName(context, code),
      trailing: active
          ? RatelChip(
              label: context.l10n.coursesActive,
              tone: RatelChipTone.teal,
              filled: true,
            )
          : Text(
              context.l10n.coursesSwitch,
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.small,
                color: RatelColors.teal,
              ),
            ),
      onTap: active
          ? null
          : () {
              unawaited(course.switchCourse(code));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text(context.l10n.coursesSwitchedTo(
                        ratelCourseLanguageName(context, code)))));
            },
    );
  }

  Widget _sharedProgressBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RatelSpace.cardPad),
      decoration: BoxDecoration(
        color: RatelColors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(RatelRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Text(
              context.l10n.coursesSharedProgress,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontWeight: RatelType.semiBold,
                fontSize: RatelType.small,
                height: 1.35,
                color: context.palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
