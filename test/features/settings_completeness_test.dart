// C1 (§4.9 Settings completeness): reduce-motion toggle + per-category
// notification prefs (persisted now; delivery is Build-ahead) + honest external
// links. Covers AppSettings, the controller persistence, and the rendered rows.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/services/preferences/app_settings.dart';

void main() {
  group('AppSettings — reduce-motion + notification prefs', () {
    test('defaults: reduce-motion off, all categories enabled', () {
      const AppSettings s = AppSettings();
      expect(s.reduceMotion, isFalse);
      expect(s.mutedNotifications, isEmpty);
      expect(s.notifyEnabled('push'), isTrue);
      expect(s.notifyEnabled('friend'), isTrue);
    });

    test('copyWith + map round-trip preserve the new fields', () {
      final AppSettings s = const AppSettings().copyWith(
          reduceMotion: true, mutedNotifications: <String>{'push', 'league'});
      expect(s.reduceMotion, isTrue);
      expect(s.notifyEnabled('push'), isFalse);
      expect(s.notifyEnabled('streak'), isTrue);
      final AppSettings round = AppSettings.fromMap(s.toMap());
      expect(round, s);
      expect(round.reduceMotion, isTrue);
      expect(round.mutedNotifications, <String>{'league', 'push'});
    });
  });

  test('controller persists reduce-motion + per-category mutes', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final AppSettingsController c =
        container.read(appSettingsControllerProvider.notifier);
    await c.setReduceMotion(true);
    expect(container.read(appSettingsControllerProvider).reduceMotion, isTrue);
    await c.setNotification('streak', false);
    expect(container.read(appSettingsControllerProvider).notifyEnabled('streak'),
        isFalse);
    await c.setNotification('streak', true);
    expect(container.read(appSettingsControllerProvider).notifyEnabled('streak'),
        isTrue);
  });

  testWidgets('Settings renders the §4.9 rows (reduce motion, 4 notif toggles, privacy & help)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(450, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.text('Push notifications'), findsOneWidget);
    expect(find.text('Streak reminders'), findsOneWidget);
    expect(find.text('League updates'), findsOneWidget);
    expect(find.text('Friend activity'), findsOneWidget);
    expect(find.text('Privacy & data'), findsOneWidget);
    expect(find.text('Help & support'), findsOneWidget);
  });
}
