import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

/// Records what actually reached the sink, so we can prove a violating event is
/// dropped (never forwarded) by `AllowListAnalytics`.
class _SpyAnalytics implements Analytics {
  final List<String> events = <String>[];
  @override
  void logEvent(String name, {Map<String, Object?> props = const {}}) =>
      events.add(name);
}

void main() {
  const tax = AnalyticsTaxonomy.standard;

  group('AnalyticsTaxonomy allow-list (P0-5)', () {
    test('accepts a curated event with allowed props', () {
      expect(tax.validate('lesson_complete', {'xp': 10, 'accuracy': 0.9}),
          isEmpty);
    });

    test('rejects an unknown event (closed taxonomy)', () {
      expect(tax.validate('totally_made_up', const {}), isNotEmpty);
    });

    test('rejects an unknown prop key (closed container)', () {
      expect(tax.validate('lesson_complete', {'xp': 10, 'note': 'hi'}),
          isNotEmpty);
    });

    test('rejects a forbidden PII key', () {
      expect(tax.validate('lesson_complete', {'email': 'x'}), isNotEmpty);
      expect(tax.validate('lesson_complete', {'first_name': 'x'}), isNotEmpty);
    });

    test('rejects auth.uid()-style identifier keys', () {
      expect(tax.validate('lesson_complete', {'user_id': 'x'}), isNotEmpty);
      expect(tax.validate('lesson_complete', {'uid': 'x'}), isNotEmpty);
      expect(tax.validate('lesson_complete', {'account_id': 'x'}), isNotEmpty);
    });

    test('rejects a PII-looking VALUE even under an allowed key', () {
      expect(tax.validate('paywall_viewed', {'source': 'me@example.com'}),
          isNotEmpty);
      expect(
          tax.validate('paywall_viewed',
              {'source': '550e8400-e29b-41d4-a716-446655440000'}),
          isNotEmpty,
          reason: 'a smuggled auth.uid() UUID must be caught');
    });

    test('self-consistency: no curated taxonomy key is itself PII-ish', () {
      for (final entry in tax.allowedEvents.entries) {
        for (final key in entry.value) {
          final tokens = key.toLowerCase().split(RegExp(r'[^a-z0-9]+'));
          for (final t in tokens) {
            expect(AnalyticsTaxonomy.forbiddenKeyTokens.contains(t), isFalse,
                reason:
                    'taxonomy event "${entry.key}" has PII-ish key "$key" (token "$t")');
          }
        }
      }
    });
  });

  group('AllowListAnalytics seam enforcement (P0-5 fail-closed)', () {
    test('forwards a clean event to the delegate', () {
      final spy = _SpyAnalytics();
      AllowListAnalytics(spy).logEvent('app_open', props: {'cold_start': true});
      expect(spy.events, ['app_open']);
    });

    test('drops a violating event — never reaches the sink', () {
      final spy = _SpyAnalytics();
      try {
        // debug builds assert (loud); release drops silently. Either way the
        // event must NOT be forwarded.
        AllowListAnalytics(spy)
            .logEvent('lesson_complete', props: {'email': 'a@b.com'});
      } on AssertionError {
        // expected loud failure in debug
      }
      expect(spy.events, isEmpty,
          reason: 'a taxonomy-violating event must never reach the vendor sink');
    });
  });

  // CI GUARD (validation finding P2-4): statically prove no feature code passes
  // `auth.uid()` / an identifier / PII into an analytics event. Mirrors the
  // token-lint source scan. Trivially green today (the seam is unused by
  // features yet); it ARMS the invariant for Stage 3.
  test('CI guard: no lib/ code passes auth.uid()/identifier into logEvent', () {
    final offenders = <String>[];
    final badArg = RegExp(
        r'\bauth\.uid|\.uid\b|identity\.uid|\bemail\b|\buserId\b|\buser_id\b|\bvoiceprint\b');
    final callRe = RegExp(r'logEvent\s*\([^;]*\)');
    for (final e in Directory('lib').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      if (e.path.endsWith('.g.dart') || e.path.endsWith('.freezed.dart')) {
        continue;
      }
      final src = e.readAsStringSync();
      for (final m in callRe.allMatches(src)) {
        final call = m.group(0)!;
        if (badArg.hasMatch(call)) offenders.add('${e.path} :: $call');
      }
    }
    expect(offenders, isEmpty,
        reason:
            'auth.uid()/PII must never enter analytics props (P0-5/P2-4):\n${offenders.join('\n')}');
  });
}
