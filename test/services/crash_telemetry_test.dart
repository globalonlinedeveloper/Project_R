import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

/// Mocked crash-telemetry sink: records every call so we can prove a known minor
/// forwards NO stable identifier and NO profiling breadcrumb into the crash
/// pipeline (R-M5 known-minors rule), while the adult path forwards normally —
/// and that the error itself is STILL recorded for the crash-free-users signal
/// regardless of audience.
class _SpyCrashSink implements CrashTelemetrySink {
  final List<String> users = <String>[];
  final List<String> breadcrumbs = <String>[];
  int clears = 0;
  int errors = 0;
  @override
  void setUser(String userId) => users.add(userId);
  @override
  void clearUser() => clears++;
  @override
  void recordError(Object error, {StackTrace? stackTrace}) => errors++;
  @override
  void leaveBreadcrumb(String message) => breadcrumbs.add(message);
}

void main() {
  group('MinorSafeCrashTelemetry — adult path MAY carry an identifier', () {
    test('forwards setUser to the sink', () {
      final spy = _SpyCrashSink();
      MinorSafeCrashTelemetry(spy, TelemetryAudience.adult).setUser('user-123');
      expect(spy.users, ['user-123']);
      expect(spy.clears, 0);
    });

    test('forwards profiling breadcrumbs to the sink', () {
      final spy = _SpyCrashSink();
      MinorSafeCrashTelemetry(spy, TelemetryAudience.adult)
          .leaveBreadcrumb('opened lesson');
      expect(spy.breadcrumbs, ['opened lesson']);
    });
  });

  group('MinorSafeCrashTelemetry — minor path emits NO stable identifier', () {
    test('setUser never reaches the sink (fail closed → cleared)', () {
      final spy = _SpyCrashSink();
      MinorSafeCrashTelemetry(spy, TelemetryAudience.minor).setUser('user-123');
      expect(spy.users, isEmpty,
          reason: 'a minor must carry no persistent crash identifier');
      expect(spy.clears, 1, reason: 'suppression is active, not passive');
    });

    test('profiling breadcrumbs are dropped for a minor', () {
      final spy = _SpyCrashSink();
      MinorSafeCrashTelemetry(spy, TelemetryAudience.minor)
          .leaveBreadcrumb('opened lesson');
      expect(spy.breadcrumbs, isEmpty,
          reason: 'no profiling breadcrumbs for a known minor');
    });

    test('the error is STILL recorded (a minor counts toward crash-free)', () {
      final spy = _SpyCrashSink();
      MinorSafeCrashTelemetry(spy, TelemetryAudience.minor)
          .recordError(StateError('boom'));
      expect(spy.errors, 1,
          reason: 'a minor is still counted — just without an identifier');
      expect(spy.users, isEmpty, reason: 'no id attached to the report');
    });
  });

  group('MinorSafeCrashTelemetry — unknown audience FAILS CLOSED', () {
    test('unknown suppresses exactly like a minor', () {
      final spy = _SpyCrashSink();
      final t = MinorSafeCrashTelemetry(spy, TelemetryAudience.unknown);
      t.setUser('user-123');
      t.leaveBreadcrumb('opened lesson');
      expect(spy.users, isEmpty);
      expect(spy.breadcrumbs, isEmpty);
      expect(spy.clears, 1, reason: 'the suppressed setUser clears the delegate');
    });
  });

  group('suppression is INJECTED, not hard-coded', () {
    test('same id + same sink type: adult attaches, minor drops', () {
      final adultSink = _SpyCrashSink();
      final minorSink = _SpyCrashSink();
      const id = 'same-stable-id';
      MinorSafeCrashTelemetry(adultSink, TelemetryAudience.adult).setUser(id);
      MinorSafeCrashTelemetry(minorSink, TelemetryAudience.minor).setUser(id);
      expect(adultSink.users, [id], reason: 'adult path attaches the id');
      expect(minorSink.users, isEmpty, reason: 'minor path drops the id');
    });

    test('recordError forwards for BOTH audiences (crash-free counts all)', () {
      final adultSink = _SpyCrashSink();
      final minorSink = _SpyCrashSink();
      MinorSafeCrashTelemetry(adultSink, TelemetryAudience.adult)
          .recordError(StateError('a'));
      MinorSafeCrashTelemetry(minorSink, TelemetryAudience.minor)
          .recordError(StateError('b'));
      expect(adultSink.errors, 1);
      expect(minorSink.errors, 1);
    });

    test('clearUser always forwards (both audiences)', () {
      final adultSink = _SpyCrashSink();
      final minorSink = _SpyCrashSink();
      MinorSafeCrashTelemetry(adultSink, TelemetryAudience.adult).clearUser();
      MinorSafeCrashTelemetry(minorSink, TelemetryAudience.minor).clearUser();
      expect(adultSink.clears, 1);
      expect(minorSink.clears, 1);
    });
  });

  group('crashTelemetryProvider ships fail-closed from day one', () {
    test('default wrapper suppresses any stable id (unknown audience)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final t = container.read(crashTelemetryProvider);
      expect(t, isA<MinorSafeCrashTelemetry>(),
          reason: 'the provider returns a SUPPRESSING wrapper, not a raw sink');
      // The default delegate is a no-op, so these are safe and leak nothing.
      expect(() => t.setUser('x'), returnsNormally);
      expect(() => t.leaveBreadcrumb('y'), returnsNormally);
      expect(() => t.recordError(StateError('z')), returnsNormally);
    });
  });
}
