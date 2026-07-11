import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static const List<({String label, int xp})> _goals = <({String label, int xp})>[
    (label: 'Casual', xp: 10),
    (label: 'Regular', xp: 20),
    (label: 'Serious', xp: 30),
    (label: 'Intense', xp: 50),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings s = ref.watch(appSettingsControllerProvider);
    final AppSettingsController c =
        ref.read(appSettingsControllerProvider.notifier);
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
        title: Text(context.l10n.settingsTitle,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            RatelSpace.screen, RatelSpace.sm, RatelSpace.screen, RatelSpace.xl),
        children: <Widget>[
          _section(context, context.l10n.settingsSectionLearning, <Widget>[
            RatelListRow(
              title: context.l10n.settingsDailyGoal,
              subtitle: goalStatus.met
                  ? '${s.dailyGoal} XP per day · ✓ reached today'
                  : '${s.dailyGoal} XP per day',
              onTap: () => _pickGoal(context, c, s.dailyGoal),
            ),
            _switchRow('Sound effects', s.sound, c.setSound),
            _switchRow('Haptics', s.haptics, c.setHaptics),
          ]),
          const SizedBox(height: RatelSpace.lg),
          _section(context, context.l10n.settingsSectionSubscription, <Widget>[
            RatelListRow(
              title: context.l10n.paywallManage,
              subtitle: isPro ? 'RATEL PRO active' : 'Free plan',
              onTap: () {
                if (isPro) {
                  ref.read(manageSubscriptionProvider).open().then((ManageResult r) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(r.message)));
                  });
                } else {
                  context.push('/paywall?source=settings');
                }
              },
            ),
          ]),
          const SizedBox(height: RatelSpace.lg),
          _section(context, context.l10n.settingsSectionAccessibility, <Widget>[
            _switchRow('Reduce motion', s.reduceMotion, c.setReduceMotion,
                subtitle: 'Master switch — turns off every animation'),
            _switchRow('High contrast', s.highContrast, c.setHighContrast),
          ]),
          const SizedBox(height: RatelSpace.lg),
          _section(context, context.l10n.settingsSectionNotifications, <Widget>[
            _switchRow('Push notifications', s.notifyEnabled('push'),
                (bool v) => c.setNotification('push', v)),
            _switchRow('Streak reminders', s.notifyEnabled('streak'),
                (bool v) => c.setNotification('streak', v)),
            _switchRow('League updates', s.notifyEnabled('league'),
                (bool v) => c.setNotification('league', v)),
            _switchRow('Friend activity', s.notifyEnabled('friend'),
                (bool v) => c.setNotification('friend', v)),
          ]),
          const SizedBox(height: RatelSpace.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RatelSpace.xs),
            child: Text(
                'Your choices are saved now — delivery switches on when push '
                'notifications ship.',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted)),
          ),
          const SizedBox(height: RatelSpace.lg),
          _section(context, context.l10n.settingsSectionAppearanceAccount, <Widget>[
            if (CourseSwitchScope.maybeOf(context)
                case final CourseSwitchScope course)
              RatelListRow(
                leadingEmoji: '🌍',
                leadingColor: RatelColors.green,
                title: 'Course',
                subtitle: _courseLabel(course.current),
                onTap: () => _pickCourse(context, course),
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
              title: 'Theme',
              subtitle: _themeLabel(s.themeMode),
              onTap: () => _pickTheme(context, c, s.themeMode),
            ),
            RatelListRow(
              leadingEmoji: '🌌',
              leadingColor: RatelColors.blue,
              title: 'World',
              subtitle: _worldLabel(s.worldTheme),
              onTap: () => context.push('/themes'),
            ),
            RatelListRow(
              leadingEmoji: '👤',
              leadingColor: RatelColors.blue,
              title: 'Edit profile',
              onTap: () => context.push('/edit-profile'),
            ),
            RatelListRow(
              leadingEmoji: '🔒',
              leadingColor: RatelColors.teal,
              title: 'Privacy & data',
              subtitle: 'learnwithratel.com/privacy',
              onTap: () => _openUrl(context, 'https://learnwithratel.com/privacy'),
            ),
            RatelListRow(
              leadingEmoji: '❓',
              leadingColor: RatelColors.green,
              title: 'Help & support',
              subtitle: 'learnwithratel.com/help',
              onTap: () => _openUrl(context, 'https://learnwithratel.com/help'),
            ),
            RatelListRow(
              leadingEmoji: identity.isAuthenticated ? '🚪' : '✨',
              leadingColor: RatelColors.coral,
              title: identity.isAuthenticated ? 'Log out' : 'Create a free account',
              subtitle: identity.isAuthenticated
                  ? null
                  : 'You are learning as a guest — sign up to save progress',
              onTap: () => context.push('/onboarding'),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final bool ok =
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (ok || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Could not open $url')));
  }

  /// One settings section (E-8): a small-caps header + a single grouped
  /// [RatelCard] whose rows are separated by hairline dividers (design §4.9).
  /// Honest/additive rows (World, Course) stay (§D-4).
  Widget _section(BuildContext context, String label, List<Widget> rows) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(Divider(
            height: 1, thickness: 1, color: context.palette.border));
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
              children: children),
        ),
      ],
    );
  }

  /// A plain toggle row for inside a section card — no leading emoji (design
  /// §4.9 toggle rows are plain): title (+ optional [subtitle]) + a trailing
  /// [RatelToggle].
  Widget _switchRow(String title, bool value, ValueChanged<bool> onChanged,
          {String? subtitle}) =>
      RatelListRow(
        title: title,
        subtitle: subtitle,
        trailing: RatelToggle(value: value, onChanged: onChanged),
      );

  void _pickGoal(
      BuildContext context, AppSettingsController c, int current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(RatelRadius.featureLg))),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: RatelSpace.sm, bottom: RatelSpace.sm),
                child: RatelSectionHeader(
                    label: context.l10n.settingsDailyGoal),
              ),
              for (final ({String label, int xp}) g in _goals) ...<Widget>[
                RatelListRow(
                  leadingEmoji: g.xp == current ? '✅' : '⚪',
                  title: context.l10n.settingsGoalRow(
                      ratelGoalDisplayLabel(context, g.label), g.xp),
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

  void _pickAppLanguage(BuildContext context, WidgetRef ref) {
    final UiLocaleController c = ref.read(uiLocaleControllerProvider.notifier);
    final String? current = ref.read(uiLocaleControllerProvider)?.languageCode;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(RatelRadius.featureLg))),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: RatelSpace.sm, bottom: RatelSpace.sm),
                child: RatelSectionHeader(
                    label: context.l10n.settingsAppLanguage),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    RatelListRow(
                      leadingEmoji: current == null ? '✅' : '⚪',
                      title: context.l10n.settingsAppLanguageSystem,
                      onTap: () {
                        c.setLocale(null);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    const SizedBox(height: RatelSpace.xs),
                    for (final MapEntry<String, String> e
                        in kUiLanguageEndonyms.entries) ...<Widget>[
                      RatelListRow(
                        leadingEmoji: e.key == current ? '✅' : '⚪',
                        title: e.value,
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

  static String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.system => 'Match device',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
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
      BuildContext context, AppSettingsController c, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(RatelRadius.featureLg))),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Padding(
                padding:
                    EdgeInsets.only(left: RatelSpace.sm, bottom: RatelSpace.sm),
                child: RatelSectionHeader(label: 'Theme'),
              ),
              for (final ({String label, ThemeMode mode, String emoji}) t
                  in _themes) ...<Widget>[
                RatelListRow(
                  leadingEmoji: t.mode == current ? '✅' : t.emoji,
                  title: t.label,
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
  /// Course picker (INF-3) — mirrors the theme sheet. Choices come from the
  /// asset manifest via [CourseSwitchScope] (a new language = content rows +
  /// one asset; the picker grows itself). Selecting persists the code and
  /// remounts the app onto that course instantly (restart-free).
  void _pickCourse(BuildContext context, CourseSwitchScope course) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(RatelRadius.featureLg))),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Padding(
                padding:
                    EdgeInsets.only(left: RatelSpace.sm, bottom: RatelSpace.sm),
                child: RatelSectionHeader(label: 'Course'),
              ),
              for (final String code in course.available) ...<Widget>[
                RatelListRow(
                  leadingEmoji: code == course.current ? '✅' : '🌍',
                  title: _courseLabel(code),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(course.switchCourse(code));
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

  static String _courseLabel(String code) => switch (code) {
        'es' => 'Spanish (es)',
        'en' => 'English (en)',
        _ => code,
      };

  String _worldLabel(WorldTheme w) =>
      kThemeWorlds[w.name]?.label ?? 'Daylight';
}
