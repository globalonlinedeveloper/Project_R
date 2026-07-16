import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:country_flags/country_flags.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/course_switch.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/billing/billing.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/ui_locale.dart';

/// Settings (design spec §4.9) — REAL where an engine exists: daily goal, sound,
/// high contrast and haptics are read from and written back through the
/// `preferences` engine (persisted on-device via the settings store). The
/// notifications block has no engine (§6) and is an honest stub; subscription
/// reflects the real billing entitlement; log-out reflects the real identity
/// (a guest sees "Not signed in").
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<({String label, int xp})> _goals =
      <({String label, int xp})>[
        (label: 'Casual', xp: 10),
        (label: 'Regular', xp: 20),
        (label: 'Serious', xp: 30),
        (label: 'Intense', xp: 50),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings s = ref.watch(appSettingsControllerProvider);
    final AppSettingsController c = ref.read(
      appSettingsControllerProvider.notifier,
    );
    final DailyGoalStatus goalStatus = ref.watch(dailyGoalProvider);
    final bool isPro = ref.watch(isProProvider);
    final Identity identity = ref.watch(identityProvider);

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(RatelIcons.arrowBack, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.settingsTitle,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          RatelSpace.screen,
          RatelSpace.sm,
          RatelSpace.screen,
          RatelSpace.xl,
        ),
        children: <Widget>[
          _section(context, context.l10n.settingsSectionLearning, <Widget>[
            RatelListRow(
              title: context.l10n.settingsDailyGoal,
              subtitle: goalStatus.met
                  ? context.l10n.settingsGoalReachedSub(s.dailyGoal)
                  : context.l10n.settingsGoalPerDay(s.dailyGoal),
              onTap: () => _pickGoal(context, c, s.dailyGoal),
            ),
            _switchRow(context.l10n.settingsSoundEffects, s.sound, c.setSound),
            _switchRow(context.l10n.settingsHaptics, s.haptics, c.setHaptics),
          ]),
          const SizedBox(height: RatelSpace.lg),
          _section(context, context.l10n.settingsSectionSubscription, <Widget>[
            RatelListRow(
              title: context.l10n.paywallManage,
              subtitle: isPro
                  ? context.l10n.settingsProActive
                  : context.l10n.settingsFreePlan,
              onTap: () {
                if (isPro) {
                  ref.read(manageSubscriptionProvider).open().then((
                    ManageResult r,
                  ) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            r.isAvailable
                                ? r.message
                                : context.l10n.settingsManageUnavailable,
                          ),
                        ),
                      );
                  });
                } else {
                  context.push('/paywall?source=settings');
                }
              },
            ),
          ]),
          const SizedBox(height: RatelSpace.lg),
          _section(context, context.l10n.settingsSectionAccessibility, <Widget>[
            _switchRow(
              context.l10n.settingsReduceMotion,
              s.reduceMotion,
              c.setReduceMotion,
              subtitle: context.l10n.settingsReduceMotionSub,
            ),
            _switchRow(
              context.l10n.settingsHighContrast,
              s.highContrast,
              c.setHighContrast,
            ),
          ]),
          const SizedBox(height: RatelSpace.lg),
          _section(context, context.l10n.settingsSectionNotifications, <Widget>[
            _switchRow(
              context.l10n.settingsNotifPush,
              s.notifyEnabled('push'),
              (bool v) => c.setNotification('push', v),
            ),
            _switchRow(
              context.l10n.settingsNotifStreak,
              s.notifyEnabled('streak'),
              (bool v) => c.setNotification('streak', v),
            ),
            _switchRow(
              context.l10n.settingsNotifLeague,
              s.notifyEnabled('league'),
              (bool v) => c.setNotification('league', v),
            ),
            _switchRow(
              context.l10n.settingsNotifFriend,
              s.notifyEnabled('friend'),
              (bool v) => c.setNotification('friend', v),
            ),
          ]),
          const SizedBox(height: RatelSpace.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RatelSpace.xs),
            child: Text(
              context.l10n.settingsNotifFootnote,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.small,
                color: context.palette.muted,
              ),
            ),
          ),
          const SizedBox(height: RatelSpace.lg),
          _section(
            context,
            context.l10n.settingsSectionAppearanceAccount,
            <Widget>[
              if (CourseSwitchScope.maybeOf(context)
                  case final CourseSwitchScope course)
                RatelListRow(
                  leadingEmoji: '🌍',
                  leadingColor: RatelColors.green,
                  title: context.l10n.settingsCourse,
                  subtitle: _courseLabel(context, course.current),
                  // A-C1: the Course row now opens the dedicated Courses
                  // screen (real switch + shared-progress note) instead of
                  // the inline picker sheet.
                  onTap: () => context.push('/courses'),
                ),
              // L-2: app-shell (chrome) language — separate concept from the
              // Course (target language) row above; device-local override.
              RatelListRow(
                leadingEmoji: '🗣️',
                leadingColor: RatelColors.teal,
                title: context.l10n.settingsAppLanguage,
                subtitle: _appLanguageLabel(context, ref),
                onTap: () => _pickAppLanguage(context, ref),
              ),
              RatelListRow(
                leadingEmoji: '🌙',
                leadingColor: RatelColors.purple,
                title: context.l10n.settingsTheme,
                subtitle: _themeLabel(context, s.themeMode),
                onTap: () => _pickTheme(context, c, s.themeMode),
              ),
              RatelListRow(
                leadingEmoji: '🌌',
                leadingColor: RatelColors.blue,
                title: context.l10n.settingsWorld,
                subtitle: _worldLabel(context, s.worldTheme),
                onTap: () => context.push('/themes'),
              ),
              RatelListRow(
                leadingEmoji: '👤',
                leadingColor: RatelColors.blue,
                title: context.l10n.settingsEditProfile,
                onTap: () => context.push('/edit-profile'),
              ),
              RatelListRow(
                leadingEmoji: '🔒',
                leadingColor: RatelColors.teal,
                title: context.l10n.settingsPrivacy,
                subtitle: 'learnwithratel.com/privacy',
                onTap: () =>
                    _openUrl(context, 'https://learnwithratel.com/privacy'),
              ),
              RatelListRow(
                leadingEmoji: '❓',
                leadingColor: RatelColors.green,
                title: context.l10n.settingsHelp,
                subtitle: 'learnwithratel.com/help',
                onTap: () =>
                    _openUrl(context, 'https://learnwithratel.com/help'),
              ),
              RatelListRow(
                leadingEmoji: identity.isAuthenticated ? '🚪' : '✨',
                leadingColor: RatelColors.coral,
                title: identity.isAuthenticated
                    ? context.l10n.settingsLogOut
                    : context.l10n.profileCreateAccount,
                subtitle: identity.isAuthenticated
                    ? null
                    : context.l10n.settingsGuestSub,
                onTap: () => context.push('/onboarding'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final bool ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (ok || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.settingsCouldNotOpen(url))),
      );
  }

  /// One settings section (E-8): a small-caps header + a single grouped
  /// [RatelCard] whose rows are separated by hairline dividers (design §4.9).
  /// Honest/additive rows (World, Course) stay (§D-4).
  Widget _section(BuildContext context, String label, List<Widget> rows) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(
          Divider(height: 1, thickness: 1, color: context.palette.border),
        );
      }
      children.add(rows[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RatelSectionHeader(label: label),
        const SizedBox(height: RatelSpace.sm),
        RatelCard(
          padding: const EdgeInsets.symmetric(horizontal: RatelSpace.cardPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }

  /// A plain toggle row for inside a section card — no leading emoji (design
  /// §4.9 toggle rows are plain): title (+ optional [subtitle]) + a trailing
  /// [RatelToggle].
  Widget _switchRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    String? subtitle,
  }) => RatelListRow(
    title: title,
    subtitle: subtitle,
    trailing: RatelToggle(value: value, onChanged: onChanged),
  );

  void _pickGoal(BuildContext context, AppSettingsController c, int current) {
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
                  label: context.l10n.settingsDailyGoal,
                ),
              ),
              for (final ({String label, int xp}) g in _goals) ...<Widget>[
                RatelListRow(
                  leadingEmoji: g.xp == current ? '✅' : '⚪',
                  title: context.l10n.settingsGoalRow(
                    ratelGoalDisplayLabel(context, g.label),
                    g.xp,
                  ),
                  onTap: () {
                    c.setDailyGoal(g.xp);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                const SizedBox(height: RatelSpace.xs),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _appLanguageLabel(BuildContext context, WidgetRef ref) {
    final Locale? l = ref.watch(uiLocaleControllerProvider);
    return l == null
        ? context.l10n.settingsAppLanguageSystem
        : (kUiLanguageEndonyms[l.languageCode] ?? l.languageCode);
  }

  // Option A app-language picker decoration: an SVG country flag (NOT emoji —
  // regional-indicator emoji render broken on Flutter web / Chrome-Windows) +
  // an English-name·country subtitle. Endonym stays the primary label.
  static Widget? _appLangFlag(String code) {
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

  static String? _appLangSubtitle(String code) {
    final ({String country, String english, String countryName})? m =
        kUiLanguageFlag[code];
    return m == null ? null : '${m.english} · ${m.countryName}';
  }

  static Widget _appLangSelectedMark(BuildContext context, bool selected) =>
      selected
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

  void _pickAppLanguage(BuildContext context, WidgetRef ref) {
    final UiLocaleController c = ref.read(uiLocaleControllerProvider.notifier);
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
                  label: context.l10n.settingsAppLanguage,
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    RatelListRow(
                      leadingEmoji: '🌐',
                      title: context.l10n.settingsAppLanguageSystem,
                      trailing: _appLangSelectedMark(
                        sheetContext,
                        current == null,
                      ),
                      onTap: () {
                        c.setLocale(null);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    const SizedBox(height: RatelSpace.xs),
                    for (final MapEntry<String, String> e
                        in kUiLanguageEndonyms.entries) ...<Widget>[
                      RatelListRow(
                        leading: _appLangFlag(e.key),
                        title: e.value,
                        subtitle: _appLangSubtitle(e.key),
                        trailing: _appLangSelectedMark(
                          sheetContext,
                          e.key == current,
                        ),
                        onTap: () {
                          c.setLocale(Locale(e.key));
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

  static String _themeLabel(BuildContext context, ThemeMode m) => switch (m) {
    ThemeMode.system => context.l10n.settingsThemeSystem,
    ThemeMode.light => context.l10n.settingsThemeLight,
    ThemeMode.dark => context.l10n.settingsThemeDark,
  };

  static const List<({String label, ThemeMode mode, String emoji})> _themes =
      <({String label, ThemeMode mode, String emoji})>[
        (label: 'Match device', mode: ThemeMode.system, emoji: '📱'),
        (label: 'Light', mode: ThemeMode.light, emoji: '☀️'),
        (label: 'Dark', mode: ThemeMode.dark, emoji: '🌙'),
      ];

  /// Appearance picker (System / Light / Dark — R-WT3 / R-WT6, S53). Mirrors the
  /// daily-goal sheet; the choice persists via [AppSettingsController.setThemeMode]
  /// and drives `MaterialApp.themeMode`.
  void _pickTheme(
    BuildContext context,
    AppSettingsController c,
    ThemeMode current,
  ) {
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
                child: RatelSectionHeader(label: context.l10n.settingsTheme),
              ),
              for (final ({String label, ThemeMode mode, String emoji}) t
                  in _themes) ...<Widget>[
                RatelListRow(
                  leadingEmoji: t.mode == current ? '✅' : t.emoji,
                  title: _themeLabel(context, t.mode),
                  onTap: () {
                    c.setThemeMode(t.mode);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                const SizedBox(height: RatelSpace.xs),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _courseLabel(BuildContext context, String code) =>
      ratelCourseLanguageName(context, code);

  String _worldLabel(BuildContext context, WorldTheme w) => ratelWorldLabel(
    context,
    kThemeWorlds.containsKey(w.name) ? w.name : 'light',
  );
}
