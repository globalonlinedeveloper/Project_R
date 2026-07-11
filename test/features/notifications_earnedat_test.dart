import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/notifications/earned_stamps_controller.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';
import 'package:ratel/features/notifications/notifications_screen.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/notifications/notifications.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

import 'auth/fake_identity.dart';

/// D-13 (UX-conformance register · design §4.14): every inbox row carries a
/// REAL relative-time label (`2h/5h/1d`) derived from an `earnedAt` stamp
/// recorded the moment the milestone's threshold was genuinely crossed —
/// device-locally, against the injected clock. Milestones with no recorded
/// stamp (earned pre-feature or hydrated from another device) honestly show
/// NO label; nothing is ever backfilled or fabricated.

/// Seeded read-only [LearnerStateStore] (mirrors the diamonds-test fake): lets
/// a test hydrate a signed-in learner's counters WITHOUT any in-session earn.
class _SeedStore implements LearnerStateStore {
  _SeedStore([this.seed = const <String, Object?>{}]);
  final Map<String, Object?> seed;
  @override
  Future<Map<String, Object?>> load(String userId) async => seed;
  @override
  Future<void> save(String userId, Map<String, Object?> state) async {}
}

ProviderContainer _container(
  DateTime Function() clock, {
  InMemoryEarnedStampsStore? stamps,
  Identity? identity,
  LearnerStateStore? store,
}) =>
    ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(clock),
      settingsStoreProvider
          .overrideWithValue(InMemorySettingsStore(const AppSettings())),
      if (stamps != null) earnedStampsStoreProvider.overrideWithValue(stamps),
      if (identity != null) identityProvider.overrideWithValue(identity),
      if (store != null) learnerStateStoreProvider.overrideWithValue(store),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

const NotificationStats _zero = NotificationStats.zero;

NotificationStats _stats({
  int lessons = 0,
  int xp = 0,
  int streak = 0,
  int level = 0,
}) =>
    NotificationStats(
      lessonsCompleted: lessons,
      xpTotal: xp,
      streakDays: streak,
      cefrOrdinal: level,
    );

/// Finder for ANY rendered relative-time label (`now` / `37m` / `2h` / `1d`).
final Finder _anyTimeLabel = find.byWidgetPredicate((Widget w) =>
    w is Text &&
    w.data != null &&
    RegExp(r'^(now|\d+[mhd])$').hasMatch(w.data!));

