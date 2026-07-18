import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/social/friend_quest.dart';
import 'package:ratel/services/social/friend_quest_service.dart';
import 'package:ratel/services/data_access/supabase_friend_quest_service.dart';

void main() {
  group('FriendQuest.fromJson', () {
    Map<String, dynamic> row({String status = 'active', int combined = 7}) =>
        <String, dynamic>{
          'friend_quest_id': 'q1',
          'creator_id': 'uA',
          'partner_id': 'uB',
          'goal_lessons': 12,
          'status': status,
          'creator_progress': 3,
          'partner_progress': 4,
          'combined_progress': combined,
          'done': combined >= 12,
          'completed_at': null,
        };

    test('parses every field + derived getters', () {
      final FriendQuest q = FriendQuest.fromJson(row());
      expect(q.id, 'q1');
      expect(q.creatorId, 'uA');
      expect(q.partnerId, 'uB');
      expect(q.goalLessons, 12);
      expect(q.isActive, isTrue);
      expect(q.creatorProgress, 3);
      expect(q.partnerProgress, 4);
      expect(q.combinedProgress, 7);
      expect(q.remaining, 5);
      expect(q.fraction, closeTo(7 / 12, 1e-9));
      expect(q.done, isFalse);
    });

    test('otherId + myProgress are seat-relative', () {
      final FriendQuest q = FriendQuest.fromJson(row());
      expect(q.otherId('uA'), 'uB');
      expect(q.otherId('uB'), 'uA');
      expect(q.myProgress('uA'), 3);
      expect(q.myProgress('uB'), 4);
    });

    test('completed quest clamps + parses completed_at', () {
      final Map<String, dynamic> r = row(status: 'completed', combined: 12)
        ..['completed_at'] = '2026-07-18T10:00:00Z';
      final FriendQuest q = FriendQuest.fromJson(r);
      expect(q.isCompleted, isTrue);
      expect(q.done, isTrue);
      expect(q.remaining, 0);
      expect(q.fraction, 1.0);
      expect(q.completedAt, isNotNull);
    });

    test('missing/unknown fields degrade honestly (empty status -> pending)', () {
      final FriendQuest q = FriendQuest.fromJson(<String, dynamic>{
        'friend_quest_id': 'q2',
        'creator_id': 'uA',
        'partner_id': 'uB',
        'goal_lessons': 5,
      });
      expect(q.status, 'pending');
      expect(q.isPending, isTrue);
      expect(q.combinedProgress, 0);
      expect(q.remaining, 5);
      expect(q.fraction, 0);
      expect(q.completedAt, isNull);
    });
  });

  group('UnavailableFriendQuestService (honest default)', () {
    const FriendQuestService s = UnavailableFriendQuestService();
    test('list is empty; writes are no-ops (never fabricates a partner)',
        () async {
      expect(await s.list(), isEmpty);
      expect(await s.create('bob'), isNull);
      expect(await s.create('bob', goal: 20), isNull);
      expect(await s.respond('q1', accept: true), isNull);
      expect(await s.refresh('q1'), isNull);
    });
  });

  group('SupabaseFriendQuestService.normalizeHandle', () {
    test('trims, drops leading @, lowercases', () {
      expect(SupabaseFriendQuestService.normalizeHandle('  @Bob '), 'bob');
      expect(SupabaseFriendQuestService.normalizeHandle('@@MIA'), 'mia');
      expect(SupabaseFriendQuestService.normalizeHandle('carol'), 'carol');
    });
  });
}
