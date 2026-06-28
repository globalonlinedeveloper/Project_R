import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/foundation_tab.dart';

/// Leagues tab (🏆) — design spec §4.3. NO backend engine exists for leagues /
/// leaderboards (design spec §6) — flagged honestly rather than faked.
class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FoundationTab(
      key: ValueKey<String>('tab-leagues'),
      title: 'Leagues',
      topBar: RatelTopBar(flagEmoji: '🇪🇸', langCode: 'ES'),
      note: Text('Leagues need a leaderboard backend — an owner decision (spec §6), not faked.'),
    );
  }
}
