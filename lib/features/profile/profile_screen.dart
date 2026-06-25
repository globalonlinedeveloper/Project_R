import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_flags.dart';
import '../../core/design_system/design_system.dart';
import '../auth/auth_service.dart';
import '../energy/energy_controller.dart';
import '../saved_words/saved_words_controller.dart';
import '../settings/settings_controller.dart';
import '../streak/streak_controller.dart';

/// Profile / "You" tab. Surfaces the learner's live progress (streak, lessons,
/// saved words) as a stat grid, hosts **Settings** (world/theme + motion + a11y),
/// then the **Account** section (sign-in / log-out, R-L1). Stats read the same
/// in-memory controllers Home and Lesson use — real data, no new backend; the
/// Account section shows only when `authEnabled` is on.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final streak = ref.watch(streakControllerProvider);
    final int lessons = ref.watch(energyControllerProvider).lessonsCompleted;
    final int saved = ref.watch(savedWordsControllerProvider).count;
    return RatelScreen(
      title: 'You',
      child: ListView(
        key: const Key('profile-screen'),
        children: [
          const SizedBox(height: RatelSpacing.sm),
          Text('Your profile', style: RatelType.headline),
          const SizedBox(height: RatelSpacing.xs),
          Text('Your progress so far.',
              style: RatelType.body.copyWith(color: t.onSurfaceVariant)),
          const SizedBox(height: RatelSpacing.lg),
          _StatsGrid(
            current: streak.current,
            longest: streak.longest,
            lessons: lessons,
            saved: saved,
          ),
          const SizedBox(height: RatelSpacing.xl),
          const _SettingsSection(),
          if (authEnabled) ...[
            const SizedBox(height: RatelSpacing.xl),
            const _AccountSection(),
          ],
        ],
      ),
    );
  }
}

/// A 2x2 grid of the learner's live stats. Each value comes from an existing
/// in-memory controller (streak / energy / saved-words) — the same sources Home
/// and Lesson read — so this is real data with no new dependencies.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.current,
    required this.longest,
    required this.lessons,
    required this.saved,
  });

  final int current;
  final int longest;
  final int lessons;
  final int saved;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      key: const Key('profile-stats'),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatTile(
                key: const Key('stat-streak'),
                icon: Icons.local_fire_department,
                value: '$current',
                label: 'Day streak',
                color: t.primary,
              ),
            ),
            const SizedBox(width: RatelSpacing.sm),
            Expanded(
              child: _StatTile(
                key: const Key('stat-best-streak'),
                icon: Icons.emoji_events,
                value: '$longest',
                label: 'Best streak',
                color: t.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: RatelSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatTile(
                key: const Key('stat-lessons'),
                icon: Icons.school,
                value: '$lessons',
                label: 'Lessons',
                color: t.success,
              ),
            ),
            const SizedBox(width: RatelSpacing.sm),
            Expanded(
              child: _StatTile(
                key: const Key('stat-saved'),
                icon: Icons.bookmark,
                value: '$saved',
                label: 'Saved words',
                color: t.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return RatelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: RatelSpacing.sm),
          Text(value, style: RatelType.display),
          const SizedBox(height: RatelSpacing.xs),
          Text(label,
              style: RatelType.caption.copyWith(color: t.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// App settings: the world/theme switch (Classic ⇄ Space, re-skins app-wide and
/// persists) plus motion + a11y toggles. Lives on Profile per the design (the
/// galaxy HUD has no settings of its own). Tokens only (R-N6).
class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);
    return RatelCard(
      child: Column(
        key: const Key('profile-settings'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Settings', style: RatelType.title),
          const SizedBox(height: RatelSpacing.xs),
          _ToggleRow(
            key: const Key('settings-space-theme'),
            icon: Icons.rocket_launch_outlined,
            label: 'Galaxy (Space) theme',
            subtitle: 'Fly the Ratel pod through a galaxy — re-skins the whole app.',
            value: s.world == WorldThemeId.space,
            onChanged: (_) => ctrl.toggleSpace(),
          ),
          _ToggleRow(
            key: const Key('settings-reduce-motion'),
            icon: Icons.motion_photos_paused_outlined,
            label: 'Reduce motion',
            subtitle: 'Calmer, mostly-still animations.',
            value: s.motion == MotionPreference.off,
            onChanged: (on) =>
                ctrl.setMotion(on ? MotionPreference.off : MotionPreference.high),
          ),
          _ToggleRow(
            key: const Key('settings-high-contrast'),
            icon: Icons.contrast,
            label: 'High contrast',
            value: s.highContrast,
            onChanged: ctrl.setHighContrast,
          ),
          _ToggleRow(
            key: const Key('settings-sound'),
            icon: Icons.volume_up_outlined,
            label: 'Sound effects',
            value: s.sound,
            onChanged: ctrl.setSound,
          ),
          _ToggleRow(
            key: const Key('settings-haptics'),
            icon: Icons.vibration,
            label: 'Haptics',
            value: s.haptics,
            onChanged: ctrl.setHaptics,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RatelSpacing.xs),
      child: Row(
        children: [
          Icon(icon, color: t.primary, size: 22),
          const SizedBox(width: RatelSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: RatelType.bodyStrong),
                if (subtitle != null)
                  Text(subtitle!,
                      style: RatelType.caption
                          .copyWith(color: t.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Account card: reflects live session state ([signedIn]) and hosts the entry /
/// exit actions. Reads the auth seam lazily (only on log-out) so it never
/// touches the must-override [authServiceProvider] in the guest path.
class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return ValueListenableBuilder<bool>(
      valueListenable: signedIn,
      builder: (context, isSignedIn, _) {
        return RatelCard(
          child: Column(
            key: const Key('profile-account'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Account', style: RatelType.title),
              const SizedBox(height: RatelSpacing.sm),
              Text(
                isSignedIn
                    ? "You're signed in."
                    : "You're playing as a guest.",
                style: RatelType.body.copyWith(color: t.onSurfaceVariant),
              ),
              const SizedBox(height: RatelSpacing.lg),
              if (isSignedIn)
                RatelButton(
                  key: const Key('profile-logout'),
                  label: 'Log out',
                  kind: RatelButtonKind.secondary,
                  expand: true,
                  onPressed: () => _confirmLogout(context, ref),
                )
              else ...[
                RatelButton(
                  key: const Key('profile-create-account'),
                  label: 'Create an account',
                  expand: true,
                  onPressed: () => context.go('/signup'),
                ),
                const SizedBox(height: RatelSpacing.sm),
                RatelButton(
                  key: const Key('profile-login'),
                  label: 'Log in',
                  kind: RatelButtonKind.text,
                  expand: true,
                  onPressed: () => context.go('/login'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final t = context.tokens;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text('Log out?', style: RatelType.title),
        content: Text(
          'You can log back in anytime.',
          style: RatelType.body.copyWith(color: t.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text('Cancel',
                style: RatelType.label.copyWith(color: t.onSurfaceVariant)),
          ),
          TextButton(
            key: const Key('profile-logout-confirm'),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text('Log out',
                style: RatelType.label.copyWith(color: t.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(authServiceProvider).signOut();
    } on AuthFailure {
      // Network sign-out failed — still drop the local session below so the
      // user isn't stuck; the next launch re-syncs from Supabase.
    }
    welcomeSeen.value = false;
    signedIn.value = false;
  }
}
// Traceability: R-WT6