void main() {
  group('NotificationsEngine.newlyEarned (pure crossing diff)', () {
    const NotificationsEngine e = NotificationsEngine();

    test('a single genuine crossing yields exactly that id', () {
      expect(e.newlyEarned(_zero, _stats(lessons: 1)),
          <String>{'lessons:1'});
    });

    test('no change yields nothing', () {
      expect(e.newlyEarned(_stats(lessons: 3), _stats(lessons: 3)), isEmpty);
    });

    test('several thresholds crossed at once all report', () {
      expect(e.newlyEarned(_zero, _stats(lessons: 1, xp: 500)),
          <String>{'lessons:1', 'xp:100', 'xp:500'});
    });

    test('a lapse (drop below threshold) is never an earn', () {
      expect(e.newlyEarned(_stats(streak: 7), _stats(streak: 0)), isEmpty);
    });

    test('already-earned ids never re-report while still held', () {
      expect(e.newlyEarned(_stats(lessons: 1), _stats(lessons: 2)), isEmpty);
    });
  });

  group('relativeEarnedLabel (design §4.14 labels)', () {
    final DateTime now = DateTime.utc(2026, 6, 1, 12);

    test('under a minute → now', () {
      expect(relativeEarnedLabel(now, now), 'now');
      expect(
          relativeEarnedLabel(now.subtract(const Duration(seconds: 59)), now),
          'now');
    });

    test('minutes bucket', () {
      expect(
          relativeEarnedLabel(now.subtract(const Duration(minutes: 1)), now),
          '1m');
      expect(
          relativeEarnedLabel(
              now.subtract(const Duration(minutes: 59, seconds: 59)), now),
          '59m');
    });

    test('hours bucket (the mock rows: 2h / 5h)', () {
      expect(relativeEarnedLabel(now.subtract(const Duration(hours: 1)), now),
          '1h');
      expect(
          relativeEarnedLabel(
              now.subtract(const Duration(hours: 2, minutes: 5)), now),
          '2h');
      expect(
          relativeEarnedLabel(
              now.subtract(const Duration(hours: 23, minutes: 59)), now),
          '23h');
    });

    test('days bucket (the mock rows: 1d / 2d)', () {
      expect(relativeEarnedLabel(now.subtract(const Duration(hours: 24)), now),
          '1d');
      expect(relativeEarnedLabel(now.subtract(const Duration(hours: 49)), now),
          '2d');
    });

    test('a future stamp (clock skew) clamps to now', () {
      expect(relativeEarnedLabel(now.add(const Duration(hours: 3)), now),
          'now');
    });
  });

  group('project() attaches stamps honestly', () {
    const NotificationsEngine e = NotificationsEngine();
    final DateTime t0 = DateTime.utc(2026, 6, 1, 10);

    test('a stamped id carries its earnedAt; an unstamped id stays null', () {
      final List<AppNotification> items = e.project(
        _stats(lessons: 5),
        const <String>{},
        earnedAt: <String, DateTime>{'lessons:5': t0},
      );
      expect(
          items
              .firstWhere((AppNotification n) => n.id == 'lessons:5')
              .earnedAt,
          t0);
      expect(
          items
              .firstWhere((AppNotification n) => n.id == 'lessons:1')
              .earnedAt,
          isNull);
    });

    test('omitting the map keeps every row label-free (back-compat)', () {
      final List<AppNotification> items =
          e.project(_stats(lessons: 1), const <String>{});
      expect(items.single.earnedAt, isNull);
    });
  });

  group('earn stamps: recorded at the REAL crossing, written through', () {
    test('a first lesson stamps lessons:1 at the injected clock', () async {
      final InMemoryEarnedStampsStore store = InMemoryEarnedStampsStore();
      final DateTime t0 = DateTime.utc(2026, 6, 1, 10);
      final ProviderContainer c = _container(() => t0, stamps: store);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      expect(c.read(earnedStampsControllerProvider)['lessons:1'], t0);
      // write-through to the device-local store
      expect(store.current['lessons:1'], t0);
      // and the projection surfaces it
      expect(
          c
              .read(notificationsProvider)
              .firstWhere((AppNotification n) => n.id == 'lessons:1')
              .earnedAt,
          t0);
    });

    test('every threshold crossed by one mutation stamps at that moment',
        () async {
      final DateTime t0 = DateTime.utc(2026, 6, 1, 10);
      final ProviderContainer c = _container(() => t0);
      addTearDown(c.dispose);
      c
          .read(learnerControllerProvider.notifier)
          .recordLessonComplete(xp: 2500);
      await _settle();
      final Map<String, DateTime> stamps =
          c.read(earnedStampsControllerProvider);
      expect(
          stamps.keys.toSet(),
          <String>{'lessons:1', 'xp:100', 'xp:500', 'xp:1000', 'xp:2500'});
      expect(stamps.values.every((DateTime t) => t == t0), isTrue);
    });

    test('a later mutation never re-stamps a milestone still held', () async {
      DateTime now = DateTime.utc(2026, 6, 1, 10);
      final ProviderContainer c = _container(() => now);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      now = now.add(const Duration(hours: 2));
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      expect(c.read(earnedStampsControllerProvider)['lessons:1'],
          DateTime.utc(2026, 6, 1, 10));
    });

    test('a genuine RE-crossing after a lapse re-stamps at the new moment',
        () {
      DateTime now = DateTime.utc(2026, 6, 1, 10);
      final ProviderContainer c = _container(() => now);
      addTearDown(c.dispose);
      final EarnedStampsController n =
          c.read(earnedStampsControllerProvider.notifier);
      n.stampCrossings(before: _zero, after: _stats(streak: 3));
      expect(c.read(earnedStampsControllerProvider)['streak:3'],
          DateTime.utc(2026, 6, 1, 10));
      // the streak lapses (item vanishes), then is genuinely re-earned later
      now = now.add(const Duration(days: 2));
      n.stampCrossings(before: _zero, after: _stats(streak: 3));
      expect(c.read(earnedStampsControllerProvider)['streak:3'],
          DateTime.utc(2026, 6, 3, 10));
    });

    test(
        'HYDRATION HONESTY: restored milestones surface WITHOUT stamps '
        '(no fabricated times)', () async {
      final ProviderContainer c = _container(
        () => DateTime.utc(2026, 6, 1, 10),
        identity: FakeIdentity(),
        store: _SeedStore(<String, Object?>{
          'courses': <Object?>[
            <String, Object?>{
              'target_locale': 'es',
              'xp_total': 500,
              'lessons_completed': 10,
            },
          ],
        }),
      );
      addTearDown(c.dispose);
      c.read(learnerControllerProvider); // trigger build + fire hydration
      await _settle();
      expect(c.read(learnerControllerProvider).lessonsCompleted, 10);
      final List<AppNotification> items = c.read(notificationsProvider);
      expect(items, isNotEmpty); // the milestones themselves DO surface
      expect(c.read(earnedStampsControllerProvider), isEmpty); // no stamps
      expect(items.every((AppNotification n) => n.earnedAt == null), isTrue);
    });
  });

  group('NotificationsScreen per-row time labels (D-13)', () {
    testWidgets('a stamped row shows the design label and keeps it once read',
        (WidgetTester tester) async {
      DateTime now = DateTime.utc(2026, 6, 1, 10);
      final ProviderContainer c = _container(() => now);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      now = now.add(const Duration(hours: 2, minutes: 5));
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: NotificationsScreen()),
      ));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('First lesson complete'), findsOneWidget);
      expect(find.text('2h'), findsOneWidget);

      await tester.tap(find.text('Mark all read'));
      await tester.pump(const Duration(milliseconds: 50));
      // the honest earn time is not read-state — the label stays
      expect(find.text('2h'), findsOneWidget);
    });

    testWidgets('earned-but-unstamped rows honestly show NO time label',
        (WidgetTester tester) async {
      final ProviderContainer c = _container(
        () => DateTime.utc(2026, 6, 1, 10),
        identity: FakeIdentity(),
        store: _SeedStore(<String, Object?>{
          'courses': <Object?>[
            <String, Object?>{
              'target_locale': 'es',
              'xp_total': 500,
              'lessons_completed': 10,
            },
          ],
        }),
      );
      addTearDown(c.dispose);
      // NB: real Future.delayed never fires inside testWidgets' FakeAsync —
      // settle the microtask-only hydration with pumps instead (§11).
      c.read(learnerControllerProvider);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: NotificationsScreen()),
      ));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      expect(c.read(learnerControllerProvider).lessonsCompleted, 10);
      expect(find.text('No notifications yet'), findsNothing);
      expect(_anyTimeLabel, findsNothing);
    });

    testWidgets('gauntlet: labelled rows stay clean at 360 / 430 / 800',
        (WidgetTester tester) async {
      for (final double w in <double>[360, 430, 800]) {
        tester.view.physicalSize = Size(w, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        DateTime now = DateTime.utc(2026, 6, 1, 10);
        final ProviderContainer c = _container(() => now);
        c.read(learnerControllerProvider.notifier)
            .recordLessonComplete(xp: 2500);
        now = now.add(const Duration(hours: 5));
        await tester.pumpWidget(UncontrolledProviderScope(
          container: c,
          key: ValueKey<double>(w),
          child: const MaterialApp(home: NotificationsScreen()),
        ));
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('5h'), findsNWidgets(5),
            reason: 'all five stamped rows label at width $w');
        c.dispose();
      }
    });
  });
}
