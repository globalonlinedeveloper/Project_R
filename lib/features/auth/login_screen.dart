import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/services/auth/auth.dart';
import 'package:ratel/services/identity/identity.dart';

import 'auth_kit.dart';

/// Account sign-in (R-L1 / R-L2). Email + password with a "forgot password"
/// reset path, reachable from the onboarding Welcome ("I already have an
/// account") and the Sign-up screen. Talks to the backend ONLY through the
/// injected [authServiceProvider] + [identityProvider] seams, so it is fully
/// testable with a fake and carries no backend types (R-K6). When no backend is
/// wired ([AuthService.isAvailable] == false) it shows an honest banner and
/// fail-closes — a session is NEVER faked (§6). On a real session it performs
/// the TS-11 guest→account claim (mint while anonymous, claim after sign-in).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onAuthenticated, this.onSignUpInstead});

  /// Fired when a live session is established (the router navigates home).
  final VoidCallback? onAuthenticated;

  /// "New to Ratel? Sign up" path (the router swaps to /signup).
  final VoidCallback? onSignUpInstead;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _busy = false;
  bool _reset = false; // forgot-password mode (email only)
  bool _sent = false; // a reset link was emailed
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
    if (!_reset && _passwordCtrl.text.isEmpty) {
      pwErr = 'Enter your password';
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
    setState(() => _busy = true);
    try {
      if (_reset) {
        await auth.sendPasswordReset(email: email);
        if (!mounted) return;
        setState(() => _sent = true);
      } else {
        // TS-11: mint a claim token while still the anonymous guest, then merge
        // the on-device state into the account once a session exists.
        final Identity identity = ref.read(identityProvider);
        final AnonymousClaimToken? claimToken = await identity.mintClaimToken();
        final AuthOutcome outcome = await auth.signInWithPassword(
            email: email, password: _passwordCtrl.text);
        if (!mounted) return;
        if (outcome == AuthOutcome.session) {
          await _claimAnonymousState(identity, claimToken);
          widget.onAuthenticated?.call();
        } else {
          setState(() => _error = 'Could not sign you in. Please try again.');
        }
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

  /// Best-effort guest→account merge (TS-11): never blocks sign-in.
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
                  key: const Key('login'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AuthHeader(
                      title: _reset ? 'Reset your password' : 'Welcome back!',
                      subtitle: _reset
                          ? "Enter your email and we'll send a reset link."
                          : 'Pick up where you left off',
                    ),
                    const SizedBox(height: RatelSpace.xl),
                    if (!auth.isAvailable) ...<Widget>[
                      const AuthUnavailableBanner(),
                      const SizedBox(height: RatelSpace.lg),
                    ],
                    if (!_reset) ...<Widget>[
                      AuthSocialButtons(onTap: _social),
                      const SizedBox(height: RatelSpace.lg),
                      const AuthDivider(),
                      const SizedBox(height: RatelSpace.lg),
                    ],
                    AuthField(
                      fieldKey: const Key('login-email'),
                      controller: _emailCtrl,
                      emoji: '✉️',
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorText: _emailError,
                    ),
                    if (!_reset) ...<Widget>[
                      const SizedBox(height: RatelSpace.md),
                      AuthField(
                        fieldKey: const Key('login-password'),
                        controller: _passwordCtrl,
                        emoji: '🔒',
                        hint: 'Password',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _busy ? null : _submit(),
                        errorText: _passwordError,
                      ),
                      const SizedBox(height: RatelSpace.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          key: const Key('login-forgot'),
                          onTap: _busy
                              ? null
                              : () => setState(() {
                                    _reset = true;
                                    _error = null;
                                    _passwordError = null;
                                  }),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontFamily: RatelFont.body,
                              fontWeight: RatelType.extraBold,
                              fontSize: RatelType.small,
                              color: RatelColors.teal,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_error != null) ...<Widget>[
                      const SizedBox(height: RatelSpace.lg),
                      Text(
                        _error!,
                        key: const Key('login-error'),
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
                      key: const Key('login-submit'),
                      label: _reset ? 'Send reset link' : 'Log in',
                      onPressed: _busy ? null : _submit,
                    ),
                    const SizedBox(height: RatelSpace.sm),
                    if (_reset)
                      RatelButton(
                        key: const Key('login-back'),
                        label: 'Back to log in',
                        variant: RatelButtonVariant.secondary,
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                  _reset = false;
                                  _error = null;
                                }),
                      )
                    else
                      AuthFooterLink(
                        lead: 'New to Ratel? ',
                        linkText: 'Sign up',
                        onTap: () => widget.onSignUpInstead?.call(),
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

/// "Check your inbox" confirmation after a password-reset link is emailed.
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
                padding: const EdgeInsets.symmetric(
                    horizontal: RatelSpace.screen),
                child: Column(
                  key: const Key('login-sent'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(RatelIcons.markEmailUnread,
                        size: 64, color: RatelColors.teal),
                    const SizedBox(height: RatelSpace.lg),
                    Text(
                      'Check your inbox',
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
                      'We sent a password-reset link to $email. Open it to '
                      'choose a new password.',
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
