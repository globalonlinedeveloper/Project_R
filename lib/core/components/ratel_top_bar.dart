import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/ratel_icons.dart';

/// Fixed top bar for the tab screens (design spec §3).
///
/// Left = a tappable language flag pill (`🇪🇸 ES ▾`). Right = a cluster of
/// stat chips plus optional action buttons (🔔 notifications, 🎨 theme). Each
/// stat is OPTIONAL and only renders when a non-null value is supplied — so a
/// screen surfaces only what is REAL (e.g. energy / diamonds have no backend
/// engine yet, so they stay hidden rather than showing a faked number — design
/// spec §6). The cluster scales-down to fit narrow phones, so it can never
/// overflow the bar.
class RatelTopBar extends StatelessWidget {
  const RatelTopBar({
    super.key,
    required this.flagEmoji,
    required this.langCode,
    this.onLanguageTap,
    this.streak,
    this.energy,
    this.energyLabel,
    this.diamonds,
    this.streakFreeze,
    this.onStreakTap,
    this.onEnergyTap,
    this.onNotificationsTap,
    this.unreadNotifications = 0,
    this.onThemeTap,
  });

  final String flagEmoji;
  final String langCode;
  final VoidCallback? onLanguageTap;

  /// 🔥 streak day count (null hides the chip).
  final int? streak;

  /// ⚡ energy count (null hides — no engine yet, do not fake).
  final int? energy;

  /// ⚡ energy display-label override (e.g. '∞' for Pro). When non-null it
  /// replaces [energy] verbatim; null → use [energy]. Lets a caller show the
  /// design's Pro-infinity glyph without faking a numeric count.
  final String? energyLabel;

  /// 💎 diamonds display string (null hides — no engine yet, do not fake).
  final String? diamonds;

  /// 💪 streak-freeze count (null hides — no engine yet).
  final int? streakFreeze;

  /// Opens the Streak screen from the 🔥 chip (null → chip is not tappable).
  final VoidCallback? onStreakTap;

  /// Opens the Energy screen from the ⚡ chip (null → chip is not tappable).
  final VoidCallback? onEnergyTap;

  /// 🔔 opens the in-app notifications inbox (null hides the bell button).
  final VoidCallback? onNotificationsTap;

  /// Count of earned-but-unseen notifications. Shows a coral count badge on the
  /// bell when > 0 (0 = bell with no badge). Only meaningful when
  /// [onNotificationsTap] is supplied, so the count is REAL learner-derived
  /// state, never a faked number.
  final int unreadNotifications;

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
                      if (streak != null)
                        _Stat(
                            emoji: '🔥',
                            value: '$streak',
                            onTap: onStreakTap),
                      if (energyLabel != null)
                        _Stat(
                            emoji: '⚡',
                            value: energyLabel!,
                            onTap: onEnergyTap)
                      else if (energy != null)
                        _Stat(
                            emoji: '⚡',
                            value: '$energy',
                            onTap: onEnergyTap),
                      if (diamonds != null)
                        _Stat(emoji: '💎', value: diamonds!),
                      if (onThemeTap != null)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onThemeTap,
                          child: Padding(
                            padding: const EdgeInsets.only(left: RatelSpace.sm),
                            child: Icon(RatelIcons.palette,
                                size: 20, color: context.palette.ink),
                          ),
                        ),
                      if (onNotificationsTap != null)
                        _BellButton(
                          unread: unreadNotifications,
                          onTap: onNotificationsTap!,
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
          color: context.palette.white,
          borderRadius: BorderRadius.circular(RatelRadius.pill),
          border: Border.all(color: context.palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(flagEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              langCode,
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontSize: RatelType.small,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(width: 2),
            Icon(RatelIcons.arrowDropDown,
                size: 18, color: context.palette.muted),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.emoji, required this.value, this.onTap});

  final String emoji;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.only(left: RatelSpace.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              fontFamily: RatelFont.display,
              fontSize: RatelType.small,
              fontWeight: RatelType.extraBold,
              color: context.palette.ink,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}

/// 🔔 inbox button with an optional coral unread-count badge. The badge text is
/// constant-white on the constant coral accent (legible in light AND dark),
/// while the separating ring uses the theme surface so it reads cleanly on any
/// bar background. Caps the display at `9+` so the cluster stays compact.
class _BellButton extends StatelessWidget {
  const _BellButton({required this.unread, required this.onTap});

  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: RatelSpace.sm),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Icon(RatelIcons.notifications,
                size: 20, color: context.palette.ink),
            if (unread > 0)
              Positioned(
                top: -5,
                right: -7,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: RatelColors.coral,
                    borderRadius: BorderRadius.circular(RatelRadius.pill),
                    border:
                        Border.all(color: context.palette.white, width: 1.5),
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: RatelFont.display,
                      fontSize: 10,
                      height: 1.1,
                      fontWeight: RatelType.extraBold,
                      color: RatelColors.white,
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

/// The top-bar language flag for a course, DERIVED from the active course code
/// (the batch locale, e.g. 'es'). Single source of truth so the Home, Leagues
/// and Quests top bars always agree (D-L8/Q7): before this, Home derived the
/// flag while Leagues/Quests hard-coded EN, so a non-EN course showed the wrong
/// flag on those two tabs. An unmapped/empty code falls back to the 🦡 mascot
/// (matching Home's original behaviour — a country flag per course is a
/// separate polish item, A-H2).
String courseFlagEmoji(String code) {
  switch (code) {
    case 'en':
      return '🇬🇧';
    case 'ja':
      return '🇯🇵';
    case 'ta':
      return '🇮🇳';
    default:
      return '🦡';
  }
}

/// The top-bar language code label for a course (the uppercased course code).
/// Paired with [courseFlagEmoji] so the flag pill is fully course-derived.
String courseLangCode(String code) => code.toUpperCase();
