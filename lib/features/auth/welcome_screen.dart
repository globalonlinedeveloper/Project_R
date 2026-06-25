import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// Auth-gated entry point (R-L1): a guest-first Welcome screen.
///
/// Shown only when `authEnabled` is on (see app_flags / router). The primary,
/// fully-wired path is "Continue as guest", which enters the existing
/// guest-first onboarding flow. Account entry points are deliberate seams:
/// [onCreateAccount] reveals the Sign-up affordance (queue #3) and [onSignIn]
/// the Log-in affordance (queue #4) — each appears automatically once wired, no
/// layout change needed.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onContinueAsGuest,
    this.onCreateAccount,
    this.onSignIn,
  });

  /// Guest-first primary action — enter the app without an account.
  final VoidCallback onContinueAsGuest;

  /// Optional account-creation path, wired when the Sign-up screen lands (#3).
  final VoidCallback? onCreateAccount;

  /// Optional existing-account path, wired when the Login flow lands (#4).
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
          if (onCreateAccount != null) ...[
            const SizedBox(height: RatelSpacing.sm),
            RatelButton(
              label: 'Create an account',
              kind: RatelButtonKind.secondary,
              expand: true,
              onPressed: onCreateAccount,
            ),
          ],
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
