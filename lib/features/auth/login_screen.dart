import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../../services/identity/identity.dart';
import 'auth_service.dart';

/// Account sign-in (R-L1): email + password, a passwordless magic link, or a
/// password-reset request. Lives behind `authEnabled` and is reachable from the
/// guest-first Welcome screen and the Sign-up screen. Talks to Supabase only
/// through the injected [authServiceProvider] seam, so it is fully testable with
/// a fake and carries no backend types.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.onAuthenticated,
    this.onSignUpInstead,
  });

  /// Fired when a session is established (the router navigates into the app).
  final VoidCallback? onAuthenticated;

  /// Optional "need an account? Sign up" path.
  final VoidCallback? onSignUpInstead;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum _Mode { password, magicLink, reset }

enum _Sent { magicLink, reset }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  _Mode _mode = _Mode.password;
  bool _busy = false;
  String? _error;
  _Sent? _sent;

  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Enter your email';
    if (!_emailRe.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (_mode != _Mode.password) return null;
    if ((v ?? '').isEmpty) return 'Enter your password';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final email = _emailCtrl.text.trim();
    final auth = ref.read(authServiceProvider);
    setState(() => _busy = true);
    try {
      switch (_mode) {
        case _Mode.password:
          // TS-11: mint a claim token while still the anonymous guest, then
          // merge the on-device state into the account once a session exists.
          final identity = ref.read(identityProvider);
          final claimToken = await identity.mintClaimToken();
          final outcome = await auth.signInWithPassword(
              email: email, password: _passwordCtrl.text);
          if (!mounted) return;
          if (outcome == AuthOutcome.session) {
            await _claimAnonymousState(identity, claimToken);
            widget.onAuthenticated?.call();
          } else {
            setState(() => _error = 'Could not sign you in. Please try again.');
          }
        case _Mode.magicLink:
          await auth.sendMagicLink(email: email);
          if (!mounted) return;
          setState(() => _sent = _Sent.magicLink);
        case _Mode.reset:
          await auth.sendPasswordReset(email: email);
          if (!mounted) return;
          setState(() => _sent = _Sent.reset);
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

  /// Best-effort guest→account merge (TS-11): never blocks sign-in — a failed
  /// merge leaves the account valid and the server token simply expires.
  Future<void> _claimAnonymousState(
      Identity identity, AnonymousClaimToken? token) async {
    if (token == null) return;
    try {
      await identity.claimAnonymousState(token);
    } catch (_) {
      // Non-fatal: the user is signed in; the merge can be retried later.
    }
  }

  void _switchTo(_Mode mode) => setState(() {
        _mode = mode;
        _error = null;
      });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (_sent != null) {
      return RatelScreen(
        title: 'Log in',
        child: _SentNotice(kind: _sent!, email: _emailCtrl.text.trim()),
      );
    }
    final isPassword = _mode == _Mode.password;
    final isReset = _mode == _Mode.reset;
    final String heading = switch (_mode) {
      _Mode.password => 'Welcome back',
      _Mode.magicLink => 'Log in with a magic link',
      _Mode.reset => 'Reset your password',
    };
    final String blurb = switch (_mode) {
      _Mode.password => 'Log in with your email and password.',
      _Mode.magicLink => "We'll email you a magic link — no password needed.",
      _Mode.reset => "Enter your email and we'll send a reset link.",
    };
    final String submitLabel = switch (_mode) {
      _Mode.password => 'Log in',
      _Mode.magicLink => 'Email me a magic link',
      _Mode.reset => 'Send reset link',
    };
    return RatelScreen(
      title: 'Log in',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            key: const Key('login'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: RatelSpacing.sm),
              Text(heading, style: RatelType.headline),
              const SizedBox(height: RatelSpacing.xs),
              Text(blurb, style: RatelType.body.copyWith(color: t.onSurfaceVariant)),
              const SizedBox(height: RatelSpacing.xl),
              TextFormField(
                key: const Key('login-email'),
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                style: RatelType.body.copyWith(color: t.onSurface),
                decoration:
                    _decoration(t, label: 'Email', hint: 'you@example.com'),
                validator: _validateEmail,
              ),
              if (isPassword) ...[
                const SizedBox(height: RatelSpacing.lg),
                TextFormField(
                  key: const Key('login-password'),
                  controller: _passwordCtrl,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  style: RatelType.body.copyWith(color: t.onSurface),
                  decoration:
                      _decoration(t, label: 'Password', hint: 'Your password'),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: RatelButton(
                    key: const Key('login-forgot'),
                    label: 'Forgot password?',
                    kind: RatelButtonKind.text,
                    onPressed: _busy ? null : () => _switchTo(_Mode.reset),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: RatelSpacing.lg),
                Text(
                  _error!,
                  key: const Key('login-error'),
                  style: RatelType.body.copyWith(color: t.danger),
                ),
              ],
              const SizedBox(height: RatelSpacing.xl),
              RatelButton(
                key: const Key('login-submit'),
                label: submitLabel,
                expand: true,
                loading: _busy,
                onPressed: _busy ? null : _submit,
              ),
              const SizedBox(height: RatelSpacing.sm),
              if (isReset)
                RatelButton(
                  key: const Key('login-back'),
                  label: 'Back to log in',
                  kind: RatelButtonKind.text,
                  expand: true,
                  onPressed: _busy ? null : () => _switchTo(_Mode.password),
                )
              else
                RatelButton(
                  key: const Key('login-mode-toggle'),
                  label: isPassword
                      ? 'Use a magic link instead'
                      : 'Use a password instead',
                  kind: RatelButtonKind.text,
                  expand: true,
                  onPressed: _busy
                      ? null
                      : () => _switchTo(
                          isPassword ? _Mode.magicLink : _Mode.password),
                ),
              if (widget.onSignUpInstead != null)
                RatelButton(
                  key: const Key('login-signup-instead'),
                  label: "New here? Create an account",
                  kind: RatelButtonKind.text,
                  expand: true,
                  onPressed: _busy ? null : widget.onSignUpInstead,
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(RatelColorTokens t,
      {required String label, String? hint}) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: RatelType.body.copyWith(color: t.onSurfaceVariant),
      hintStyle: RatelType.body.copyWith(color: t.onSurfaceVariant),
      filled: true,
      fillColor: t.surfaceVariant,
      enabledBorder: border(t.outline),
      focusedBorder: border(t.primary),
      errorBorder: border(t.danger),
      focusedErrorBorder: border(t.danger),
      errorStyle: RatelType.caption.copyWith(color: t.danger),
    );
  }
}

/// Post-submit confirmation surface for the magic-link / password-reset paths.
class _SentNotice extends StatelessWidget {
  const _SentNotice({required this.kind, required this.email});

  final _Sent kind;
  final String email;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isMagic = kind == _Sent.magicLink;
    return Column(
      key: const Key('login-sent'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_unread_outlined, size: 64, color: t.primary),
        const SizedBox(height: RatelSpacing.lg),
        Text('Check your inbox',
            style: RatelType.headline, textAlign: TextAlign.center),
        const SizedBox(height: RatelSpacing.sm),
        Text(
          isMagic
              ? 'We sent a magic sign-in link to $email. Open it on this device to finish logging in.'
              : 'We sent a password-reset link to $email. Open it to choose a new password.',
          style: RatelType.body.copyWith(color: t.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
