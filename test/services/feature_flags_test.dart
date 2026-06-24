// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// FLAGS-1 [R-M2] tests — the pure feature-flag & experiment evaluation core:
// flag resolution with kill-switch + safe fallback, the FAIL-OPEN
// minimum-supported-version gate, deterministic stable-hash A/B assignment
// (minors excluded from non-essential experiments), and percentage / wave
// rollout. All pure: no I/O, no clock, no network. Golden buckets were computed
// from the exact stable-hash algorithm and cross-checked in python.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

void main() {
  group('FeatureFlags (resolution · kill-switch · safe fallback)', () {
    const defaults = FlagDefaults(
      flags: {'leagues': true, 'social_feed': false},
      numbers: {'energy_cap': 25, 'ad_frequency': 3},
    );

    test('unreachable service (null config) falls back to safe defaults', () {
      const ff = FeatureFlags(defaults);
      expect(ff.isEnabled('leagues'), isTrue);
      expect(ff.isEnabled('social_feed'), isFalse);
      expect(ff.number('energy_cap'), 25);
    });

    test('remote value overrides the compiled-in default', () {
      const ff = FeatureFlags(
        defaults,
        config: FlagConfig(flags: {'social_feed': true, 'leagues': false}),
      );
      expect(ff.isEnabled('social_feed'), isTrue);
      expect(ff.isEnabled('leagues'), isFalse);
    });

    test('kill-switch ALWAYS wins — over a remote-on and a default-on', () {
      const ff = FeatureFlags(
        defaults,
        config: FlagConfig(flags: {'leagues': true}, killed: {'leagues'}),
      );
      expect(ff.isEnabled('leagues'), isFalse, reason: 'killed overrides on');
    });

    test('unknown key is OFF (conservative)', () {
      const ff = FeatureFlags(defaults);
      expect(ff.isEnabled('does_not_exist'), isFalse);
    });

    test('numbers: remote overrides default; fallback when absent everywhere', () {
      const ff = FeatureFlags(
        defaults,
        config: FlagConfig(numbers: {'energy_cap': 40}),
      );
      expect(ff.number('energy_cap'), 40);
      expect(ff.number('ad_frequency'), 3, reason: 'from compiled-in defaults');
      expect(ff.number('missing', fallback: 7), 7);
    });
  });

  group('MinVersionGate (FAILS OPEN)', () {
    final gate = MinVersionGate(
      floor: AppVersion.tryParse('1.2.0'),
      recommended: AppVersion.tryParse('1.5.0'),
    );

    test('at/above recommended is ok', () {
      expect(gate.evaluateRaw('1.5.0').isOk, isTrue);
      expect(gate.evaluateRaw('2.0.0'), VersionVerdict.ok);
    });

    test('between floor and recommended → soft update available', () {
      expect(gate.evaluateRaw('1.3.9'), VersionVerdict.updateAvailable);
    });

    test('below floor → hard update required', () {
      expect(gate.evaluateRaw('1.1.5'), VersionVerdict.updateRequired);
    });

    test('null / unparseable / empty current FAILS OPEN to ok', () {
      expect(gate.evaluateRaw(null), VersionVerdict.ok);
      expect(gate.evaluateRaw('garbage'), VersionVerdict.ok);
      expect(gate.evaluateRaw(''), VersionVerdict.ok);
    });

    test('absent thresholds never lock anyone out', () {
      const open = MinVersionGate();
      expect(open.evaluateRaw('0.0.1'), VersionVerdict.ok);
    });

    test('AppVersion parses, compares numerically, ignores pre-release/build', () {
      expect(AppVersion.tryParse('1.4'), const AppVersion(1, 4, 0));
      expect(AppVersion.tryParse('1.2.3-beta+9'), const AppVersion(1, 2, 3));
      expect(AppVersion.tryParse('1.2.3.4'), isNull);
      expect(AppVersion.tryParse('x'), isNull);
      expect(
        const AppVersion(1, 2, 0).compareTo(const AppVersion(1, 10, 0)) < 0,
        isTrue,
        reason: 'numeric, not lexicographic (2 < 10)',
      );
    });
  });

  group('Experiments (deterministic A/B · minors excluded · kill-switch)', () {
    const exp = Experiment(
      'paywall_copy',
      [Variant('control', 50), Variant('v2', 50)],
    );

    test('assignment is deterministic and stable for a user', () {
      const ex = Experiments();
      final a = ex.assign(exp, userId: 'user-123', audience: FlagAudience.adult);
      final b = ex.assign(exp, userId: 'user-123', audience: FlagAudience.adult);
      expect(a, b);
      expect(const ['control', 'v2'].contains(a), isTrue);
    });

    test('golden buckets — known users land in known variants', () {
      const ex = Experiments();
      expect(ex.assign(exp, userId: 'alice', audience: FlagAudience.adult),
          'control'); // bucket 39 (< 50)
      expect(ex.assign(exp, userId: 'bob', audience: FlagAudience.adult),
          'control'); // bucket 38 (< 50)
      expect(ex.assign(exp, userId: 'user-123', audience: FlagAudience.adult),
          'v2'); // bucket 74 (>= 50)
    });

    test('a 50/50 split actually splits a population both ways (golden counts)', () {
      const ex = Experiments();
      var control = 0;
      var v2 = 0;
      for (var i = 0; i < 100; i++) {
        final v = ex.assign(exp, userId: 'u$i', audience: FlagAudience.adult);
        if (v == 'control') {
          control++;
        } else {
          v2++;
        }
      }
      expect(control, 39);
      expect(v2, 61);
      expect(control + v2, 100);
    });

    test('minors and unknown are excluded from a NON-essential experiment', () {
      const ex = Experiments();
      // 'u1' lands an ADULT in v2 (bucket 52); exclusion must force control.
      expect(ex.assign(exp, userId: 'u1', audience: FlagAudience.adult), 'v2');
      expect(ex.assign(exp, userId: 'u1', audience: FlagAudience.minor), 'control');
      expect(ex.assign(exp, userId: 'u1', audience: FlagAudience.unknown), 'control');
    });

    test('an ESSENTIAL experiment enrolls minors normally', () {
      const essential = Experiment(
        'core_loop',
        [Variant('control', 50), Variant('v2', 50)],
        essential: true,
      );
      const ex = Experiments();
      final adult = ex.assign(essential, userId: 'kid-1', audience: FlagAudience.adult);
      final minor = ex.assign(essential, userId: 'kid-1', audience: FlagAudience.minor);
      expect(minor, adult, reason: 'essential ⇒ audience does not change the bucket');
    });

    test('kill-switch forces everyone to control', () {
      const ex = Experiments(config: FlagConfig(killed: {'paywall_copy'}));
      for (final id in const ['alice', 'bob', 'user-123', 'u1']) {
        expect(ex.assign(exp, userId: id, audience: FlagAudience.adult), 'control');
      }
    });

    test('weighted variants honor their share (golden cumulative bands)', () {
      const weighted = Experiment('w', [Variant('a', 1), Variant('b', 3)]);
      const ex = Experiments();
      var a = 0;
      var b = 0;
      for (var i = 0; i < 100; i++) {
        final v = ex.assign(weighted, userId: 'w$i', audience: FlagAudience.adult);
        if (v == 'a') {
          a++;
        } else {
          b++;
        }
      }
      expect(a, 26); // ~1/4 share
      expect(b, 74); // ~3/4 share
      expect(a + b, 100);
    });

    test('non-positive total weight degrades to control', () {
      const zero = Experiment('z', [Variant('control', 0), Variant('v2', 0)]);
      const ex = Experiments();
      expect(ex.assign(zero, userId: 'anyone', audience: FlagAudience.adult),
          'control');
    });
  });

  group('RolloutGate (deterministic percentage / wave)', () {
    const gate = RolloutGate();

    test('0% includes nobody, 100% includes everybody', () {
      expect(gate.inRollout('feat', userId: 'u1', percent: 0), isFalse);
      expect(gate.inRollout('feat', userId: 'u1', percent: 100), isTrue);
    });

    test('stable per user across calls', () {
      final a = gate.inRollout('feat', userId: 'u1', percent: 50);
      final b = gate.inRollout('feat', userId: 'u1', percent: 50);
      expect(a, b);
    });

    test('inclusion is monotonic in percent for a given user', () {
      const id = 'rollout-user';
      var firstIn = 101;
      for (var p = 0; p <= 100; p++) {
        if (gate.inRollout('feat', userId: id, percent: p)) {
          firstIn = p;
          break;
        }
      }
      for (var p = firstIn; p <= 100; p++) {
        expect(gate.inRollout('feat', userId: id, percent: p), isTrue);
      }
    });

    test('~percent of a population is included (golden, 50%)', () {
      var inWave = 0;
      for (var i = 0; i < 100; i++) {
        if (gate.inRollout('wave', userId: 'p$i', percent: 50)) {
          inWave++;
        }
      }
      expect(inWave, 55);
    });
  });
}
