import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/quests/coop_quest_section.dart';
import 'package:ratel/features/quests/quests_controller.dart';
import 'package:ratel/services/social/friend_quest.dart';
import 'package:ratel/services/social/friend_quest_service.dart';

FriendQuest _q({
  String id = 'q1',
  String creatorId = 'me',
  String partnerId = 'bob',
  String creatorHandle = 'me',
  String partnerHandle = 'bob',
  String status = 'active',
  int goal = 12,
  int creator = 4,
  int partner = 3,
  int combined = 7,
  bool done = false,
}) =>
    FriendQuest(
      id: id,
      creatorId: creatorId,
      partnerId: partnerId,
      creatorHandle: creatorHandle,
      partnerHandle: partnerHandle,
      goalLessons: goal,
      status: status,
      creatorProgress: creator,
      partnerProgress: partner,
      combinedProgress: combined,
      done: done,
    );

/// Controllable fake seam so a widget test can assert the exact RPC calls.
class _FakeCoop implements FriendQuestService {
  _FakeCoop(this._list, {this.available = true});
  final List<FriendQuest> _list;
  final bool available;
  final List<(String, bool)> responded = <(String, bool)>[];
  String? created;

  @override
  bool get isAvailable => available;
  @override
  Future<List<FriendQuest>> list() async => _list;
  @override
  Future<FriendQuest?> create(String h, {int goal = 12}) async {
    created = h;
    return null;
  }

  @override
  Future<FriendQuest?> respond(String id, {required bool accept}) async {
    responded.add((id, accept));
    return null;
  }

  @override
  Future<FriendQuest?> refresh(String id) async => null;
}

Future<_FakeCoop> _pump(
  WidgetTester tester,
  List<FriendQuest> list, {
  String? uid = 'me',
  bool available = true,
}) async {
  tester.view.physicalSize = const Size(440, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final _FakeCoop fake = _FakeCoop(list, available: available);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      friendQuestServiceProvider.overrideWithValue(fake),
      currentUidProvider.overrideWithValue(uid),
    ],
    child: MaterialApp(
      theme: RatelTheme.light(),
      home: const Scaffold(body: CoopQuestSection()),
    ),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  group('pickCoopQuest (pure priority: active > incoming > outgoing)', () {
    test('active wins over any pending', () {
      final FriendQuest? r = pickCoopQuest(<FriendQuest>[
        _q(id: 'p', status: 'pending', creatorId: 'bob', partnerId: 'me'),
        _q(id: 'a', status: 'active'),
      ], 'me');
      expect(r!.id, 'a');
    });
    test('incoming (I am partner) beats outgoing (I created)', () {
      final FriendQuest? r = pickCoopQuest(<FriendQuest>[
        _q(id: 'out', status: 'pending', creatorId: 'me', partnerId: 'x'),
        _q(id: 'in', status: 'pending', creatorId: 'y', partnerId: 'me'),
      ], 'me');
      expect(r!.id, 'in');
    });
    test('completed / empty -> null (no live quest surfaced)', () {
      expect(
          pickCoopQuest(
              <FriendQuest>[_q(status: 'completed', done: true)], 'me'),
          isNull);
      expect(pickCoopQuest(const <FriendQuest>[], 'me'), isNull);
    });
  });

  testWidgets('unavailable backend renders NOTHING (honest, no fabrication)',
      (WidgetTester tester) async {
    await _pump(tester, <FriendQuest>[], available: false);
    expect(find.byKey(const ValueKey('coop-start-row')), findsNothing);
    expect(find.byKey(const ValueKey('coop-quest-tile')), findsNothing);
  });

  testWidgets('no live quest -> the start-a-co-op-quest row',
      (WidgetTester tester) async {
    await _pump(tester, <FriendQuest>[]);
    expect(find.byKey(const ValueKey('coop-start-row')), findsOneWidget);
    expect(find.text('Start a co-op quest'), findsOneWidget);
  });

  testWidgets('active quest -> progress tile names the real partner + N/goal',
      (WidgetTester tester) async {
    await _pump(tester, <FriendQuest>[
      _q(
          status: 'active',
          creatorId: 'me',
          partnerId: 'bob',
          partnerHandle: 'bob',
          combined: 7,
          goal: 12),
    ]);
    expect(find.byKey(const ValueKey('coop-quest-tile')), findsOneWidget);
    expect(find.textContaining('Co-op with @bob'), findsOneWidget);
    expect(find.textContaining('7 of 12'), findsOneWidget);
  });

  testWidgets('incoming invite -> accept/decline; accept calls respond(true)',
      (WidgetTester tester) async {
    final _FakeCoop fake = await _pump(tester, <FriendQuest>[
      _q(
          id: 'inv',
          status: 'pending',
          creatorId: 'mia',
          creatorHandle: 'mia',
          partnerId: 'me'),
    ]);
    expect(find.byKey(const ValueKey('coop-invite-tile')), findsOneWidget);
    expect(find.textContaining('@mia invited you'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('coop-accept')));
    await tester.pump();
    expect(fake.responded, <(String, bool)>[('inv', true)]);
  });

  testWidgets('outgoing invite -> muted waiting tile',
      (WidgetTester tester) async {
    await _pump(tester, <FriendQuest>[
      _q(
          id: 'o',
          status: 'pending',
          creatorId: 'me',
          partnerId: 'bob',
          partnerHandle: 'bob'),
    ]);
    expect(find.byKey(const ValueKey('coop-waiting-tile')), findsOneWidget);
    expect(find.textContaining('Waiting for @bob'), findsOneWidget);
  });

  testWidgets('start row -> invite sheet -> send calls create(handle)',
      (WidgetTester tester) async {
    final _FakeCoop fake = await _pump(tester, <FriendQuest>[]);
    await tester.tap(find.byKey(const ValueKey('coop-start-row')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('coop-invite-field')), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('coop-invite-field')), 'carol');
    await tester.tap(find.byKey(const ValueKey('coop-invite-send')));
    await tester.pumpAndSettle();
    expect(fake.created, 'carol');
  });
}
