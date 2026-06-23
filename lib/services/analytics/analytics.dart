import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Portability seam (R-M1): analytics. Anonymous-first — NO PII, no raw speech;
/// events key only on a pseudonymous id, never `auth.uid()`. Stage 3 swaps in a
/// concrete sink behind a taxonomy allow-list without touching feature code.
abstract interface class Analytics {
  void logEvent(String name, {Map<String, Object?> props});
}

/// Default (local / Stage 1–2): no-op sink (collects nothing).
class NoopAnalytics implements Analytics {
  const NoopAnalytics();
  @override
  void logEvent(String name, {Map<String, Object?> props = const {}}) {}
}

final analyticsProvider = Provider<Analytics>((ref) => const NoopAnalytics());
