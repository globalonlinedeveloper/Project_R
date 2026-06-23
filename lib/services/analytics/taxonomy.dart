/// Analytics taxonomy & PII guard (R-M1 / R-K1 / R-K6 — Stage-4 validation
/// finding P0-5). The analytics seam's `props{}` is an OPEN container; without a
/// taxonomy allow-list enforced AT THE SEAM, a feature could smuggle PII, a
/// minor's identifier, or `auth.uid()` into an event and leak it to a vendor
/// SDK (Firebase/GA4) or an ad SDK (AdMob). Minors 13+ are in scope, so this is
/// a P0 privacy control.
///
/// This is the CLIENT-SIDE MIRROR of the schema's `additionalProperties:false`:
/// every event has a CLOSED set of allowed, non-identifying prop keys; anything
/// else is a violation. Enforced at runtime by `AllowListAnalytics` (see
/// `analytics.dart`) and at build time by `test/services/analytics_taxonomy_test.dart`
/// (which also statically scans `lib/` to prove no feature passes `auth.uid()`
/// into an event — validation finding P2-4).
library;

/// The curated, anonymous-first event taxonomy: event name -> the CLOSED set of
/// allowed prop keys. Keys are behavioural/aggregate only — never identifying.
/// Stage 3 EXTENDS this list deliberately (in a reviewed PR), never opens it.
class AnalyticsTaxonomy {
  const AnalyticsTaxonomy(this.allowedEvents);

  final Map<String, Set<String>> allowedEvents;

  /// The standard taxonomy shipped with the app. Add events here on purpose.
  static const AnalyticsTaxonomy standard = AnalyticsTaxonomy(<String, Set<String>>{
    'app_open': <String>{'cold_start'},
    'onboarding_step': <String>{'step', 'motivation', 'goal'},
    'onboarding_complete': <String>{'steps'},
    'lesson_start': <String>{'lesson_id', 'review'},
    'lesson_complete': <String>{'lesson_id', 'xp', 'accuracy', 'item_count', 'review'},
    'review_start': <String>{'item_count'},
    'streak_extended': <String>{'length'},
    'energy_depleted': <String>{},
    'paywall_viewed': <String>{'source'},
    'scene_start': <String>{'scene_id'},
    'scene_complete': <String>{'scene_id'},
  });

  /// Forbidden key TOKENS (a key is split on non-alphanumerics, each token is
  /// checked). Token-based (not naive substring) so a future legit key like
  /// `message_count` is not wrongly flagged for containing "age". Defense in
  /// depth on top of the closed allow-list: also catches a PII-ish key added to
  /// the taxonomy itself by mistake.
  static const Set<String> forbiddenKeyTokens = <String>{
    'email', 'phone', 'mobile', 'name', 'firstname', 'lastname', 'fullname',
    'address', 'street', 'city', 'zip', 'postal', 'dob', 'birthday', 'birthdate',
    'age', 'gender', 'ssn', 'passport',
    'uid', 'user', 'userid', 'auth', 'authuid', 'account',
    'ip', 'ipaddress', 'lat', 'lng', 'lon', 'latitude', 'longitude', 'geo',
    'gps', 'location',
    'password', 'passwd', 'secret', 'token', 'apikey',
    'voice', 'voiceprint', 'audio', 'speech', 'transcript', 'raw',
  };

  static final RegExp _emailRe = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');
  // auth.uid() values are Supabase/Postgres UUIDs — catch one smuggled as text.
  static final RegExp _uuidRe = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false);

  static bool _looksLikePii(Object? value) {
    if (value is! String) return false;
    final s = value.trim();
    if (_emailRe.hasMatch(s)) return true;
    if (_uuidRe.hasMatch(s)) return true; // very likely an auth.uid()
    return false;
  }

  /// Returns the list of violations for an event. Empty list == clean.
  List<String> validate(String name, Map<String, Object?> props) {
    final Set<String>? allowed = allowedEvents[name];
    if (allowed == null) {
      return <String>['unknown event "$name" (not in the analytics taxonomy)'];
    }
    final violations = <String>[];
    for (final entry in props.entries) {
      final key = entry.key;
      if (!allowed.contains(key)) {
        violations.add(
            'event "$name": prop "$key" not in allow-list {${allowed.join(', ')}}');
      }
      final tokens = key.toLowerCase().split(RegExp(r'[^a-z0-9]+'));
      for (final t in tokens) {
        if (forbiddenKeyTokens.contains(t)) {
          violations.add(
              'event "$name": prop "$key" contains forbidden identifier token "$t" (PII/auth.uid)');
          break;
        }
      }
      if (_looksLikePii(entry.value)) {
        violations.add(
            'event "$name": prop "$key" value looks like PII (email or auth.uid UUID)');
      }
    }
    return violations;
  }
}
