import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/social/friends.dart';

void main() {
  const FriendsEngine e = FriendsEngine();

  FriendRecord rec(String id, FriendStatus s, {String? name, int xp = 0}) =>
      FriendRecord(
        userId: id,
        handle: id,
        displayName: name ?? id,
        status: s,
        weeklyXp: xp,
      );

  group('handle normalization', () {
    test('strips @, trims, lowercases', () {
      expect(e.normalizeHandle('  @Mia_99 '), 'mia_99');
    });
    test('validates charset + length', () {
      expect(e.isValidHandle('@Mia_99'), isTrue);
      expect(e.isValidHandle('a'), isFalse); // too short
      expect(e.isValidHandle('has space'), isFalse);
      expect(e.isValidHandle('bad!'), isFalse);
    });
  });

  group('partitions', () {
    final List<FriendRecord> recs = <FriendRecord>[
      rec('z', FriendStatus.friends, name: 'Zoe'),
      rec('a', FriendStatus.friends, name: 'Ana'),
      rec('i', FriendStatus.requestIncoming, name: 'Ivan'),
      rec('o', FriendStatus.requestOutgoing, name: 'Omar'),
      rec('b', FriendStatus.blocked, name: 'Bea'),
    ];
    test('friends are accepted-only, alphabetical', () {
      expect(e.friends(recs).map((FriendRecord r) => r.displayName).toList(),
          <String>['Ana', 'Zoe']);
    });
    test('incoming / outgoing isolate their state', () {
      expect(e.incoming(recs).single.userId, 'i');
      expect(e.outgoing(recs).single.userId, 'o');
    });
    test('blocked never appears in friends', () {
      expect(e.friends(recs).any((FriendRecord r) => r.userId == 'b'), isFalse);
    });
  });

  group('feed', () {
    FriendActivity ev(String actor, int hour) => FriendActivity(
          actorId: actor,
          actorHandle: actor,
          actorName: actor,
          type: FriendActivityType.lessonsCompleted,
          summary: 'did a lesson',
          at: DateTime.utc(2026, 6, 30, hour),
        );
    final List<FriendRecord> recs = <FriendRecord>[
      rec('a', FriendStatus.friends),
      rec('o', FriendStatus.requestOutgoing),
    ];
    test('only friends events, newest first', () {
      final List<FriendActivity> feed = e.feed(
        <FriendActivity>[ev('a', 9), ev('o', 10), ev('a', 11)],
        recs,
      );
      expect(feed.length, 2); // 'o' is not a friend → excluded
      expect(feed.first.at.hour, 11); // newest first
    });
    test('respects cap', () {
      final List<FriendActivity> many =
          List<FriendActivity>.generate(60, (int i) => ev('a', i % 24));
      expect(e.feed(many, recs, cap: 10).length, 10);
    });
  });

  test('whoPassedMe: friends ahead on weekly XP, biggest lead first', () {
    final List<FriendRecord> recs = <FriendRecord>[
      rec('a', FriendStatus.friends, xp: 300),
      rec('b', FriendStatus.friends, xp: 120),
      rec('c', FriendStatus.friends, xp: 50),
      rec('o', FriendStatus.requestOutgoing, xp: 999),
    ];
    expect(e.whoPassedMe(100, recs).map((FriendRecord r) => r.userId).toList(),
        <String>['a', 'b']); // c below me; o not a friend
  });

  group('transitions (pure, return new list)', () {
    test('canSendRequest: false for self / existing, true for new', () {
      final List<FriendRecord> recs = <FriendRecord>[
        rec('a', FriendStatus.friends)
      ];
      expect(
          e.canSendRequest(recs, rec('a', FriendStatus.none)), isFalse); // dup
      expect(
          e.canSendRequest(recs, rec('new', FriendStatus.none)), isTrue);
      expect(
          e.canSendRequest(recs, rec('me', FriendStatus.none), myHandle: '@me'),
          isFalse);
    });
    test('send adds outgoing; duplicate is a no-op', () {
      final List<FriendRecord> r0 = <FriendRecord>[];
      final List<FriendRecord> r1 =
          e.applySendRequest(r0, rec('new', FriendStatus.none));
      expect(r1.single.status, FriendStatus.requestOutgoing);
      final List<FriendRecord> r2 =
          e.applySendRequest(r1, rec('new', FriendStatus.none));
      expect(r2.length, 1); // unchanged
    });
    test('accept: incoming → friends only', () {
      final List<FriendRecord> recs = <FriendRecord>[
        rec('i', FriendStatus.requestIncoming),
        rec('o', FriendStatus.requestOutgoing),
      ];
      final List<FriendRecord> after = e.applyAccept(recs, 'i');
      expect(after.firstWhere((FriendRecord r) => r.userId == 'i').status,
          FriendStatus.friends);
      // accepting a non-incoming is a no-op
      expect(e.applyAccept(recs, 'o'), recs);
    });
    test('decline removes the incoming row', () {
      final List<FriendRecord> recs = <FriendRecord>[
        rec('i', FriendStatus.requestIncoming)
      ];
      expect(e.applyDecline(recs, 'i'), isEmpty);
    });
    test('remove drops a friend / outgoing row', () {
      final List<FriendRecord> recs = <FriendRecord>[
        rec('a', FriendStatus.friends)
      ];
      expect(e.applyRemove(recs, 'a'), isEmpty);
    });
    test('block: row becomes blocked, hidden from friends', () {
      final List<FriendRecord> recs = <FriendRecord>[
        rec('a', FriendStatus.friends)
      ];
      final List<FriendRecord> after = e.applyBlock(recs, 'a');
      expect(after.single.status, FriendStatus.blocked);
      expect(e.friends(after), isEmpty);
    });
  });

  group('row round-trips', () {
    test('FriendRecord toRow/fromRow', () {
      final FriendRecord r =
          rec('a', FriendStatus.friends, name: 'Ana', xp: 42);
      expect(FriendRecord.fromRow(r.toRow()), r);
    });
    test('FriendActivity toRow/fromRow', () {
      final FriendActivity a = FriendActivity(
        actorId: 'a',
        actorHandle: 'a',
        actorName: 'Ana',
        type: FriendActivityType.passedYouInLeague,
        summary: 'passed you',
        at: DateTime.utc(2026, 6, 30, 12),
      );
      expect(FriendActivity.fromRow(a.toRow()), a);
    });
  });
}
