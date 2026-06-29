import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/services/auth/auth.dart';
import 'package:ratel/services/identity/identity.dart';

import 'auth_kit.dart';

/// Account creation (R-L1 / R-L2). Email + password, reachable from the
/// onboarding Welcome and the Login screen. Talks to the backend ONLY through
/// the injected [authServiceProvider] + [identityProvider] seams (R-K6). When
/// no backend is wired it shows an honest banner and fail-closes — a session is
/// NEVER faked (§6). A password sign-up that yields an immediate session
/// performs the TS-11 guest→account claim (mint while anonymous, claim after).
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, this.onAuthenticated, this.onSignInInstead});

  /// Fired when a live session is established (the router navigates home).
  final VoidCallback? onAuthenticated;

  /// "Already have an account? Sign in" path (the router swaps to /login).
  final VoidCallback? onSignInInstead;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _busy = false;
  bool _sent = false; // a confirmation email was dispatched
  String? _emailError;
  String? _passwordError;
  String? _error;

  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    String? emailErr;
    String? pwErr;
    final String email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      emailErr = 'Enter your email';
    } else if (!_emailRe.hasMatch(email)) {
      emailErr = 'Enter a valid email';
    }
    final String pw = _passwordCtrl.text;
    if (pw.isEmpty) {
      pwErr = 'Create a password';
    } else if (pw.length < 8) {
      pwErr = 'At least 8 characters';
    }
    setState(() {
      _emailError = emailErr;
      _passwordError = pwErr;
    });
    return emailErr == null && pwErr == null;
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_validate()) return;
    final String email = _emailCtrl.text.trim();
    final AuthService auth = ref.read(authServiceProvider);
    final Identity identity = ref.read(identityProvider);
    setState(() => _busy = true);
    try {
      // TS-11: a password sign-up yields an immediate session, so mint the
      // claim token while still the anonymous guest to merge on-device state.
      final AnonymousClaimToken? claimToken = await identity.mintClaimToken();
      final AuthOutcome outcome = await auth.signUpWithPassword(
          email: email, password: _passwordCtrl.text);
      if (!mounted) return;
      if (outcome == AuthOutcome.session) {
        await _claimAnonymousState(identity, claimToken);
        widget.onAuthenticated?.call();
      } else {
        setState(() => _sent = true);
      }
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Best-effort guest→account merge (TS-11): never blocks sign-up.
  Future<void> _claimAnonymousState(
      Identity identity, AnonymousClaimToken? token) async {
    if (token == null) return;
    try {
      await identity.claimAnonymousState(token);
    } catch (_) {
      // Non-fatal: the user is signed in; the merge can be retried later.
    }
  }

  void _social() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
          content: Text('Social sign-in (Google / Apple) is coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = ref.watch(authServiceProvider);
    if (_sent) return _SentNotice(email: _emailCtrl.text.trim());
    return Scaffold(
      backgroundColor: context.palette.cream,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const AuthBackButton(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: RatelSpace.screen, vertical: RatelSpace.md),
                child: Column(
                  key: const Key('signup'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const AuthHeader(
                      title: 'Create your account',
                      subtitle: 'Free forever · learn 52 languages',
                    ),
                    const SizedBox(height: RatelSpace.xl),
                    if (!auth.isAvailable) ...<Widget>[
                      const AuthUnavailableBanner(),
                      const SizedBox(height: RatelSpace.lg),
                    ],
                    AuthSocialButtons(onTap: _social),
                    const SizedBox(height: RatelSpace.lg),
                    const AuthDivider(),
                    const SizedBox(height: RatelSpace.lg),
                    AuthField(
                      fieldKey: const Key('signup-email'),
                      controller: _emailCtrl,
                      emoji: '✉️',
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: RatelSpace.md),
                    AuthField(
                      fieldKey: const Key('signup-password'),
                      controller: _passwordCtrl,
                      emoji: '🔒',
                      hint: 'Password (8+ characters)',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _busy ? null : _submit(),
                      errorText: _passwordError,
                    ),
                    if (_error != null) ...<Widget>[
                      const SizedBox(height: RatelSpace.lg),
                      Text(
                        _error!,
                        key: const Key('signup-error'),
                        style: const TextStyle(
                          fontFamily: RatelFont.body,
                          fontWeight: RatelType.semiBold,
                          fontSize: RatelType.small,
                          color: RatelColors.coral,
                        ),
                      ),
                    ],
                    const SizedBox(height: RatelSpace.xl),
                    RatelButton(
                      key: const Key('signup-submit'),
                      label: 'Create account',
                      onPressed: _busy ? null : _submit,
                    ),
                    const SizedBox(height: RatelSpace.sm),
                    AuthFooterLink(
                      lead: 'Already have an account? ',
                      linkText: 'Sign in',
                      onTap: () => widget.onSignInInstead?.call(),
                    ),
                    const SizedBox(height: RatelSpace.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Confirm your email" surface after a confirmation link is dispatched (the
/// project requires email confirmation, so sign-up may defer the session).
class _SentNotice extends StatelessWidget {
  const _SentNotice({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.cream,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const AuthBackButton(),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: RatelSpace.screen),
                child: Column(
                  key: const Key('signup-sent'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.mark_email_unread_rounded,
                        size: 64, color: RatelColors.teal),
                    const SizedBox(height: RatelSpace.lg),
                    Text(
                      'Confirm your email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.screenTitle,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: RatelSpace.sm),
                    Text(
                      'We sent a confirmation link to $email. Tap it to activate '
                      'your account, then come back to log in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontWeight: RatelType.semiBold,
                        fontSize: RatelType.body,
                        color: context.palette.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
