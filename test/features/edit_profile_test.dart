// C2 (§4.9 Edit profile): a real in-app display-name editor persisted through
// the preferences engine; surfaces on the Profile header. Honest device-local.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/profile/edit_profile_screen.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/social/friends_service.dart';

/// Test-harness helper (INC-9.2 gate fix): the screen under test uses a
/// lazy [ListView] body, so children below the default 800x600 test
/// viewport are never built and resolve to findsNothing (the taller post-INC-6 edit form pushes Save off-screen).
/// Enlarging the test surface builds the whole list. The screen is
/// UNCHANGED — a viewport-only harness fix; the single-item tests already
/// prove the render path is correct.
void _tallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  test('AppSettings.displayName round-trips through the map', () {
    final AppSettings s = const AppSettings().copyWith(displayName: 'Rafa');
    expect(s.displayName, 'Rafa');
    expect(AppSettings.fromMap(s.toMap()).displayName, 'Rafa');
  });

  test('controller setDisplayName trims + persists', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    await container
        .read(appSettingsControllerProvider.notifier)
        .setDisplayName('  Rafa  ');
    expect(container.read(appSettingsControllerProvider).displayName, 'Rafa');
  });

  testWidgets('Edit profile screen edits + saves the display name',
      (WidgetTester tester) async {
    _tallSurface(tester);
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: EditProfileScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsWidgets);
    await tester.enterText(
        find.byKey(const ValueKey<String>('edit-display-name')), 'Rafa');
    await tester.tap(find.byKey(const ValueKey<String>('edit-save')));
    await tester.pumpAndSettle();
    expect(container.read(appSettingsControllerProvider).displayName, 'Rafa');
  });

  testWidgets('claiming an @handle routes it through FriendsService.setHandle',
      (WidgetTester tester) async {
    _tallSurface(tester);
    final svc = _RecordingFriendsService();
    final ProviderContainer container = ProviderContainer(overrides: <Override>[
      friendsServiceProvider.overrideWithValue(svc),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: EditProfileScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey<String>('edit-display-name')), 'Mia');
    await tester.enterText(
        find.byKey(const ValueKey<String>('edit-handle')), '@Mia');
    await tester.tap(find.byKey(const ValueKey<String>('edit-save')));
    await tester.pumpAndSettle();
    expect(svc.handles, <String>['@Mia']);
    expect(container.read(appSettingsControllerProvider).displayName, 'Mia');
  });
}

class _RecordingFriendsService implements FriendsService {
  final List<String> handles = <String>[];
  @override
  Future<FriendDeliveryResult> sendRequest(String t) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.unavailable);
  @override
  Future<FriendDeliveryResult> respond(String h, {required bool accept}) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.unavailable);
  @override
  Future<FriendDeliveryResult> setHandle(String h) async {
    handles.add(h);
    return const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
  }

  @override
  Future<FriendDeliveryResult> removeFriend(String otherHandle,
          {required bool block}) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.unavailable);

  @override
  Future<FriendDeliveryResult> emitActivity(String activityType,
          {String summary = '', List<String>? targets}) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.unavailable);

  @override
  Future<FriendDeliveryResult> publishWeeklyXp(int weeklyXp) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.unavailable);
}
