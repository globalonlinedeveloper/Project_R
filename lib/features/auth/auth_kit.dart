import 'package:flutter/material.dart';

import 'package:ratel/core/core.dart';

/// Shared, token-driven building blocks for the Login + Signup screens
/// (design spec — auth screens). Kept here so both screens render the EXACT
/// same chrome (🦡 header, social buttons, "or" divider, bordered fields,
/// footer cross-link) without duplicating widget code. Raw `Color(` is never
/// used — only named [RatelColors] tokens (token-lint clean).

/// Top-of-screen back chevron (full-screen pushed route → its own back arrow).
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: context.palette.ink),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

/// Centered 🦡 + title + subtitle.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text('🦡', style: TextStyle(fontSize: 62)),
        const SizedBox(height: RatelSpace.sm),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            fontSize: RatelType.screenTitle,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: RatelSpace.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: RatelFont.body,
            fontWeight: RatelType.semiBold,
            fontSize: RatelType.small,
            color: context.palette.muted,
          ),
        ),
      ],
    );
  }
}

/// Google + Apple "continue with" buttons. There is NO OAuth engine wired yet,
/// so tapping either is an honest no-op handler (the screen shows a "coming
/// soon" notice) — a session is NEVER faked (§6 honesty).
class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SocialButton(
          key: const Key('auth-google'),
          label: 'Continue with Google',
          emoji: '🔵',
          background: context.palette.white,
          foreground: context.palette.ink,
          border: context.palette.border,
          onTap: onTap,
        ),
        const SizedBox(height: RatelSpace.sm),
        _SocialButton(
          key: const Key('auth-apple'),
          label: 'Continue with Apple',
          emoji: '',
          background: context.palette.ink,
          foreground: context.palette.white,
          border: context.palette.ink,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    super.key,
    required this.label,
    required this.emoji,
    required this.background,
    required this.foreground,
    required this.border,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color background;
  final Color foreground;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RatelRadius.card),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border, width: 1.5),
          borderRadius: BorderRadius.circular(RatelRadius.card),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (emoji.isNotEmpty) ...<Widget>[
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: RatelSpace.sm),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontWeight: RatelType.extraBold,
                  fontSize: RatelType.body,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal rule with a centered "or".
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    Widget line = Expanded(child: Divider(color: context.palette.border, thickness: 1));
    return Row(
      children: <Widget>[
        line,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: RatelSpace.md),
          child: Text(
            'or',
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontWeight: RatelType.semiBold,
              fontSize: RatelType.small,
              color: context.palette.muted,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

/// A bordered email/password field (the foundation has no text-field component,
/// so this is the inline token-styled input — coral border on error).
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.emoji,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.errorText,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String emoji;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.lg, vertical: RatelSpace.xs),
          decoration: BoxDecoration(
            color: context.palette.white,
            border: Border.all(
                color: hasError ? RatelColors.coral : context.palette.border,
                width: 1.5),
            borderRadius: BorderRadius.circular(RatelRadius.card),
          ),
          child: Row(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: RatelSpace.sm),
              Expanded(
                child: TextField(
                  key: fieldKey,
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  onSubmitted: onSubmitted,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontWeight: RatelType.medium,
                    fontSize: RatelType.body,
                    color: context.palette.ink,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontFamily: RatelFont.body,
                      fontWeight: RatelType.medium,
                      fontSize: RatelType.body,
                      color: context.palette.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...<Widget>[
          const SizedBox(height: RatelSpace.xs),
          Text(
            errorText!,
            style: const TextStyle(
              fontFamily: RatelFont.body,
              fontWeight: RatelType.semiBold,
              fontSize: RatelType.small,
              color: RatelColors.coral,
            ),
          ),
        ],
      ],
    );
  }
}

/// Honest banner shown when no auth backend is wired (the default local build):
/// the form is real but fail-closes, so this explains why (§6).
class AuthUnavailableBanner extends StatelessWidget {
  const AuthUnavailableBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('auth-unavailable'),
      padding: const EdgeInsets.all(RatelSpace.md),
      decoration: BoxDecoration(
        color: context.palette.cream2,
        border: Border.all(color: context.palette.border, width: 1.5),
        borderRadius: BorderRadius.circular(RatelRadius.card),
      ),
      child: Text(
        'Accounts aren’t available in this build yet — you can keep learning as '
        'a guest. Sign-in turns on when the backend is configured.',
        style: TextStyle(
          fontFamily: RatelFont.body,
          fontWeight: RatelType.semiBold,
          fontSize: RatelType.small,
          color: context.palette.ink,
        ),
      ),
    );
  }
}

/// Centered "lead linkText" footer where linkText is a teal tappable.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.lead,
    required this.linkText,
    required this.onTap,
  });

  final String lead;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          lead,
          style: TextStyle(
            fontFamily: RatelFont.body,
            fontWeight: RatelType.semiBold,
            fontSize: RatelType.small,
            color: context.palette.muted,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: const TextStyle(
              fontFamily: RatelFont.body,
              fontWeight: RatelType.extraBold,
              fontSize: RatelType.small,
              color: RatelColors.teal,
            ),
          ),
        ),
      ],
    );
  }
}
