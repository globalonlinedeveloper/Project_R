import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/services/billing/billing.dart';

export 'package:ratel/features/learner/learner_controller.dart';
export 'package:ratel/features/saved_words/saved_words_controller.dart';
export 'package:ratel/features/settings/settings_controller.dart';
export 'package:ratel/features/learner/daily_goal.dart';

/// Current Pro entitlement (design spec §4 PRO gating) — wraps the existing
/// billing `entitlementsProvider` (free tier by default; server-computed at
/// Stage 3, never client-asserted).
final isProProvider =
    Provider<bool>((ref) => ref.watch(entitlementsProvider).isPro);
