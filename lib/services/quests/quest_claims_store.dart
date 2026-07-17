import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The DEVICE-LOCAL, durable record of which daily quests have already PAID
/// their 💎 today (INC-QR1 durable idempotency). It is REAL user state — the
/// device credited these quest ids on this calendar day — so refusing to pay
/// them again is honest, and survives a relaunch (unlike `xpToday`, which has
/// no durable column and resets to 0 on boot). Without this a paid quest would
/// re-complete after relaunch once XP is re-earned and pay a SECOND time; the
/// persisted claimed-set closes that restart double-credit path.
///
/// Fields:
///  * [day] — the calendar day (date-only, local midnight) the [ids] belong to;
///    a stored day != today is STALE (a new day re-opens every quest), so the
///    controller ignores it and starts the day empty;
///  * [ids] — the set of quest ids already credited on [day]. A quest in this
///    set will NOT pay again on the same day, even across a restart.
///
/// This is deliberately per-CALENDAR-DAY per-DEVICE only: it is not a synced
/// ledger (that fixed-column / owner-gated migration is INC-QR2), so it caps a
/// quest at one payout per day per device, never claims cross-device proof.
class QuestClaims {
  const QuestClaims({this.day, this.ids = const <String>{}});

  /// The empty claims value — no day, no ids (nothing paid yet).
  static const QuestClaims empty = QuestClaims();

  final DateTime? day;
  final Set<String> ids;

  /// ISO date-only string for [day] (`yyyy-mm-dd`), or null when unset. Kept
  /// date-only so equality is by calendar day, never wall-clock instant.
  String? get _dayIso => day == null
      ? null
      : '${day!.year.toString().padLeft(4, '0')}-'
          '${day!.month.toString().padLeft(2, '0')}-'
          '${day!.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (_dayIso != null) 'day': _dayIso,
        'ids': ids.toList(growable: false),
      };

  /// Tolerant decode: any malformed shape yields [empty] — we never fabricate a
  /// claim from a bad value, and never throw into the boot path. A missing or
  /// unparseable `day` drops the day (⇒ treated as stale ⇒ a fresh day), and a
  /// missing/non-list `ids` yields an empty set.
  static QuestClaims fromJson(Object? raw) {
    if (raw is! Map) return empty;
    final Object? rawDay = raw['day'];
    final DateTime? day = (rawDay is String) ? _parseDate(rawDay) : null;
    final Object? rawIds = raw['ids'];
    final Set<String> ids = <String>{
      if (rawIds is List)
        for (final Object? id in rawIds)
          if (id is String && id.isNotEmpty) id,
    };
    return QuestClaims(day: day, ids: ids);
  }

  /// Parse a date-only `yyyy-mm-dd` to a local-midnight [DateTime], or null on
  /// any malformed value (never throws).
  static DateTime? _parseDate(String iso) {
    final List<String> parts = iso.split('-');
    if (parts.length != 3) return null;
    final int? y = int.tryParse(parts[0]);
    final int? m = int.tryParse(parts[1]);
    final int? d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    return DateTime(y, m, d);
  }

  @override
  bool operator ==(Object other) =>
      other is QuestClaims && other.day == day && _setEquals(other.ids, ids);

  @override
  int get hashCode => Object.hash(day, Object.hashAllUnordered(ids));

  @override
  String toString() => 'QuestClaims(${_dayIso ?? '-'}: ${ids.join(',')})';

  static bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    for (final String e in a) {
      if (!b.contains(e)) return false;
    }
    return true;
  }
}

/// Persistence seam for the device-local quest-claims record (INC-QR1). A
/// synchronous [load] keeps controller construction test-friendly (mirrors
/// `LastReadStore` / `ImmersionModeStore`); [save] is best-effort and never
/// blocks the earn path. [QuestClaims.empty] means nothing has paid yet ⇒ the
/// controller starts the day with an empty claimed-set.
///
/// Device-local for everyone (guest included) — the synced `user_course` row is
/// fixed-column, so a cross-device synced ledger is a separate owner-gated
/// migration (INC-QR2), never smuggled in here.
abstract class QuestClaimsStore {
  QuestClaims load();
  Future<void> save(QuestClaims claims);
}

/// Default — in-memory (tests + keyless boots). A `PrefsQuestClaimsStore`
/// override in `main` gives real on-device persistence that survives relaunch.
class InMemoryQuestClaimsStore implements QuestClaimsStore {
  InMemoryQuestClaimsStore([this._claims = QuestClaims.empty]);

  QuestClaims _claims;

  /// The most recently saved value (handy for tests).
  QuestClaims get current => _claims;

  @override
  QuestClaims load() => _claims;

  @override
  Future<void> save(QuestClaims claims) async {
    _claims = claims;
  }
}

/// The quest-claims persistence seam. Defaults to in-memory; `main` overrides it
/// with a `PrefsQuestClaimsStore` for real on-device persistence.
final Provider<QuestClaimsStore> questClaimsStoreProvider =
    Provider<QuestClaimsStore>((ref) => InMemoryQuestClaimsStore());
