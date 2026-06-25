import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// Auth-gated entry point (R-L1): a guest-first Welcome screen.
///
/// Shown only when `authEnabled` is on (see app_flags / router). The primary,
/// fully-wired path is "Continue as guest", which enters the existing
/// guest-first onboarding flow. Account entry points (Sign up / Log in) are a
/// deliberate seam: pass [onSignIn] once the Login screen (queue #4) exists and
/// the secondary affordance appears automatically — no layout change needed.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onContinueAsGuest,
    this.onSignIn,
  });

  /// Guest-first primary action — enter the app without an account.
  final VoidCallback onContinueAsGuest;

  /// Optional account path, wired when the Login flow lands (queue #4).
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return RatelScreen(
      child: Column(
        key: const Key('welcome'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          Icon(Icons.bolt, size: 72, color: t.primary, semanticLabel: 'Ratel'),
          const SizedBox(height: RatelSpacing.lg),
          Text('Welcome to Ratel',
              style: RatelType.display, textAlign: TextAlign.center),
          const SizedBox(height: RatelSpacing.sm),
          Text(
            'Learn a language a few minutes a day — no account needed to start.',
            style: RatelType.body.copyWith(color: t.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          RatelButton(
            label: 'Continue as guest',
            expand: true,
            onPressed: onContinueAsGuest,
          ),
          if (onSignIn != null) ...[
            const SizedBox(height: RatelSpacing.sm),
            RatelButton(
              label: 'I already have an account',
              kind: RatelButtonKind.text,
              expand: true,
              onPressed: onSignIn,
            ),
          ],
          const SizedBox(height: RatelSpacing.lg),
        ],
      ),
    );
  }
}
