import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Fixed top bar for the tab screens (design spec §3).
///
/// Left = a tappable language flag pill (`🇪🇸 ES ▾`). Right = a cluster of
/// stat chips. Each stat is OPTIONAL and only renders when a non-null value is
/// supplied — so a screen surfaces only what is REAL (e.g. energy / diamonds
/// have no backend engine yet, so they stay hidden rather than showing a faked
/// number — design spec §6). The cluster scales-down to fit narrow phones, so
/// it can never overflow the bar.
class RatelTopBar extends StatelessWidget {
  const RatelTopBar({
    super.key,
    required this.flagEmoji,
    required this.langCode,
    this.onLanguageTap,
    this.streak,
    this.energy,
    this.diamonds,
    this.streakFreeze,
    this.onThemeTap,
  });

  final String flagEmoji;
  final String langCode;
  final VoidCallback? onLanguageTap;

  /// 🔥 streak day count (null hides the chip).
  final int? streak;

  /// ⚡ energy count (null hides — no engine yet, do not fake).
  final int? energy;

  /// 💎 diamonds display string (null hides — no engine yet, do not fake).
  final String? diamonds;

  /// 💪 streak-freeze count (null hides — no engine yet).
  final int? streakFreeze;

  /// 🎨 theme picker (null hides the button).
  final VoidCallback? onThemeTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: RatelSpace.screen),
        child: Row(
          children: <Widget>[
            _FlagPill(
              flagEmoji: flagEmoji,
              langCode: langCode,
              onTap: onLanguageTap,
            ),
            const SizedBox(width: RatelSpace.sm),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (streakFreeze != null)
                        _Stat(emoji: '💪', value: '$streakFreeze'),
                      if (streak != null) _Stat(emoji: '🔥', value: '$streak'),
                      if (energy != null) _Stat(emoji: '⚡', value: '$energy'),
                      if (diamonds != null)
                        _Stat(emoji: '💎', value: diamonds!),
                      if (onThemeTap != null)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onThemeTap,
                          child: const Padding(
                            padding: EdgeInsets.only(left: RatelSpace.sm),
                            child: Text('🎨', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagPill extends StatelessWidget {
  const _FlagPill({
    required this.flagEmoji,
    required this.langCode,
    this.onTap,
  });

  final String flagEmoji;
  final String langCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RatelSpace.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: RatelColors.white,
          borderRadius: BorderRadius.circular(RatelRadius.pill),
          border: Border.all(color: RatelColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(flagEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              langCode,
              style: const TextStyle(
                fontFamily: RatelFont.display,
                fontSize: RatelType.small,
                fontWeight: RatelType.extraBold,
                color: RatelColors.ink,
              ),
            ),
            const Text('  ▾',
                style: TextStyle(fontSize: 11, color: RatelColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.emoji, required this.value});

  final String emoji;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: RatelSpace.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: RatelFont.display,
              fontSize: RatelType.small,
              fontWeight: RatelType.extraBold,
              color: RatelColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
