import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

/// Mocked analytics-identity sink: records every call so we can prove the minor
/// path forwards NO stable identifier to the SDK (R-M1 / R-K1 — no analytics /
/// tracking / ad id for minors) while the adult path forwards normally.
class _SpyIdentitySink implements AnalyticsIdentitySink {
  final List<String> userIds = <String>[];
  final List<String> deviceIds = <String>[];
  int clears = 0;
  @override
  void setUserId(String userId) => userIds.add(userId);
  @override
  void setDeviceId(String deviceId) => deviceIds.add(deviceId);
  @override
  void clearIdentity() => clears++;
}

void main() {
  group('MinorSafeAnalyticsIdentity — adult path MAY carry an identifier', () {
    test('forwards setUserId to the sink', () {
      final spy = _SpyIdentitySink();
      MinorSafeAnalyticsIdentity(spy, AnalyticsAudience.adult)
          .setUserId('analytics-123');
      expect(spy.userIds, ['analytics-123']);
      expect(spy.deviceIds, isEmpty);
      expect(spy.clears, 0);
    });

    test('forwards setDeviceId to the sink', () {
      final spy = _SpyIdentitySink();
      MinorSafeAnalyticsIdentity(spy, AnalyticsAudience.adult)
          .setDeviceId('device-abc');
      expect(spy.deviceIds, ['device-abc']);
      expect(spy.userIds, isEmpty);
    });
  });

  group('MinorSafeAnalyticsIdentity — minor path emits NO stable identifier', () {
    test('setUserId never reaches the sink (fail closed → cleared)', () {
      final spy = _SpyIdentitySink();
      MinorSafeAnalyticsIdentity(spy, AnalyticsAudience.minor)
          .setUserId('analytics-123');
      expect(spy.userIds, isEmpty,
          reason: 'a minor must carry no analytics / tracking user id');
      expect(spy.clears, 1, reason: 'suppression is active, not passive');
    });

    test('setDeviceId never reaches the sink (fail closed → cleared)', () {
      final spy = _SpyIdentitySink();
      MinorSafeAnalyticsIdentity(spy, AnalyticsAudience.minor)
          .setDeviceId('device-abc');
      expect(spy.deviceIds, isEmpty,
          reason: 'a minor must carry no device / ad id linkage');
      expect(spy.clears, 1);
    });
  });

  group('MinorSafeAnalyticsIdentity — unknown audience FAILS CLOSED', () {
    test('unknown suppresses exactly like a minor', () {
      final spy = _SpyIdentitySink();
      final id = MinorSafeAnalyticsIdentity(spy, AnalyticsAudience.unknown);
      id.setUserId('analytics-123');
      id.setDeviceId('device-abc');
      expect(spy.userIds, isEmpty);
      expect(spy.deviceIds, isEmpty);
      expect(spy.clears, 2, reason: 'each suppressed assignment clears');
    });
  });

  group('suppression is INJECTED, not hard-coded', () {
    test('same id + same sink type: adult links, minor drops', () {
      final adultSink = _SpyIdentitySink();
      final minorSink = _SpyIdentitySink();
      const id = 'same-stable-id';
      MinorSafeAnalyticsIdentity(adultSink, AnalyticsAudience.adult)
          .setUserId(id);
      MinorSafeAnalyticsIdentity(minorSink, AnalyticsAudience.minor)
          .setUserId(id);
      expect(adultSink.userIds, [id], reason: 'adult path links the id');
      expect(minorSink.userIds, isEmpty, reason: 'minor path drops the id');
    });

    test('clearIdentity always forwards (both audiences)', () {
      final adultSink = _SpyIdentitySink();
      final minorSink = _SpyIdentitySink();
      MinorSafeAnalyticsIdentity(adultSink, AnalyticsAudience.adult)
          .clearIdentity();
      MinorSafeAnalyticsIdentity(minorSink, AnalyticsAudience.minor)
          .clearIdentity();
      expect(adultSink.clears, 1);
      expect(minorSink.clears, 1);
    });
  });

  group('analyticsIdentityProvider ships fail-closed from day one', () {
    test('default wrapper suppresses any stable id (unknown audience)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final id = container.read(analyticsIdentityProvider);
      expect(id, isA<MinorSafeAnalyticsIdentity>(),
          reason: 'the provider returns a SUPPRESSING wrapper, not a raw sink');
      // The default delegate is a no-op, so these are safe and leak nothing.
      expect(() => id.setUserId('x'), returnsNormally);
      expect(() => id.setDeviceId('y'), returnsNormally);
    });
  });
}
