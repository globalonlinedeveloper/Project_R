import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/foundation_tab.dart';

/// Home tab (🏠) — the learning path (design spec §4.1). Foundation placeholder
/// wired to the real learner snapshot (streak surfaced in the top bar).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    return FoundationTab(
      key: const ValueKey<String>('tab-home'),
      title: 'Home',
      topBar: RatelTopBar(
        flagEmoji: '🇪🇸',
        langCode: 'ES',
        streak: snap.streakDays,
      ),
      note: const Text('Your learning path is built in P2.'),
    );
  }
}
