import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'taxonomy.dart';

export 'taxonomy.dart';
export 'analytics_identity.dart';

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

/// Enforces an [AnalyticsTaxonomy] allow-list AT THE SEAM (validation finding
/// P0-5). Wraps any concrete sink:
///   • in DEBUG it `assert`s — so tests + CI fail LOUD on a taxonomy violation;
///   • in RELEASE it FAILS CLOSED — a violating event is dropped, never
///     forwarded to the vendor/ad SDK.
/// This is the client-side mirror of the schema's `additionalProperties:false`:
/// unknown events, unknown prop keys, PII-ish keys, and PII-looking values
/// (emails, `auth.uid()` UUIDs) are all refused before reaching the delegate.
class AllowListAnalytics implements Analytics {
  const AllowListAnalytics(this._delegate,
      [this._taxonomy = AnalyticsTaxonomy.standard]);

  final Analytics _delegate;
  final AnalyticsTaxonomy _taxonomy;

  @override
  void logEvent(String name, {Map<String, Object?> props = const {}}) {
    final violations = _taxonomy.validate(name, props);
    assert(violations.isEmpty,
        'Analytics taxonomy violation (P0-5 PII guard):\n${violations.join('\n')}');
    if (violations.isNotEmpty) return; // fail closed — never forward PII
    _delegate.logEvent(name, props: props);
  }
}

/// The seam is allow-list-enforced FROM DAY ONE: even the local no-op default is
/// wrapped, so any feature that logs an off-taxonomy event trips the guard in
/// tests immediately (not first in Stage 3). Stage 3 overrides the delegate with
/// a real sink — still behind [AllowListAnalytics].
final analyticsProvider =
    Provider<Analytics>((ref) => const AllowListAnalytics(NoopAnalytics()));
