import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/foundation_tab.dart';

/// Quests tab (🎯) — design spec §4.4. Daily Refresh / daily-goal XP are REAL
/// (learning + learner_state); quest tracking + rewards + friend quest have NO
/// engine (design spec §6) — flagged for an owner decision.
class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FoundationTab(
      key: ValueKey<String>('tab-quests'),
      title: 'Quests',
      topBar: RatelTopBar(flagEmoji: '🇪🇸', langCode: 'ES'),
      note: Text('Quest tracking + rewards need a backend — an owner decision (spec §6).'),
    );
  }
}
