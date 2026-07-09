import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/learning/learning.dart';

/// Records every append so the test can assert the controller fired the seam.
class _RecordingSink implements ReviewLogSink {
  final List<(String, ReviewLogEntry)> appended = <(String, ReviewLogEntry)>[];

  @override
  void append(String targetLocale, ReviewLogEntry entry) =>
      appended.add((targetLocale, entry));
}

void main() {
  test('recordReview fires the durable answer-spine sink exactly once', () {
    final _RecordingSink sink = _RecordingSink();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      reviewLogSinkProvider.overrideWithValue(sink),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(c.dispose);

    const ReviewLogEntry entry = ReviewLogEntry(
      itemId: 'i1',
      skill: 's1',
      grade: FsrsRating.good,
      correct: true,
      elapsedMs: 0,
      thetaBefore: -2.5,
      irtBAtReview: -2.5,
      source: 'lesson',
    );
    c.read(learnerControllerProvider.notifier).recordReview(entry);

    expect(sink.appended, hasLength(1));
    expect(sink.appended.single.$1, 'es'); // the controller's targetLocale
    expect(sink.appended.single.$2, same(entry));
  });

  test('default sink is the no-op — recordReview stays side-effect free', () {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(c.dispose);
    expect(c.read(reviewLogSinkProvider), isA<NoopReviewLogSink>());
    c.read(learnerControllerProvider.notifier).recordReview(
          const ReviewLogEntry(
            itemId: 'i2',
            skill: 's1',
            grade: FsrsRating.again,
            correct: false,
            elapsedMs: 0,
            thetaBefore: 0,
            irtBAtReview: 0,
            source: 'lesson',
          ),
        );
  });
}
