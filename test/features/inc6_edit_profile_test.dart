// INC-6 (§4.9 Edit profile · design #60/#61): emoji avatar + short bio, both
// persisted device-locally through the preferences engine (honest — RATEL is
// mascot/emoji-based and has no photo/upload backend nor a server `bio` column).
// The @handle still routes to the server; name/avatar/bio stay local. Covers:
// the AppSettings round-trip, picking an avatar in the editor, entering a bio +
// Save, and the Profile header reflecting the chosen avatar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/profile/edit_profile_screen.dart';
import 'package:ratel/features/profile/profile_screen.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';
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
  group('AppSettings avatar + bio', () {
    test('defaults are empty (back-compat: header falls back to the outfit)', () {
      const AppSettings s = AppSettings();
      expect(s.avatarEmoji, '');
      expect(s.bio, '');
    });

    test('round-trip avatarEmoji + bio through the map', () {
      final AppSettings s =
          const AppSettings().copyWith(avatarEmoji: '🦊', bio: 'Hi there');
      expect(s.avatarEmoji, '🦊');
      expect(s.bio, 'Hi there');
      final AppSettings back = AppSettings.fromMap(s.toMap());
      expect(back.avatarEmoji, '🦊');
      expect(back.bio, 'Hi there');
    });

    test('legacy stored map (no avatar/bio keys) still loads with defaults', () {
      // A settings blob persisted before INC-6 has neither key.
      final Map<String, Object?> legacy = <String, Object?>{
        'displayName': 'Rafa',
        'worldTheme': 'light',
      };
      final AppSettings s = AppSettings.fromMap(legacy);
      expect(s.displayName, 'Rafa');
      expect(s.avatarEmoji, '');
      expect(s.bio, '');
    });

    test('equality distinguishes avatarEmoji + bio', () {
      const AppSettings base = AppSettings();
      expect(base.copyWith(avatarEmoji: '🐼') == base, isFalse);
      expect(base.copyWith(bio: 'x') == base, isFalse);
      expect(base.copyWith() == base, isTrue);
    });
  });

  group('controller setters', () {
    test('setAvatarEmoji persists the chosen emoji', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      await container
          .read(appSettingsControllerProvider.notifier)
          .setAvatarEmoji('🐨');
      expect(container.read(appSettingsControllerProvider).avatarEmoji, '🐨');
    });

    test('setBio trims + persists', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      await container
          .read(appSettingsControllerProvider.notifier)
          .setBio('  Learning German  ');
      expect(container.read(appSettingsControllerProvider).bio,
          'Learning German');
    });
  });

  testWidgets('picking an avatar in the editor persists it on Save',
      (WidgetTester tester) async {
    _tallSurface(tester);
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: EditProfileScreen()),
    ));
    await tester.pumpAndSettle();

    // Open the picker and choose the fox.
    await tester.tap(find.byKey(const ValueKey<String>('edit-change-avatar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('edit-avatar-picker')),
        findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('edit-avatar-🦊')));
    await tester.pumpAndSettle();

    // Save persists it locally.
    await tester.tap(find.byKey(const ValueKey<String>('edit-save')));
    await tester.pumpAndSettle();
    expect(container.read(appSettingsControllerProvider).avatarEmoji, '🦊');
  });

  testWidgets('entering a bio + Save persists it',
      (WidgetTester tester) async {
    _tallSurface(tester);
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: EditProfileScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const ValueKey<String>('edit-bio')), 'Coffee & verbs');
    await tester.tap(find.byKey(const ValueKey<String>('edit-save')));
    await tester.pumpAndSettle();
    expect(container.read(appSettingsControllerProvider).bio, 'Coffee & verbs');
  });

  testWidgets('the editor pre-fills the persisted avatar + bio',
      (WidgetTester tester) async {
    _tallSurface(tester);
    final ProviderContainer container = ProviderContainer(overrides: <Override>[
      settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
        const AppSettings(avatarEmoji: '🐼', bio: 'Panda'),
      )),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: EditProfileScreen()),
    ));
    await tester.pumpAndSettle();
    // The bio text field is seeded from the persisted value.
    expect(find.widgetWithText(TextField, 'Panda'), findsOneWidget);
    // The avatar circle shows the persisted emoji.
    expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('edit-avatar-display')),
          matching: find.text('🐼'),
        ),
        findsOneWidget);
  });

  testWidgets('Profile header reflects the chosen avatar emoji',
      (WidgetTester tester) async {
    _tallSurface(tester);
    final ProviderContainer container = ProviderContainer(overrides: <Override>[
      settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
        const AppSettings(avatarEmoji: '🐼'),
      )),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
    ));
    await tester.pumpAndSettle();
    // The picked emoji appears on the header (falls back to the outfit 🦡 only
    // when unset, so 🐼 here proves the wiring). The default outfit is 🦡, so a
    // stray 🦡 could never masquerade as this assertion.
    expect(find.text('🐼'), findsWidgets);
  });

  testWidgets('claiming an @handle still routes through FriendsService.setHandle',
      (WidgetTester tester) async {
    _tallSurface(tester);
    final _RecordingFriendsService svc = _RecordingFriendsService();
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
        find.byKey(const ValueKey<String>('edit-handle')), '@Mia');
    await tester.tap(find.byKey(const ValueKey<String>('edit-save')));
    await tester.pumpAndSettle();
    expect(svc.handles, <String>['@Mia']);
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
