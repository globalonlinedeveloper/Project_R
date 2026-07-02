import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';

/// Formats a count the way the design's top bar does for gems/diamonds
/// (`Ratel App.dc.html`:3492):
///
/// ```js
/// gems = S.gems >= 1000
///   ? (S.gems/1000).toFixed(2).replace(/0$/,'') + 'k'
///   : S.gems
/// ```
///
/// So values < 1000 render verbatim, and values >= 1000 render as thousands
/// with two decimals, then *one* trailing zero stripped:
///   1240 -> "1.24k", 1200 -> "1.2k", 1000 -> "1.0k", 2000 -> "2.0k".
///
/// Pure -- no providers, no context.
String formatCount(int n) {
  if (n < 1000) return '$n';
  // toFixed(2) then strip a SINGLE trailing '0' (mirrors JS /0$/ replace).
  var s = (n / 1000).toStringAsFixed(2);
  if (s.endsWith('0')) s = s.substring(0, s.length - 1);
  return '${s}k';
}

/// Formats the energy label the way the design's top bar does
/// (`Ratel App.dc.html`:3502): `energyLabel = S.isPro ? '∞' : S.energy`.
///
/// Pass [unlimited] (the Pro flag, resolved by the caller) to get the infinity
/// glyph; otherwise the raw count. Pure -- no providers.
String formatEnergy(int e, {required bool unlimited}) {
  return unlimited ? '∞' : '$e';
}

/// A pure, static economy stat glyph: an emoji + its formatted value, as shown
/// in the top-bar economy cluster (`Ratel App.dc.html`:100-121).
///
/// This widget is intentionally motionless -- the design's per-glyph twinkle /
/// flicker animations (`rflame`/`relec`/`rsparkle`) are gated OFF under the
/// reduce-motion floor, and this authoring pass ships the static form so it is
/// safe in every motion setting. The integrating screen supplies the already
/// formatted [value] (via [formatCount] / [formatEnergy]) and, optionally, the
/// themed digit [color].
class EconomyGlyph extends StatelessWidget {
  const EconomyGlyph({
    super.key,
    required this.emoji,
    required this.value,
    this.color,
    this.onTap,
  });

  /// The stat's leading emoji (e.g. 🔥 / ⚡ / 💎).
  final String emoji;

  /// The pre-formatted value string (e.g. "7", "1.24k", "∞").
  final String value;

  /// Digit colour. Defaults to the primary ink colour of the active palette.
  final Color? color;

  /// Optional tap handler (e.g. open the streak / energy / gems screen).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final digitColor = color ?? context.palette.ink;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: digitColor,
          ),
        ),
      ],
    );

    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}
