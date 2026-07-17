import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:country_flags/country_flags.dart';

import 'package:ratel/app/course_switch.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learner/learner_controller.dart';
import 'package:ratel/services/preferences/ui_locale.dart';
import 'package:ratel/services/preferences/immersion_mode.dart';

/// Courses screen (🌍) — design #7/#8 / lane A-C (`/courses`).
///
/// A real, dedicated Courses list. The switchable courses + the switch action
/// come from [CourseSwitchScope] (the same manifest-derived source the Settings
/// course-picker uses, `settings_screen.dart` `_pickCourse`) — so this screen
/// reuses the REAL restart-free switch logic, not a new mechanism.
///
/// LAYOUT (INC-12, Duolingo split):
///  * LEARNING = the CURRENT course only, shown as a rich card: flag + endonym
///    name + its REAL XP + an "Active" chip.
///  * ADD A COURSE = the OTHER `available` courses, each a row with a "Switch"
///    affordance (the real [CourseSwitchScope.switchCourse]). A search field
///    filters this list (by name or code) over the REAL shipped `available`
///    list only — never a fabricated "50+" catalog.
///
/// HONEST decisions (still UI-only — no per-course backend yet, that is
/// INC-15):
///  * There is a SINGLE global learner state (`learnerControllerProvider`), so
///    only the CURRENT course actually has XP. We show the current course's
///    REAL [LearnerSnapshot.xpTotal] on its LEARNING card; we show NO XP on the
///    ADD rows (inventing per-course XP for a non-current course would be a
///    lie). No per-course "Level A2" is shown — CEFR is hidden difficulty
///    metadata, never a user-facing label.
///  * The amber banner stays honest: streak & XP are SHARED across courses and
///    switching never loses progress (it does NOT promise per-course XP — that
///    becomes true only at INC-15).
///  * "ADD A COURSE" is NOT a live 52-language catalog: RATEL only ships the
///    bundled courses, so an honest note stands in for a fake catalog / count.
///  * Menu language (DISPLAY): the REAL app-shell language control lives INLINE
///    here (INC-13) — the row shows the current menu language and taps open an
///    in-place picker over [kUiLanguageEndonyms] that drives
///    `uiLocaleControllerProvider.setLocale` (the SAME restart-free control
///    Settings uses; `MaterialApp.locale`). No `/settings` deep-link.
///  * Immersion (DISPLAY, below the menu-language row): a REAL toggle
///    (INC-14). When the CURRENT course target is one of the 10 translated
///    chrome locales ([kUiLanguageEndonyms]), turning it ON sets the app
///    interface to that language (`setLocale(Locale(courseCode))`) and
///    persists the flag; OFF returns to the device / menu language
///    (`setLocale(null)`). For an UNTRANSLATED target (es · ta — shipped as
///    COURSES but with no chrome ARB) the toggle is shown DISABLED with an
///    honest reason, never faked.
///
/// Reached from Settings (the Course row) and any future Home entry.
class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// The ADD list = every available course except the current one, filtered by
  /// the (case-insensitive) query over the localized NAME or the raw CODE.
  List<String> _addCourses(BuildContext context, CourseSwitchScope course) {
    final String q = _query.trim().toLowerCase();
    return course.available.where((String code) {
      if (code == course.current) return false;
      if (q.isEmpty) return true;
      final String name = ratelCourseLanguageName(context, code).toLowerCase();
      return name.contains(q) || code.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final CourseSwitchScope? course = CourseSwitchScope.maybeOf(context);
    final int xpTotal =
        ref.watch(learnerControllerProvider.select((LearnerSnapshot s) => s.xpTotal));
    final List<String> addCourses =
        course == null ? const <String>[] : _addCourses(context, course);

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
            // ── LEARNING (the current course only) ──────────────────────────
            Padding(
              padding: const EdgeInsets.only(
                  left: RatelSpace.sm, bottom: RatelSpace.sm),
              child: RatelSectionHeader(
                  label: context.l10n.coursesLearningHeader),
            ),
            if (course != null) _currentCourseCard(context, course, xpTotal),
            const SizedBox(height: RatelSpace.md),
            _sharedProgressBanner(context),
            const SizedBox(height: RatelSpace.lg),
            // ── ADD A COURSE (the rest, with browse/search) ─────────────────
            Padding(
              padding: const EdgeInsets.only(
                  left: RatelSpace.sm, bottom: RatelSpace.sm),
              child:
                  RatelSectionHeader(label: context.l10n.coursesAddHeader),
            ),
            _searchField(context),
            const SizedBox(height: RatelSpace.sm),
            if (course != null)
              for (final String code in addCourses) ...<Widget>[
                _addCourseRow(context, course, code),
                const SizedBox(height: RatelSpace.xs),
              ],
            const SizedBox(height: RatelSpace.sm),
            _addHonestNote(context),
            const SizedBox(height: RatelSpace.lg),
            // ── DISPLAY (interface language lives in Settings — INC-13/14) ──
            Padding(
              padding: const EdgeInsets.only(
                  left: RatelSpace.sm, bottom: RatelSpace.sm),
              child: RatelSectionHeader(
                  label: context.l10n.coursesDisplayHeader),
            ),
            RatelListRow(
              key: const ValueKey<String>('courses-menu-language'),
              leadingEmoji: '🗣️',
              title: context.l10n.coursesMenuLanguage,
              subtitle: _menuLanguageLabel(context),
              onTap: () => _pickMenuLanguage(context),
            ),
            if (course != null) _immersionRow(context, course),
          ],
        ),
      ),
    );
  }

  /// The LEARNING card: the CURRENT course with flag + endonym + REAL XP + the
  /// "Active" chip. This is the only place XP is shown (it is the only course
  /// with real progress under today's single global learner state).
  Widget _currentCourseCard(
      BuildContext context, CourseSwitchScope course, int xpTotal) {
    return RatelCard(
      color: context.palette.white,
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RatelColors.teal.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(courseFlagEmoji(course.current),
                style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ratelCourseLanguageName(context, course.current),
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.cardTitle,
                    color: context.palette.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.coursesXpTotal(xpTotal),
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontWeight: RatelType.semiBold,
                    fontSize: RatelType.small,
                    color: context.palette.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RatelSpace.sm),
          RatelChip(
            label: context.l10n.coursesActive,
            tone: RatelChipTone.teal,
            filled: true,
          ),
        ],
      ),
    );
  }

  /// An ADD row: flag + name + a "Switch" affordance. No XP (a non-current
  /// course has no real per-course progress yet).
  Widget _addCourseRow(
      BuildContext context, CourseSwitchScope course, String code) {
    return RatelListRow(
      leadingEmoji: courseFlagEmoji(code),
      title: ratelCourseLanguageName(context, code),
      trailing: Text(
        context.l10n.coursesSwitch,
        style: TextStyle(
          fontFamily: RatelFont.display,
          fontWeight: RatelType.extraBold,
          fontSize: RatelType.small,
          color: RatelColors.teal,
        ),
      ),
      onTap: () {
        unawaited(course.switchCourse(code));
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Text(context.l10n
                  .coursesSwitchedTo(ratelCourseLanguageName(context, code)))));
      },
    );
  }

  Widget _searchField(BuildContext context) {
    return TextField(
      key: const ValueKey<String>('courses-search'),
      controller: _searchController,
      onChanged: (String value) => setState(() => _query = value),
      style: TextStyle(
        fontFamily: RatelFont.body,
        fontSize: RatelType.body,
        color: context.palette.ink,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: context.l10n.coursesSearchHint,
        hintStyle: TextStyle(
          fontFamily: RatelFont.body,
          fontSize: RatelType.body,
          color: context.palette.muted,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: RatelSpace.md, right: RatelSpace.sm),
          child: Text('🔍', style: TextStyle(fontSize: 16)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: context.palette.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: RatelSpace.md, vertical: RatelSpace.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RatelRadius.card),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RatelRadius.card),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _addHonestNote(BuildContext context) {
    return RatelCard(
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

  // ── DISPLAY · inline menu-language control (INC-13) ─────────────────────────
  // The REAL app-shell language lives here now: the row shows the current menu
  // language and tapping opens an in-place picker over [kUiLanguageEndonyms]
  // that calls `uiLocaleControllerProvider.setLocale` — the SAME restart-free
  // control Settings uses (drives `MaterialApp.locale`). NO `/settings` hop.
  //
  // Presentation is a short duplicate of the Settings app-language sheet
  // (`settings_screen.dart` `_pickAppLanguage`): an SVG country flag + an
  // English-name·country subtitle, endonym as the primary label, a leading
  // "system default" row (null override). Duplicated — not a shared helper —
  // because the Settings picker is a set of private/static members on a
  // `ConsumerWidget` with a DIFFERENT section header (`settingsAppLanguage` vs
  // `coursesMenuLanguage`); a ~60-line copy keeps Settings byte-identical and
  // is lower-risk than parameterising a shared builder (INC-13 directive).

  /// The row's shown current menu language: the endonym of the active override,
  /// or Settings' own "System default" label when following the device (null).
  String _menuLanguageLabel(BuildContext context) {
    final Locale? l = ref.watch(uiLocaleControllerProvider);
    return l == null
        ? context.l10n.settingsAppLanguageSystem
        : (kUiLanguageEndonyms[l.languageCode] ?? l.languageCode);
  }

  Widget? _menuLangFlag(String code) {
    final ({String country, String english, String countryName})? m =
        kUiLanguageFlag[code];
    if (m == null) return null;
    return CountryFlag.fromCountryCode(
      m.country,
      width: 34,
      height: 26,
      shape: const RoundedRectangle(4),
    );
  }

  String? _menuLangSubtitle(String code) {
    final ({String country, String english, String countryName})? m =
        kUiLanguageFlag[code];
    return m == null ? null : '${m.english} · ${m.countryName}';
  }

  Widget _menuLangSelectedMark(bool selected) => selected
      ? const Text(
          '✓',
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontSize: 20,
            fontWeight: RatelType.extraBold,
            color: RatelColors.teal,
          ),
        )
      : const SizedBox.shrink();

  /// Opens the in-place menu-language picker (a modal bottom sheet on THIS
  /// screen — never a navigation). Each row calls the real
  /// [UiLocaleController.setLocale], flipping `MaterialApp.locale` restart-free.
  void _pickMenuLanguage(BuildContext context) {
    final UiLocaleController controller =
        ref.read(uiLocaleControllerProvider.notifier);
    final String? current = ref.read(uiLocaleControllerProvider)?.languageCode;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RatelRadius.featureLg),
        ),
      ),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: RatelSpace.sm,
                  bottom: RatelSpace.sm,
                ),
                child: RatelSectionHeader(
                  label: context.l10n.coursesMenuLanguage,
                ),
              ),
              Flexible(
                child: ListView(
                  key: const ValueKey<String>('courses-menu-language-sheet'),
                  shrinkWrap: true,
                  children: <Widget>[
                    RatelListRow(
                      leadingEmoji: '\u{1F310}',
                      title: context.l10n.settingsAppLanguageSystem,
                      trailing: _menuLangSelectedMark(current == null),
                      onTap: () {
                        controller.setLocale(null);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    const SizedBox(height: RatelSpace.xs),
                    for (final MapEntry<String, String> e
                        in kUiLanguageEndonyms.entries) ...<Widget>[
                      RatelListRow(
                        leading: _menuLangFlag(e.key),
                        title: e.value,
                        subtitle: _menuLangSubtitle(e.key),
                        trailing: _menuLangSelectedMark(e.key == current),
                        onTap: () {
                          controller.setLocale(Locale(e.key));
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                      const SizedBox(height: RatelSpace.xs),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DISPLAY · immersion toggle (INC-14, honest partial) ─────────────────────
  // A REAL toggle below the menu-language row. Immersion = "learn with the app
  // interface in the language you're studying": ON sets the app-shell chrome to
  // the CURRENT course's target language, OFF returns to the device / menu
  // language. It reuses the SAME restart-free control INC-13 uses
  // (`UiLocaleController.setLocale`, wired to `MaterialApp.locale`) — immersion
  // and the menu-language row deliberately share `uiLocale`.
  //
  // HONESTY: immersion only works for a target that HAS a translated chrome ARB
  // — i.e. a course code in [kUiLanguageEndonyms] (the 10 real UI languages).
  // The 12 shipped COURSES include es (Spanish) and ta (Tamil), which have NO
  // translated interface, so for those the toggle is shown DISABLED with a
  // specific honest reason. It is NEVER enabled/faked for an untranslated
  // target.

  /// The current course target can be immersed IFF the app is actually
  /// translated into it — i.e. its code is one of the 10 chrome ARB locales.
  bool _supportsImmersion(String courseCode) =>
      kUiLanguageEndonyms.containsKey(courseCode);

  /// The DISPLAY immersion row. Enabled + interactive for a translated target;
  /// disabled + muted with an honest reason for an untranslated one (es · ta).
  Widget _immersionRow(BuildContext context, CourseSwitchScope course) {
    final String code = course.current;
    final bool supported = _supportsImmersion(code);
    // Immersion can only genuinely be ON for a supported target; for an
    // unsupported one the flag is meaningless, so render it OFF.
    final bool on = supported && ref.watch(immersionModeProvider);

    return RatelListRow(
      key: const ValueKey<String>('courses-immersion'),
      leadingEmoji: '\u{1F30A}', // 🌊 immersion
      title: context.l10n.coursesImmersionMode,
      subtitle: supported
          ? context.l10n.coursesImmersionSub
          : context.l10n.coursesImmersionUnsupported(
              ratelCourseLanguageName(context, code)),
      trailing: RatelToggle(
        value: on,
        // null onChanged ⇒ the toggle is non-interactive and visually muted:
        // the HONEST disabled surface for an untranslated target.
        onChanged: supported
            ? (bool next) => _setImmersion(code, next)
            : null,
      ),
    );
  }

  /// Applies an immersion toggle: flips the SHARED app-shell locale through the
  /// real [UiLocaleController] (target language on / device on off) and persists
  /// the immersion flag. Manual action — no reactive per-build enforcement.
  void _setImmersion(String courseCode, bool enabled) {
    ref
        .read(uiLocaleControllerProvider.notifier)
        .setLocale(enabled ? Locale(courseCode) : null);
    ref.read(immersionModeProvider.notifier).setEnabled(enabled);
  }
}
