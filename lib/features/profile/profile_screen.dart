import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/foundation_tab.dart';

/// Profile tab (🦡) — design spec §4.5. Foundation placeholder wired to the REAL
/// learner snapshot: CEFR level (from θ via cold_start), lessons + saved words.
/// Fresh/wiped backend ⇒ A1 · 0 · 0 (honest — not the mockup's A2 · 1,240 XP).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final int words = ref.watch(savedWordsControllerProvider);
    final String level = snap.level.name.toUpperCase();
    return FoundationTab(
      key: const ValueKey<String>('tab-profile'),
      title: 'Profile',
      topBar: RatelTopBar(
        flagEmoji: '🇪🇸',
        langCode: 'ES',
        streak: snap.streakDays,
      ),
      note: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RatelChip.level(level),
          const SizedBox(height: RatelSpace.sm),
          Text(
            '${snap.lessonsCompleted} lessons · ${snap.xpTotal} XP · $words words (real)',
          ),
          const SizedBox(height: RatelSpace.xs),
          const Text('Your profile is built in P2.'),
        ],
      ),
    );
  }
}
