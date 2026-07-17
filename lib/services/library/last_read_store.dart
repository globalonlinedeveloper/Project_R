import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The most recently OPENED Read&Listen item, as a device-local resume pointer
/// (s163 CONTINUE / INC-C1). It is REAL user state — the device recorded that
/// the user opened this story — so surfacing "CONTINUE → that story" is
/// honest; it is NOT a claim about progress %, completion, or time remaining.
/// We deliberately store NO read-percentage / scroll-offset in v1, so nothing
/// downstream can imply one.
///
/// Fields:
///  * [courseCode] — the batch/course the pointer belongs to, so a course
///    switch drops a stale pointer (see `LastReadController.clearIfStale`);
///  * [passageId] — the content `passage_id` (== `CourseStory.id`) to reopen;
///  * [title] / [cefr] — small display metadata cached at record time. The
///    CONTINUE card renders title/level from the LIVE resolved spine story
///    (spine wins on display), so these are only a fallback / debugging aid and
///    are never trusted over the live spine copy;
///  * [kind] — `'story' | 'podcast' | 'watch'`; v1 records only `'story'`, but
///    the pointer supports all three so a follow-up can resume any kind.
class LastReadRef {
  const LastReadRef({
    required this.courseCode,
    required this.passageId,
    required this.title,
    required this.cefr,
    this.kind = 'story',
  });

  final String courseCode;
  final String passageId;
  final String title;
  final String cefr;
  final String kind;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'courseCode': courseCode,
        'passageId': passageId,
        'title': title,
        'cefr': cefr,
        'kind': kind,
      };

  /// Tolerant decode: any missing/blank `passageId` (the only load-bearing
  /// field) yields `null` — we never fabricate a pointer from a malformed
  /// value. Absent `courseCode`/`title`/`cefr` default to empty; absent `kind`
  /// defaults to `'story'`.
  static LastReadRef? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final Object? id = raw['passageId'];
    if (id is! String || id.isEmpty) return null;
    String str(Object? v) => v is String ? v : '';
    final Object? kind = raw['kind'];
    return LastReadRef(
      courseCode: str(raw['courseCode']),
      passageId: id,
      title: str(raw['title']),
      cefr: str(raw['cefr']),
      kind: (kind is String && kind.isNotEmpty) ? kind : 'story',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LastReadRef &&
      other.courseCode == courseCode &&
      other.passageId == passageId &&
      other.title == title &&
      other.cefr == cefr &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(courseCode, passageId, title, cefr, kind);

  @override
  String toString() =>
      'LastReadRef($kind:$passageId "$title" $cefr @$courseCode)';
}

/// Persistence seam for the device-local LAST-READ pointer (s163 INC-C1). A
/// single pointer (unlike the adventure explored-SET); synchronous [load] keeps
/// controller construction test-friendly (mirrors `ImmersionModeStore`). A
/// `null` return means nothing has been opened yet ⇒ the Library shows NO
/// CONTINUE card (honest empty state).
///
/// Device-local for everyone (guest included) — the synced `user_settings` row
/// is fixed-column (S111/S126 — an unknown column 400s the whole upsert), so a
/// cross-device synced pointer (`user_last_read`) is a separate owner-gated
/// migration (INC-C4), never smuggled in here.
abstract class LastReadStore {
  LastReadRef? load();
  Future<void> save(LastReadRef ref);
  Future<void> clear();
}

/// Default — in-memory (tests + keyless boots). A `PrefsLastReadStore` override
/// in `main` gives real on-device persistence.
class InMemoryLastReadStore implements LastReadStore {
  InMemoryLastReadStore([this._ref]);

  LastReadRef? _ref;

  /// The most recently saved value (handy for tests).
  LastReadRef? get current => _ref;

  @override
  LastReadRef? load() => _ref;

  @override
  Future<void> save(LastReadRef ref) async {
    _ref = ref;
  }

  @override
  Future<void> clear() async {
    _ref = null;
  }
}

/// The last-read persistence seam. Defaults to in-memory; `main` overrides it
/// with a `PrefsLastReadStore` for real on-device persistence.
final Provider<LastReadStore> lastReadStoreProvider =
    Provider<LastReadStore>((ref) => InMemoryLastReadStore());
