import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// One bottom-nav destination.
class RatelNavTab {
  const RatelNavTab({required this.emoji, required this.label});

  final String emoji;
  final String label;
}

/// The 5-tab bottom navigation spine (design spec §3). Active tab = a teal
/// rounded pill behind the emoji + a teal label; inactive = muted.
class RatelBottomNav extends StatelessWidget {
  const RatelBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.tabs = defaultTabs,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<RatelNavTab> tabs;

  /// The default Ratel spine: Home · Library · Leagues · Quests · Profile.
  static const List<RatelNavTab> defaultTabs = <RatelNavTab>[
    RatelNavTab(emoji: '🏠', label: 'Home'),
    RatelNavTab(emoji: '📚', label: 'Library'),
    RatelNavTab(emoji: '🏆', label: 'Leagues'),
    RatelNavTab(emoji: '🎯', label: 'Quests'),
    RatelNavTab(emoji: '🦡', label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.white,
        border: Border(top: BorderSide(color: context.palette.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: tabs[i],
                    active: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final RatelNavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: tab.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RatelSpace.lg,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: active
                    ? RatelColors.teal.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(RatelRadius.pill),
              ),
              // M-1: the emoji is a pictogram, not prose — pin its scale so
              // the fixed-height bar survives 200% font scale; the LABEL below
              // (the accessible part) keeps scaling with the user setting.
              child: Text(
                tab.emoji,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 2),
            // M-1: Flexible+FittedBox — identity at normal scale; at very large
            // font scales the label compresses to fit the 64px bar instead of
            // overflowing (gauntlet @200%).
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontSize: 10,
                    fontWeight: RatelType.extraBold,
                    color: active ? RatelColors.teal : context.palette.muted,
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
