import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';

/// The sticky unit banner at the top of the learning path
/// (`Ratel App.dc.html`:128-137).
///
/// A teal rounded bar with a two-line label on the left — a small [kicker]
/// ("SECTION 1 · LEVEL A1", the authored section string) and the named unit
/// title ("Level A1") — and a tappable 📖 Guide chip on the right.
///
/// Pure: takes all copy via constructor params and a single [onGuide]
/// `VoidCallback` (the integrating screen wires it to navigation, e.g.
/// `context.go('/library')`). No providers, no motion.
///
/// Design values ported: container `padding:11px 14px; border-radius:18px;
/// background:var(--accent)` (teal); kicker `font-size:10px; weight:800;
/// letter-spacing:1px; opacity:.8; color:var(--ink,#fff)`; title
/// `font-size:17px; weight:800; color:var(--ink,#fff)`; guide chip
/// `background:rgba(255,255,255,.22); border-radius:12px; padding:7px 9px;
/// gap:5px`, 📖 at 15px + bold "Guide" at 11px.
///
/// The kicker text stays HONEST to the wired course content (the CEFR section
/// string authored in the ContentBatch), rather than the design's mock
/// "SECTION n · UNIT m" copy which has no engine behind it (SPEC_HOME_PATH D3).
class UnitBanner extends StatelessWidget {
  const UnitBanner({
    super.key,
    required this.kicker,
    required this.unitTitle,
    this.onGuide,
  });

  /// The small upper label — the authored section string (e.g.
  /// "SECTION 1 · LEVEL A1").
  final String kicker;

  /// The named unit title shown on the second line (e.g. "Level A1").
  final String unitTitle;

  /// Tapped when the 📖 Guide chip is pressed. Null hides the chip's tap.
  final VoidCallback? onGuide;

  @override
  Widget build(BuildContext context) {
    // Design glyph colour on the teal banner is --ink = #fff (onColor).
    final onTeal = RatelColors.onColor;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: RatelColors.teal,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: context.palette.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    kicker,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: onTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unitTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: onTeal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _GuideChip(onGuide: onGuide, foreground: onTeal),
        ],
      ),
    );
  }
}

class _GuideChip extends StatelessWidget {
  const _GuideChip({required this.onGuide, required this.foreground});

  final VoidCallback? onGuide;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onGuide,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          // rgba(255,255,255,.22) over the teal banner.
          color: RatelColors.onColor.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📖', style: TextStyle(fontSize: 15)),
            const SizedBox(width: 5),
            Text(
              context.l10n.homeGuideChip,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
