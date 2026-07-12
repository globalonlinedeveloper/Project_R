import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A list row (design spec §3) — a leading emoji medallion + title (+ optional
/// subtitle) + a trailing widget (defaults to a chevron when [onTap] is set).
/// Used for Profile menu rows, Shop items, Library lists, Settings rows.
class RatelListRow extends StatelessWidget {
  const RatelListRow({
    super.key,
    this.leadingEmoji,
    this.leadingColor,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  final String? leadingEmoji;
  final Color? leadingColor;

  /// Optional leading WIDGET (e.g. an SVG country flag). Takes precedence over
  /// [leadingEmoji] when both are set.
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// M-3: optional long-press affordance (e.g. Adventures scene preview).
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final Widget? trail = trailing ??
        (onTap != null
            ? Text(
                '›',
                style: TextStyle(
                  fontFamily: RatelFont.display,
                  fontSize: 22,
                  fontWeight: RatelType.extraBold,
                  color: context.palette.muted,
                ),
              )
            : null);

    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: RatelSpace.sm),
          child: Row(
            children: <Widget>[
              if (leading != null) ...<Widget>[
                leading!,
                const SizedBox(width: RatelSpace.md),
              ] else if (leadingEmoji != null) ...<Widget>[
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (leadingColor ?? context.palette.muted)
                        .withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Text(leadingEmoji!,
                      style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: RatelSpace.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        style: t.titleMedium, overflow: TextOverflow.ellipsis),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: t.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (trail != null) ...<Widget>[
                const SizedBox(width: RatelSpace.sm),
                trail,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
