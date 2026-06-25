import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import 'auth_service.dart';

/// Account creation (R-L1): email + password, or a passwordless magic link.
/// Lives behind `authEnabled` and is reachable from the guest-first Welcome
/// screen. Talks to Supabase only through the injected [authServiceProvider]
/// seam, so it is fully testable with a fake and carries no backend types.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({
    super.key,
    this.onAuthenticated,
    this.onSignInInstead,
  });

  /// Fired when a session is established (the router navigates into the app).
  final VoidCallback? onAuthenticated;

  /// Optional "already have an account? Log in" path — wired when Login lands (#4).
  final VoidCallback? onSignInInstead;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

enum _Mode { password, magicLink }

enum _Sent { confirmEmail, magicLink }

class _SignupScreenState extends ConsumerState<SignupScreen> {
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
    final value = v ?? '';
    if (value.isEmpty) return 'Enter a password';
    if (value.length < 8) return 'At least 8 characters';
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
      final AuthOutcome outcome = _mode == _Mode.password
          ? await auth.signUpWithPassword(
              email: email, password: _passwordCtrl.text)
          : await auth.sendMagicLink(email: email);
      if (!mounted) return;
      if (outcome == AuthOutcome.session) {
        widget.onAuthenticated?.call();
      } else {
        setState(() => _sent =
            _mode == _Mode.password ? _Sent.confirmEmail : _Sent.magicLink);
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

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (_sent != null) {
      return RatelScreen(
        title: 'Create account',
        child: _SentNotice(kind: _sent!, email: _emailCtrl.text.trim()),
      );
    }
    final isPassword = _mode == _Mode.password;
    return RatelScreen(
      title: 'Create account',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            key: const Key('signup'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: RatelSpacing.sm),
              Text('Create your account', style: RatelType.headline),
              const SizedBox(height: RatelSpacing.xs),
              Text(
                isPassword
                    ? 'Sign up with your email and a password.'
                    : "We'll email you a magic link — no password needed.",
                style: RatelType.body.copyWith(color: t.onSurfaceVariant),
              ),
              const SizedBox(height: RatelSpacing.xl),
              TextFormField(
                key: const Key('signup-email'),
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
                  key: const Key('signup-password'),
                  controller: _passwordCtrl,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  style: RatelType.body.copyWith(color: t.onSurface),
                  decoration: _decoration(t,
                      label: 'Password', hint: 'Create a password'),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: RatelSpacing.lg),
                Text(
                  _error!,
                  key: const Key('signup-error'),
                  style: RatelType.body.copyWith(color: t.danger),
                ),
              ],
              const SizedBox(height: RatelSpacing.xl),
              RatelButton(
                key: const Key('signup-submit'),
                label: isPassword ? 'Create account' : 'Email me a magic link',
                expand: true,
                loading: _busy,
                onPressed: _busy ? null : _submit,
              ),
              const SizedBox(height: RatelSpacing.sm),
              RatelButton(
                key: const Key('signup-mode-toggle'),
                label: isPassword
                    ? 'Use a magic link instead'
                    : 'Use a password instead',
                kind: RatelButtonKind.text,
                expand: true,
                onPressed: _busy
                    ? null
                    : () => setState(() {
                          _mode = isPassword ? _Mode.magicLink : _Mode.password;
                          _error = null;
                        }),
              ),
              if (widget.onSignInInstead != null)
                RatelButton(
                  key: const Key('signup-signin-instead'),
                  label: 'I already have an account',
                  kind: RatelButtonKind.text,
                  expand: true,
                  onPressed: _busy ? null : widget.onSignInInstead,
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

/// Post-submit confirmation surface for the email-verification / magic-link path.
class _SentNotice extends StatelessWidget {
  const _SentNotice({required this.kind, required this.email});

  final _Sent kind;
  final String email;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isMagic = kind == _Sent.magicLink;
    return Column(
      key: const Key('signup-sent'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_unread_outlined, size: 64, color: t.primary),
        const SizedBox(height: RatelSpacing.lg),
        Text(
          isMagic ? 'Check your inbox' : 'Confirm your email',
          style: RatelType.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: RatelSpacing.sm),
        Text(
          isMagic
              ? 'We sent a magic sign-in link to $email. Open it on this device to finish signing in.'
              : 'We sent a confirmation link to $email. Tap it to activate your account, then come back to log in.',
          style: RatelType.body.copyWith(color: t.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
