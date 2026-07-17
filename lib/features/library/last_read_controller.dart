import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/library/last_read_store.dart';

export 'package:ratel/services/library/last_read_store.dart'
    show LastReadRef, LastReadStore, InMemoryLastReadStore, lastReadStoreProvider;

/// Bridges the device-local [LastReadStore] to the Library CONTINUE card
/// (s163 INC-C1). Holds the single most-recently-OPENED Read&Listen pointer —
/// written ONLY when the reader mounts a REAL resolved story (never on the
/// unavailable/placeholder path), never fabricated, never a progress %. Mirrors
/// `AdventureProgressController` (device-local for everyone, guest included).
class LastReadController extends Notifier<LastReadRef?> {
  @override
  LastReadRef? build() => ref.read(lastReadStoreProvider).load();

  /// Record [item] as the last-opened pointer. Idempotent for an unchanged
  /// pointer (a state no-op + no redundant write) so a re-record on the same
  /// story doesn't churn the store. Best-effort device-local write; never
  /// blocks the reader.
  void record(LastReadRef item) {
    if (state == item) return;
    state = item;
    ref.read(lastReadStoreProvider).save(item);
  }

  /// Drop the pointer when it no longer resolves in [spine] — a course switch
  /// (different `courseCode`) or content removal (id absent from
  /// stories/podcasts/watch). Guarantees the Library never shows a DEAD
  /// CONTINUE pointing at a story that left the course (which would be a subtle
  /// fabrication of "where you were"). A state + store no-op when the pointer
  /// is null or still valid.
  void clearIfStale(CourseSpine spine) {
    final LastReadRef? cur = state;
    if (cur == null) return;
    if (cur.courseCode == spine.courseCode && _inSpine(spine, cur.passageId)) {
      return;
    }
    state = null;
    ref.read(lastReadStoreProvider).clear();
  }

  static bool _inSpine(CourseSpine spine, String id) {
    for (final CourseStory s in spine.stories) {
      if (s.id == id) return true;
    }
    for (final CourseStory s in spine.podcasts) {
      if (s.id == id) return true;
    }
    for (final CourseStory s in spine.watch) {
      if (s.id == id) return true;
    }
    return false;
  }
}

final lastReadControllerProvider =
    NotifierProvider<LastReadController, LastReadRef?>(LastReadController.new);
