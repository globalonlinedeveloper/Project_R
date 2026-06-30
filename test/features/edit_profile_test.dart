// C2 (§4.9 Edit profile): a real in-app display-name editor persisted through
// the preferences engine; surfaces on the Profile header. Honest device-local.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/profile/edit_profile_screen.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/social/friends_service.dart';

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
    await tester.tap(find.byType(RatelButton));
    await tester.pumpAndSettle();
    expect(container.read(appSettingsControllerProvider).displayName, 'Rafa');
  });

  testWidgets('claiming an @handle routes it through FriendsService.setHandle',
      (WidgetTester tester) async {
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
    await tester.tap(find.byType(RatelButton));
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
}
