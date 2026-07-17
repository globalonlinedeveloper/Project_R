import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/library/last_read_controller.dart';

// s163 INC-C1 — the controller bridges the device-local store to the CONTINUE
// card: record() persists + updates state; clearIfStale() drops a pointer that
// no longer resolves in the current spine (course switch / content pull).

CourseStory _story(String id) =>
    CourseStory(id: id, title: id, cefr: 'A2', sentences: const <String>['x.']);

CourseSpine _spine({String code = 'es'}) => CourseSpine(
      courseCode: code,
      units: const <CourseUnit>[],
      stories: <CourseStory>[_story('s1'), _story('s2')],
      podcasts: <CourseStory>[_story('p1')],
    );

const LastReadRef _s2 = LastReadRef(
    courseCode: 'es', passageId: 's2', title: 'La receta', cefr: 'A2');

ProviderContainer _container(InMemoryLastReadStore store) {
  final ProviderContainer c = ProviderContainer(overrides: <Override>[
    lastReadStoreProvider.overrideWithValue(store),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('build() hydrates from the store', () {
    final InMemoryLastReadStore store = InMemoryLastReadStore(_s2);
    final ProviderContainer c = _container(store);
    expect(c.read(lastReadControllerProvider), _s2);
  });

  test('record updates state AND persists to the store', () {
    final InMemoryLastReadStore store = InMemoryLastReadStore();
    final ProviderContainer c = _container(store);
    expect(c.read(lastReadControllerProvider), isNull);

    c.read(lastReadControllerProvider.notifier).record(_s2);
    expect(c.read(lastReadControllerProvider), _s2);
    expect(store.current, _s2);
  });

  test('record is a no-op when the pointer is unchanged (no churn)', () {
    final InMemoryLastReadStore store = InMemoryLastReadStore(_s2);
    final ProviderContainer c = _container(store);
    int rebuilds = 0;
    c.listen(lastReadControllerProvider, (_, _) => rebuilds++);
    c.read(lastReadControllerProvider.notifier).record(_s2);
    expect(rebuilds, 0);
    expect(c.read(lastReadControllerProvider), _s2);
  });

  test('clearIfStale keeps a pointer that still resolves in the spine', () {
    final InMemoryLastReadStore store = InMemoryLastReadStore(_s2);
    final ProviderContainer c = _container(store);
    c.read(lastReadControllerProvider.notifier).clearIfStale(_spine());
    expect(c.read(lastReadControllerProvider), _s2);
    expect(store.current, _s2);
  });

  test('clearIfStale drops a pointer whose id left the spine', () {
    const LastReadRef gone = LastReadRef(
        courseCode: 'es', passageId: 'ghost', title: 'Old', cefr: 'A2');
    final InMemoryLastReadStore store = InMemoryLastReadStore(gone);
    final ProviderContainer c = _container(store);
    c.read(lastReadControllerProvider.notifier).clearIfStale(_spine());
    expect(c.read(lastReadControllerProvider), isNull);
    expect(store.current, isNull);
  });

  test('clearIfStale drops a pointer from a DIFFERENT course', () {
    // Same id exists, but the spine is now a different course ⇒ stale.
    final InMemoryLastReadStore store = InMemoryLastReadStore(_s2);
    final ProviderContainer c = _container(store);
    c.read(lastReadControllerProvider.notifier)
        .clearIfStale(_spine(code: 'fr'));
    expect(c.read(lastReadControllerProvider), isNull);
    expect(store.current, isNull);
  });

  test('clearIfStale on a null pointer is a no-op', () {
    final InMemoryLastReadStore store = InMemoryLastReadStore();
    final ProviderContainer c = _container(store);
    c.read(lastReadControllerProvider.notifier).clearIfStale(_spine());
    expect(c.read(lastReadControllerProvider), isNull);
  });
}
