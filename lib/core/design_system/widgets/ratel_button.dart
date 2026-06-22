import 'package:flutter/material.dart';
import '../context_ext.dart';
import '../tokens/ratel_color_tokens.dart';
import '../tokens/ratel_spacing.dart';
import '../tokens/ratel_typography.dart';

enum RatelButtonKind { primary, secondary, text }

/// Tokenized button built over Material so it inherits accessible state layers
/// (rest / hover / focus-visible / pressed / disabled — R-L17) and the 48dp
/// tap target (R-K8), plus a [loading] state. Colors/shape come from tokens.
class RatelButton extends StatelessWidget {
  const RatelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = RatelButtonKind.primary,
    this.loading = false,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final RatelButtonKind kind;
  final bool loading;
  final IconData? icon;
  final bool expand;

  Color _fg(RatelColorTokens t) {
    switch (kind) {
      case RatelButtonKind.primary:
        return t.onPrimary;
      case RatelButtonKind.secondary:
        return t.onSurface;
      case RatelButtonKind.text:
        return t.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final disabled = onPressed == null || loading;

    final Widget content = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_fg(t)),
            ),
          )
        : (icon == null
            ? Text(label, style: RatelType.label)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: RatelSpacing.sm),
                  Text(label, style: RatelType.label),
                ],
              ));

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
    );
    final minSize = const Size(0, RatelSpacing.minTapTarget);
    final pad = const EdgeInsets.symmetric(
        horizontal: RatelSpacing.xl, vertical: RatelSpacing.md);

    Widget button;
    switch (kind) {
      case RatelButtonKind.primary:
        button = FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: t.primary,
            foregroundColor: t.onPrimary,
            disabledBackgroundColor: t.outline.withValues(alpha: 0.18),
            disabledForegroundColor: t.onSurfaceVariant.withValues(alpha: 0.6),
            minimumSize: minSize,
            padding: pad,
            shape: shape,
            textStyle: RatelType.label,
          ),
          child: content,
        );
      case RatelButtonKind.secondary:
        button = FilledButton.tonal(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: t.surfaceVariant,
            foregroundColor: t.onSurface,
            disabledBackgroundColor: t.surfaceVariant.withValues(alpha: 0.5),
            disabledForegroundColor: t.onSurfaceVariant.withValues(alpha: 0.6),
            minimumSize: minSize,
            padding: pad,
            shape: shape,
            textStyle: RatelType.label,
          ),
          child: content,
        );
      case RatelButtonKind.text:
        button = TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: t.primary,
            disabledForegroundColor: t.onSurfaceVariant.withValues(alpha: 0.6),
            minimumSize: minSize,
            padding: pad,
            shape: shape,
            textStyle: RatelType.label,
          ),
          child: content,
        );
    }

    final sized = expand ? SizedBox(width: double.infinity, child: button) : button;
    // Keep the label announced even while the spinner replaces it.
    return loading
        ? Semantics(label: label, button: true, enabled: false, child: sized)
        : sized;
  }
}
