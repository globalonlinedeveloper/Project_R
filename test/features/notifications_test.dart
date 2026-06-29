import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';
import 'package:ratel/features/notifications/notifications_screen.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/notifications/notifications.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// Tests for the in-app notifications inbox (R-L11): the pure
/// [NotificationsEngine] projection, the provider bridge + device-local
/// read-state persistence, and the [NotificationsScreen] empty-state +
/// mark-all-read flow. The feed is a HONEST projection of real milestones, so a
/// fresh account is an empty inbox — never fabricated alerts.

ProviderContainer _container({
  int goal = 20,
  Set<String> read = const <String>{},
}) =>
    ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(() => DateTime(2026, 6, 1)),
      settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
          AppSettings(dailyGoal: goal, readNotifications: read))),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  group('NotificationsEngine (pure)', () {
    const NotificationsEngine e = NotificationsEngine();

    test('a fresh account has an empty inbox', () {
      expect(e.project(NotificationStats.zero, const <String>{}), isEmpty);
      expect(e.unreadCount(NotificationStats.zero, const <String>{}), 0);
      expect(e.earnedIds(NotificationStats.zero), isEmpty);
    });

    test('one lesson earns exactly the first-lesson milestone, unread', () {
      const NotificationStats s = NotificationStats(
          lessonsCompleted: 1, xpTotal: 20, streakDays: 1, cefrOrdinal: 0);
      final List<AppNotification> items = e.project(s, const <String>{});
      expect(items.map((AppNotification n) => n.id), contains('lessons:1'));
      expect(items.length, 1);
      expect(items.every((AppNotification n) => !n.read), isTrue);
    });

    test('milestones are ordered biggest-first by rank', () {
      const NotificationStats s = NotificationStats(
          lessonsCompleted: 50, xpTotal: 2500, streakDays: 0, cefrOrdinal: 0);
      final List<AppNotification> items = e.project(s, const <String>{});
      expect(items.first.id, 'lessons:50'); // the top-ranked earned milestone
      final Map<String, int> rankById = <String, int>{
        for (final NotificationDef d in NotificationsEngine.catalogue)
          d.id: d.rank,
      };
      final List<int> ranks =
          items.map((AppNotification n) => rankById[n.id]!).toList();
      for (int i = 1; i < ranks.length; i++) {
        expect(ranks[i] <= ranks[i - 1], isTrue);
      }
    });

    test('read ids are reflected and reduce the unread count', () {
      const NotificationStats s = NotificationStats(
          lessonsCompleted: 1, xpTotal: 0, streakDays: 0, cefrOrdinal: 0);
      expect(e.unreadCount(s, const <String>{}), 1);
      expect(e.unreadCount(s, const <String>{'lessons:1'}), 0);
      expect(e.project(s, const <String>{'lessons:1'}).single.read, isTrue);
    });

    test('level / streak / xp thresholds each fire honestly', () {
      expect(
          e.earnedIds(const NotificationStats(
              lessonsCompleted: 0, xpTotal: 0, streakDays: 0, cefrOrdinal: 1)),
          contains('level:1'));
      expect(
          e.earnedIds(const NotificationStats(
              lessonsCompleted: 0, xpTotal: 0, streakDays: 7, cefrOrdinal: 0)),
          containsAll(<String>['streak:3', 'streak:7']));
      expect(
          e.earnedIds(const NotificationStats(
              lessonsCompleted: 0, xpTotal: 500, streakDays: 0, cefrOrdinal: 0)),
          containsAll(<String>['xp:100', 'xp:500']));
    });
  });

  group('notifications providers + device-local read-state', () {
    test('fresh container → empty inbox, zero unread', () {
      final ProviderContainer c = _container();
      addTearDown(c.dispose);
      expect(c.read(notificationsProvider), isEmpty);
      expect(c.read(unreadNotificationsCountProvider), 0);
    });

    test('completing a lesson surfaces a real notification', () async {
      final ProviderContainer c = _container();
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      expect(c.read(unreadNotificationsCountProvider), greaterThan(0));
      expect(c.read(notificationsProvider).map((AppNotification n) => n.id),
          contains('lessons:1'));
    });

    test('marking read persists and clears the unread badge', () async {
      final ProviderContainer c = _container();
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      final Set<String> earned = c.read(earnedNotificationIdsProvider);
      await c
          .read(appSettingsControllerProvider.notifier)
          .addReadNotifications(earned);
      expect(c.read(unreadNotificationsCountProvider), 0);
      expect(c.read(notificationsProvider).every((AppNotification n) => n.read),
          isTrue);
    });

    test('read-state rehydrates from the store', () async {
      final ProviderContainer c = _container(read: const <String>{'lessons:1'});
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      // lessons:1 is the only earned milestone and it is already read.
      expect(c.read(unreadNotificationsCountProvider), 0);
    });
  });

  group('NotificationsScreen', () {
    testWidgets('empty for a fresh account, then a real milestone + mark-read',
        (WidgetTester tester) async {
      final ProviderContainer c = _container();
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: NotificationsScreen()),
      ));
      await tester.pump();
      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.text('Mark all read'), findsNothing);

      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('No notifications yet'), findsNothing);
      expect(find.text('First lesson complete'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);

      await tester.tap(find.text('Mark all read'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Mark all read'), findsNothing); // unread == 0
    });
  });
}
