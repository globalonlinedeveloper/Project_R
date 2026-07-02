import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/billing/billing.dart';
import 'package:ratel/services/preferences/app_settings.dart';

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
        title: Text('Settings',
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
          const RatelSectionHeader(label: 'Learning'),
          const SizedBox(height: RatelSpace.sm),
          RatelListRow(
            leadingEmoji: '🎯',
            leadingColor: RatelColors.teal,
            title: 'Daily goal',
            subtitle: goalStatus.met
                ? '${s.dailyGoal} XP per day · ✓ reached today'
                : '${s.dailyGoal} XP per day',
            onTap: () => _pickGoal(context, c, s.dailyGoal),
          ),
          const SizedBox(height: RatelSpace.sm),
          _toggle(context, '🔊', 'Sound effects', s.sound, c.setSound),
          const SizedBox(height: RatelSpace.lg),
          const RatelSectionHeader(label: 'Habits'),
          const SizedBox(height: RatelSpace.sm),
          RatelListRow(
            leadingEmoji: '💳',
            leadingColor: RatelColors.amber,
            title: 'Manage subscription',
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
          const SizedBox(height: RatelSpace.sm),
          _toggle(context, '🌀', 'Reduce motion', s.reduceMotion, c.setReduceMotion),
          const SizedBox(height: RatelSpace.sm),
          _toggle(context, '🎨', 'High contrast', s.highContrast, c.setHighContrast),
          const SizedBox(height: RatelSpace.sm),
          _toggle(context, '📳', 'Haptics', s.haptics, c.setHaptics),
          const SizedBox(height: RatelSpace.lg),
          const RatelSectionHeader(label: 'Notifications'),
          const SizedBox(height: RatelSpace.sm),
          _toggle(context, '🔔', 'Push notifications', s.notifyEnabled('push'),
              (bool v) => c.setNotification('push', v)),
          const SizedBox(height: RatelSpace.sm),
          _toggle(context, '🔥', 'Streak reminders', s.notifyEnabled('streak'),
              (bool v) => c.setNotification('streak', v)),
          const SizedBox(height: RatelSpace.sm),
          _toggle(context, '🏆', 'League updates', s.notifyEnabled('league'),
              (bool v) => c.setNotification('league', v)),
          const SizedBox(height: RatelSpace.sm),
          _toggle(context, '👥', 'Friend activity', s.notifyEnabled('friend'),
              (bool v) => c.setNotification('friend', v)),
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
          const RatelSectionHeader(label: 'Appearance & account'),
          const SizedBox(height: RatelSpace.sm),
          RatelListRow(
            leadingEmoji: '🌙',
            leadingColor: RatelColors.purple,
            title: 'Theme',
            subtitle: _themeLabel(s.themeMode),
            onTap: () => _pickTheme(context, c, s.themeMode),
          ),
          const SizedBox(height: RatelSpace.sm),
          RatelListRow(
            leadingEmoji: '🌌',
            leadingColor: RatelColors.blue,
            title: 'World',
            subtitle: _worldLabel(s.worldTheme),
            onTap: () => _pickWorld(context, c, s.worldTheme, isPro),
          ),
          const SizedBox(height: RatelSpace.sm),
          RatelListRow(
            leadingEmoji: '👤',
            leadingColor: RatelColors.blue,
            title: 'Edit profile',
            onTap: () => context.push('/edit-profile'),
          ),
          const SizedBox(height: RatelSpace.sm),
          RatelListRow(
            leadingEmoji: '🔒',
            leadingColor: RatelColors.teal,
            title: 'Privacy & data',
            subtitle: 'learnwithratel.com/privacy',
            onTap: () => _openUrl(context, 'https://learnwithratel.com/privacy'),
          ),
          const SizedBox(height: RatelSpace.sm),
          RatelListRow(
            leadingEmoji: '❓',
            leadingColor: RatelColors.green,
            title: 'Help & support',
            subtitle: 'learnwithratel.com/help',
            onTap: () => _openUrl(context, 'https://learnwithratel.com/help'),
          ),
          const SizedBox(height: RatelSpace.sm),
          RatelListRow(
            leadingEmoji: identity.isAuthenticated ? '🚪' : '✨',
            leadingColor: RatelColors.coral,
            title: identity.isAuthenticated ? 'Log out' : 'Create a free account',
            subtitle: identity.isAuthenticated
                ? null
                : 'You are learning as a guest — sign up to save progress',
            onTap: () => context.push('/onboarding'),
          ),
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

  Widget _toggle(BuildContext context,
          String emoji, String title, bool value, ValueChanged<bool> onChanged) =>
      RatelCard(
        child: Row(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.bodyLg,
                      color: context.palette.ink)),
            ),
            RatelToggle(value: value, onChanged: onChanged),
          ],
        ),
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
              const Padding(
                padding: EdgeInsets.only(
                    left: RatelSpace.sm, bottom: RatelSpace.sm),
                child: RatelSectionHeader(label: 'Daily goal'),
              ),
              for (final ({String label, int xp}) g in _goals) ...<Widget>[
                RatelListRow(
                  leadingEmoji: g.xp == current ? '✅' : '⚪',
                  title: '${g.label} · ${g.xp} XP/day',
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
  String _worldLabel(WorldTheme w) =>
      kThemeWorlds[w.name]?.label ?? 'Daylight';

  /// World-theme picker — all 31 design worlds (2 free + 29 Pro, from
  /// `kThemeWorlds`). A free world (or any world when Pro) selects + persists via
  /// [AppSettingsController.setWorldTheme] and re-skins the whole app; a locked
  /// Pro world routes to the paywall. Never fakes selection of a locked world.
  void _pickWorld(BuildContext context, AppSettingsController c,
      WorldTheme current, bool isPro) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
                child: RatelSectionHeader(label: 'World'),
              ),
              SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.6,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: RatelSpace.sm,
                  crossAxisSpacing: RatelSpace.sm,
                  childAspectRatio: 0.82,
                  children: <Widget>[
                    for (final ThemeWorld w in kThemeWorlds.values)
                      _WorldSwatch(
                        world: w,
                        selected: w.id == current.name,
                        locked: !w.isFree && !isPro,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          if (!w.isFree && !isPro) {
                            context.go('/paywall');
                          } else {
                            c.setWorldTheme(WorldTheme.values.byName(w.id));
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

/// A tappable world tile in the picker: the world's own bg + accent/gold dots,
/// its label, a ✓ when selected and a 🔒 when locked (Pro). Reads the world's
/// ported palette via field access — no raw color literals (token-lint safe).
class _WorldSwatch extends StatelessWidget {
  const _WorldSwatch({
    required this.world,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final ThemeWorld world;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final WorldPalette p = world.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(RatelSpace.sm),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: BorderRadius.circular(RatelRadius.featureLg),
          border: Border.all(
            color: selected ? p.accent : context.palette.border,
            width: selected ? 3 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                _dot(p.accent),
                const SizedBox(width: 4),
                _dot(p.gold),
                const Spacer(),
                if (selected)
                  Text('✓',
                      style: TextStyle(
                          color: p.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 16))
                else if (locked)
                  const Text('🔒', style: TextStyle(fontSize: 13)),
              ],
            ),
            Text(
              world.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: p.text, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
