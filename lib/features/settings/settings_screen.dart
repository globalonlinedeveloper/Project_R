import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/identity/identity.dart';
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
      backgroundColor: RatelColors.cream,
      appBar: AppBar(
        backgroundColor: RatelColors.cream,
        surfaceTintColor: RatelColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: RatelColors.ink),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings',
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: RatelColors.ink,
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
          _toggle('🔊', 'Sound effects', s.sound, c.setSound),
          const SizedBox(height: RatelSpace.lg),
          const RatelSectionHeader(label: 'Accessibility'),
          const SizedBox(height: RatelSpace.sm),
          _toggle('🎨', 'High contrast', s.highContrast, c.setHighContrast),
          const SizedBox(height: RatelSpace.sm),
          _toggle('📳', 'Haptics', s.haptics, c.setHaptics),
          const SizedBox(height: RatelSpace.lg),
          const RatelSectionHeader(label: 'Notifications'),
          const SizedBox(height: RatelSpace.sm),
          RatelCard(
            color: RatelColors.cream2,
            child: Row(
              children: const <Widget>[
                Text('🔔', style: TextStyle(fontSize: 22)),
                SizedBox(width: RatelSpace.md),
                Expanded(
                    child: Text(
                        'Push, streak reminders, league & friend alerts need a '
                        'notification engine — an owner decision (§6).',
                        style: TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.body,
                            color: RatelColors.muted))),
                RatelChip(label: 'Soon', tone: RatelChipTone.neutral),
              ],
            ),
          ),
          const SizedBox(height: RatelSpace.lg),
          const RatelSectionHeader(label: 'Account'),
          const SizedBox(height: RatelSpace.sm),
          RatelListRow(
            leadingEmoji: '💳',
            leadingColor: RatelColors.amber,
            title: 'Manage subscription',
            subtitle: isPro ? 'RATEL PRO active' : 'Free plan',
            onTap: () => context.push('/shop'),
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

  Widget _toggle(
          String emoji, String title, bool value, ValueChanged<bool> onChanged) =>
      RatelCard(
        child: Row(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.bodyLg,
                      color: RatelColors.ink)),
            ),
            RatelToggle(value: value, onChanged: onChanged),
          ],
        ),
      );

  void _pickGoal(
      BuildContext context, AppSettingsController c, int current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: RatelColors.white,
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
}
