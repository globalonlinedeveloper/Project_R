import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/auth_gate.dart';
import 'package:ratel/core/core.dart';

import 'auth_kit.dart';

/// AUTH-1 (S112): the first-launch Welcome gate — Register / Log in /
/// Continue as guest. Reached ONLY via the router redirect while
/// [welcomeGateNeededProvider] is true (configured build, no session, no
/// persisted choice — policy in `auth_gate.dart`).
///
/// The guest action is the SAME anonymous-session boot pre-gate builds ran
/// automatically ([guestEntryProvider], best-effort), followed by persisting
/// the choice so the gate never re-shows; account entry rides the existing
/// /login + /signup screens (which clear the gate on session via the router).
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen(
      {super.key, this.onRegister, this.onLogin, this.onEntered});

  /// "Create free account" → the router pushes /signup.
  final VoidCallback? onRegister;

  /// "I already have an account" → the router pushes /login.
  final VoidCallback? onLogin;

  /// Guest entry finished → the router goes home.
  final VoidCallback? onEntered;

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _busy = false;

  Future<void> _continueAsGuest() async {
    setState(() => _busy = true);
    try {
      // Best-effort anonymous session (never throws; offline stays local).
      await ref.read(guestEntryProvider)();
      // Persist the choice — the gate is first-launch-only — then drop it.
      await ref.read(authChoicePersisterProvider)(kAuthChoiceGuest);
      ref.read(welcomeGateNeededProvider.notifier).state = false;
      widget.onEntered?.call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: RatelSpace.screen, vertical: RatelSpace.xl),
            child: Column(
              key: const Key('welcome'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const AuthHeader(
                  title: 'Welcome to Ratel',
                  subtitle:
                      'Lessons, stories, podcasts and more —\npick how you want to start.',
                ),
                const SizedBox(height: RatelSpace.xl),
                RatelButton(
                  key: const Key('welcome-register'),
                  label: 'Create free account',
                  onPressed:
                      _busy ? null : () => widget.onRegister?.call(),
                ),
                const SizedBox(height: RatelSpace.sm),
                RatelButton(
                  key: const Key('welcome-login'),
                  label: 'I already have an account',
                  variant: RatelButtonVariant.secondary,
                  onPressed: _busy ? null : () => widget.onLogin?.call(),
                ),
                const SizedBox(height: RatelSpace.lg),
                Center(
                  child: GestureDetector(
                    key: const Key('welcome-guest'),
                    onTap: _busy ? null : _continueAsGuest,
                    child: Text(
                      _busy ? 'Setting things up…' : 'Continue as guest',
                      style: const TextStyle(
                        fontFamily: RatelFont.body,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.body,
                        color: RatelColors.teal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: RatelSpace.sm),
                Text(
                  'Guest progress lives on this device — create a free account any time in Settings to keep it everywhere.',
                  textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
