import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/data_access/supabase_review_log_sink.dart';
import 'package:ratel/services/learning/learning.dart';

void main() {
  const ReviewLogEntry entry = ReviewLogEntry(
    itemId: 'item_x',
    skill: 'skill_y',
    grade: FsrsRating.hard,
    correct: false,
    elapsedMs: 1234,
    thetaBefore: -0.5,
    irtBAtReview: 0.25,
    source: 'lesson',
    feedsTheta: false,
  );

  test('rowFor maps every spine field 1:1 (grade = FSRS 1..4 int)', () {
    final Map<String, Object?> row =
        SupabaseReviewLogSink.rowFor(entry, 'en', 'u1');
    expect(row, <String, Object?>{
      'user_id': 'u1',
      'target_locale': 'en',
      'item_id': 'item_x',
      'skill': 'skill_y',
      'grade': 2,
      'correct': false,
      'elapsed_ms': 1234,
      'theta_before': -0.5,
      'irt_b_at_review': 0.25,
      'source': 'lesson',
      'feeds_theta': false,
    });
    expect(row.containsKey('taken_at'), isFalse); // DB default now()
  });

  test('guest sink (null client) is an honest silent no-op', () {
    SupabaseReviewLogSink(null).append('en', entry); // must not throw
  });

  test('NoopReviewLogSink drops entries silently', () {
    const NoopReviewLogSink().append('en', entry);
  });
}
