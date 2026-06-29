import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';

/// Leagues tab (🏆) — design spec §4.3. There is NO leaderboard / cohort engine
/// in lib/services (§6), so this is an HONEST stub: it describes the planned
/// weekly-league design, flags it as an owner decision, and NEVER shows a
/// fabricated leaderboard. The top bar still surfaces the REAL streak.
class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    return Container(
      key: const ValueKey<String>('tab-leagues'),
      color: context.palette.cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RatelTopBar(
                flagEmoji: '🇪🇸', langCode: 'ES', streak: snap.streakDays),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                    RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
                children: <Widget>[
                  RatelCard(
                    child: Column(
                      children: <Widget>[
                        const Text('🏆', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: RatelSpace.md),
                        Text('Leagues are coming',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: RatelFont.display,
                                fontWeight: RatelType.extraBold,
                                fontSize: RatelType.screenTitle,
                                color: context.palette.ink)),
                        const SizedBox(height: RatelSpace.sm),
                        Text(
                            'Weekly leaderboards with promotion & demotion zones '
                            '(Gold League, "Top 7 advance") need a cohort / '
                            'leaderboard backend. There is no engine for this yet '
                            '— it is an owner decision, and we will never show a '
                            'fake leaderboard.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: RatelFont.body,
                                fontSize: RatelType.body,
                                color: context.palette.muted,
                                height: 1.4)),
                        const SizedBox(height: RatelSpace.md),
                        const RatelChip(
                            label: 'Owner decision',
                            tone: RatelChipTone.amber,
                            filled: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
