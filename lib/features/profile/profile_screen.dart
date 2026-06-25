import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_flags.dart';
import '../../core/design_system/design_system.dart';
import '../auth/auth_service.dart';
import '../saved_words/saved_words_controller.dart';

/// Profile / "You" tab. Stats and settings will live here in a later wave;
/// this increment adds the **Account** section that hosts sign-in / log-out
/// (R-L1), shown only when `authEnabled` is on so `main` behaviour is unchanged
/// with the flag off.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final int saved = ref.watch(savedWordsControllerProvider).count;
    return RatelScreen(
      title: 'You',
      child: ListView(
        key: const Key('profile-screen'),
        children: [
          const SizedBox(height: RatelSpacing.sm),
          Text('Your profile', style: RatelType.headline),
          const SizedBox(height: RatelSpacing.xs),
          Text('Stats and settings live here.',
              style: RatelType.body.copyWith(color: t.onSurfaceVariant)),
          const SizedBox(height: RatelSpacing.lg),
          RatelCard(
            child: Row(
              children: [
                Text('Saved words', style: RatelType.body),
                const Spacer(),
                Text('$saved', style: RatelType.title),
              ],
            ),
          ),
          if (authEnabled) ...[
            const SizedBox(height: RatelSpacing.xl),
            const _AccountSection(),
          ],
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

  /// Double-confirm (R-L1): a destructive action gets an explicit dialog. On
  /// confirm we drop the local session even if the network sign-out fails, so
  /// the user is never trapped; the router (listening to [signedIn]) returns to
  /// Welcome automatically.
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
            child:
                Text('Log out', style: RatelType.label.copyWith(color: t.danger)),
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
