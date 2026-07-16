import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// The owner's locked roleplay taxonomy (design #23) — five NAMED categories
/// that replace the old CEFR-band section headers. [C-R1]
///
/// `CourseScenario` carries NO category/tag/topic field (verified: the model
/// exposes only `world`/`title`/`goal`/`cefr`, and the content `scenario`
/// JSON has no category key either). So the bucket is **derived
/// deterministically** from the real authored signal (world+title+goal) by
/// [categoryOf] — the same honest derive-don't-fabricate pattern INC-1 used
/// for flag derivation. We never invent a content field and never re-author a
/// scenario. [R-B3]
enum RoleplayCategory { everyday, travel, workStudy, social, health }

/// FIXED render order for the category sections (design #23 top-to-bottom).
/// Only categories that actually contain scenarios are shown (empty buckets
/// stay hidden — honest, content-gated per C-R3).
const List<RoleplayCategory> _kCategoryOrder = <RoleplayCategory>[
  RoleplayCategory.everyday,
  RoleplayCategory.travel,
  RoleplayCategory.workStudy,
  RoleplayCategory.social,
  RoleplayCategory.health,
];

/// Localized section-header label for a category (labels come from ARB).
String _categoryLabel(BuildContext context, RoleplayCategory c) {
  switch (c) {
    case RoleplayCategory.everyday:
      return context.l10n.roleplayCatEveryday;
    case RoleplayCategory.travel:
      return context.l10n.roleplayCatTravel;
    case RoleplayCategory.workStudy:
      return context.l10n.roleplayCatWorkStudy;
    case RoleplayCategory.social:
      return context.l10n.roleplayCatSocial;
    case RoleplayCategory.health:
      return context.l10n.roleplayCatHealth;
  }
}

/// Pure, deterministic category derivation over the scenario's real authored
/// text (world + title + goal, lower-cased). The keyword map is documented and
/// ordered so the FIRST matching family wins; anything unmatched falls back to
/// [RoleplayCategory.everyday] (we keep to the five owner-locked buckets and
/// never invent a sixth visible section). This is intentionally a heuristic
/// over honest signal — NOT a fabricated content field. [C-R1 · R-B3]
///
/// Ordering note: HEALTH, TRAVEL, WORK & STUDY and SOCIAL are checked before
/// EVERYDAY-ish food words so a "café" that is really a barista job interview
/// ("a bright cafe hiring a weekend barista") lands under WORK & STUDY via the
/// stronger `barista`/`hiring` signal, while a plain "small café in town"
/// falls through to EVERYDAY.
RoleplayCategory categoryOf(CourseScenario s) {
  final String hay =
      '${s.world ?? ''} ${s.title} ${s.goal ?? ''}'.toLowerCase();

  bool has(List<String> keys) {
    for (final String k in keys) {
      if (hay.contains(k)) return true;
    }
    return false;
  }

  // HEALTH — doctor / pharmacy / clinic / hospital / dentist / health / ill.
  if (has(<String>[
    'doctor',
    'pharmacy',
    'pharmacist',
    'clinic',
    'hospital',
    'dentist',
    'health',
    'symptom',
    'ill',
    'sick',
    'medic',
  ])) {
    return RoleplayCategory.health;
  }

  // SOCIAL — a first-meeting / greeting / friend scene: friend / party / meet /
  // classmate / neighbour / social / invite, plus explicit greeting signals
  // (greet / introduce / get to know / make friends). Checked BEFORE WORK &
  // STUDY so a "classmate" greeting ("school hallway — greet Ben and introduce
  // yourself") reads SOCIAL rather than being pulled to WORK by the incidental
  // "school". (An interview at a café has none of these signals, so the
  // stronger barista/hiring cues below still resolve it to WORK & STUDY.)
  if (has(<String>[
    'friend',
    'party',
    'meet',
    'neighbour',
    'neighbor',
    'social',
    'invite',
    'classmate',
    'rapport',
    'greet',
    'introduce',
    'get to know',
    'make friends',
  ])) {
    return RoleplayCategory.social;
  }

  // WORK & STUDY — office / work / colleague / school / college / interview /
  // barista / hiring / study. Checked after SOCIAL (so a first-meeting
  // classmate scene stays SOCIAL) but before food/travel so a "barista"/"job
  // interview" at a café resolves to work, not everyday. ('class' is
  // intentionally NOT a keyword — it would spuriously match "classmate".)
  if (has(<String>[
    'office',
    'work',
    'colleague',
    'coworker',
    'school',
    'college',
    'university',
    'interview',
    'barista',
    'hiring',
    'hire',
    'study',
    'proposal',
    'meeting a new colleague',
    'the room',
  ])) {
    return RoleplayCategory.workStudy;
  }

  // TRAVEL — airport / station / bus / taxi / street / city / hotel / trip /
  // travel / directions.
  if (has(<String>[
    'airport',
    'station',
    'bus',
    'taxi',
    'train',
    'street',
    'city',
    'hotel',
    'trip',
    'travel',
    'directions',
    'flight',
    'abroad',
  ])) {
    return RoleplayCategory.travel;
  }

  // EVERYDAY — café / restaurant / bakery / market / shop / food / order.
  // Also the DEFAULT bucket for anything unmatched (kept to the five).
  return RoleplayCategory.everyday;
}

/// Per-scene medallion (emoji + tint) derived deterministically from the same
/// real signal, replacing the single fixed 🎭 purple medallion (design #23
/// varied medallions). Tints are [RatelColors] tokens — no raw hex in features
/// (token_lint). Default keeps the 🎭 mask so an unmatched scene still reads as
/// roleplay. [C-R4]
({String emoji, Color tint}) _medallionOf(CourseScenario s) {
  final String hay =
      '${s.world ?? ''} ${s.title} ${s.goal ?? ''}'.toLowerCase();

  bool has(List<String> keys) {
    for (final String k in keys) {
      if (hay.contains(k)) return true;
    }
    return false;
  }

  if (has(<String>['doctor', 'pharmacy', 'clinic', 'hospital', 'dentist',
      'health', 'symptom', 'medic'])) {
    return (emoji: '🩺', tint: RatelColors.coral);
  }
  if (has(<String>['airport', 'station', 'train', 'flight', 'trip', 'travel',
      'bus', 'taxi', 'directions', 'abroad'])) {
    return (emoji: '✈️', tint: RatelColors.blue);
  }
  if (has(<String>['bakery', 'bread', 'croissant'])) {
    return (emoji: '🥐', tint: RatelColors.amber);
  }
  if (has(<String>['restaurant', 'dinner', 'menu', 'waiter', 'table'])) {
    return (emoji: '🍽', tint: RatelColors.districtCafe);
  }
  if (has(<String>['café', 'cafe', 'coffee', 'barista', 'drink'])) {
    return (emoji: '☕', tint: RatelColors.districtCafe);
  }
  if (has(<String>['market', 'shop', 'store', 'refund', 'buy', 'pay'])) {
    return (emoji: '🛍', tint: RatelColors.green);
  }
  if (has(<String>['office', 'work', 'colleague', 'interview', 'school',
      'college', 'class', 'hiring', 'study', 'proposal'])) {
    return (emoji: '💼', tint: RatelColors.teal);
  }
  if (has(<String>['friend', 'party', 'meet', 'neighbour', 'neighbor',
      'classmate', 'invite', 'social', 'rapport'])) {
    return (emoji: '👋', tint: RatelColors.purple);
  }
  return (emoji: '🎭', tint: RatelColors.purple);
}

/// Roleplay (INF-8) — the un-gated pre-generated roleplay library. Lists the
/// graded roleplay drills the current course authors (content `scenario`,
/// kind=roleplay), grouped under the owner's five NAMED categories
/// (EVERYDAY / TRAVEL / WORK & STUDY / SOCIAL / HEALTH, design #23) derived
/// deterministically from real scenario text, filterable by a live search
/// field, each opening the [RoleplayPlayerScreen]. A course with none yet shows
/// an HONEST empty state — never a fabricated list. [R-D10 · R-B3]
class RoleplayScreen extends ConsumerStatefulWidget {
  const RoleplayScreen({super.key});

  @override
  ConsumerState<RoleplayScreen> createState() => _RoleplayScreenState();
}

class _RoleplayScreenState extends ConsumerState<RoleplayScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _onChanged(String value) => setState(() => _query = value.trim());

  void _clear() {
    _search.clear();
    setState(() => _query = '');
  }

  /// Case-insensitive live filter over title / goal / world (C-R2).
  bool _matches(CourseScenario s) {
    if (_query.isEmpty) return true;
    final String q = _query.toLowerCase();
    return s.title.toLowerCase().contains(q) ||
        (s.goal ?? '').toLowerCase().contains(q) ||
        (s.world ?? '').toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final List<CourseScenario> items = ref.watch(courseSpineProvider).roleplays;
    final bool isPro = ref.watch(isProProvider);

    // Derive + bucket (fixed order), honoring the live search filter.
    final Map<RoleplayCategory, List<CourseScenario>> byCategory =
        <RoleplayCategory, List<CourseScenario>>{};
    for (final CourseScenario s in items) {
      if (!_matches(s)) continue;
      (byCategory[categoryOf(s)] ??= <CourseScenario>[]).add(s);
    }

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(RatelIcons.arrowBack, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(context.l10n.libraryRoleplay,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
      ),
      body: items.isEmpty
          ? _empty(context)
          : ListView(
              key: const ValueKey<String>('screen-roleplay'),
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              children: <Widget>[
                Text(
                  context.l10n.roleplaySub,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.muted),
                ),
                const SizedBox(height: RatelSpace.md),
                // C-R2: live search under the subheader — filters rows by
                // title/goal/world, case-insensitive. Built from the Library
                // search field style (Ratel tokens only, no raw hex).
                _searchField(context),
                const SizedBox(height: RatelSpace.lg),
                // L-3 (S113): the LIVE variant entry — ADDITIVE beside the
                // pre-generated list (plan §B; anti-goal §D: this screen's
                // authored surface is untouched). Two-signal honesty lives on
                // the LiveRoleplayScreen itself. [R-H6 · R-J1]
                RatelCard(
                  key: const ValueKey<String>('live-roleplay-entry'),
                  gradient: const LinearGradient(
                      colors: <Color>[RatelColors.teal, RatelColors.tealDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  onTap: () => context.push('/roleplay-live'),
                  child: Row(
                    children: <Widget>[
                      const Text('🎙️', style: TextStyle(fontSize: 30)),
                      const SizedBox(width: RatelSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(context.l10n.liveRoleplayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: RatelFont.display,
                                    fontWeight: RatelType.extraBold,
                                    fontSize: RatelType.cardTitle,
                                    color: RatelColors.onColor)),
                            Text(context.l10n.liveRoleplayCardSub,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: RatelFont.body,
                                    fontSize: RatelType.small,
                                    color: RatelColors.onColor)),
                          ],
                        ),
                      ),
                      if (!isPro) ...<Widget>[
                        const SizedBox(width: RatelSpace.sm),
                        RatelChip.pro(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: RatelSpace.lg),
                // C-R1: named-category sections in FIXED order; only categories
                // that actually have (matching) scenarios render.
                if (byCategory.isEmpty)
                  _noMatches(context)
                else
                  for (final RoleplayCategory cat in _kCategoryOrder)
                    if (byCategory[cat] != null) ...<Widget>[
                      RatelSectionHeader(label: _categoryLabel(context, cat)),
                      const SizedBox(height: RatelSpace.sm),
                      for (final CourseScenario s in byCategory[cat]!) ...<Widget>[
                        Builder(builder: (BuildContext context) {
                          final ({String emoji, Color tint}) m =
                              _medallionOf(s);
                          return RatelListRow(
                            key: ValueKey<String>('roleplay-row-${s.id}'),
                            leadingEmoji: m.emoji,
                            leadingColor: m.tint,
                            title: s.title,
                            subtitle: s.goal == null || s.goal!.isEmpty
                                ? (s.world ?? context.l10n.libraryRoleplay)
                                : s.goal!,
                            onTap: () => context.push(
                                '/roleplay-play?scenario=${Uri.encodeComponent(s.id)}'),
                          );
                        }),
                        const SizedBox(height: RatelSpace.sm),
                      ],
                      const SizedBox(height: RatelSpace.md),
                    ],
              ],
            ),
    );
  }

  Widget _searchField(BuildContext context) => Container(
        key: const ValueKey<String>('roleplay-search'),
        padding: const EdgeInsets.symmetric(horizontal: RatelSpace.lg),
        decoration: BoxDecoration(
          color: context.palette.white,
          borderRadius: BorderRadius.circular(RatelRadius.pill),
          border: Border.all(color: context.palette.border),
        ),
        child: Row(
          children: <Widget>[
            const Text('🔍', style: TextStyle(fontSize: 16)),
            const SizedBox(width: RatelSpace.sm),
            Expanded(
              child: TextField(
                key: const ValueKey<String>('roleplay-search-field'),
                controller: _search,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.ink),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: context.l10n.roleplaySearchHint,
                  hintStyle: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: context.palette.muted),
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                key: const ValueKey<String>('roleplay-search-clear'),
                onTap: _clear,
                child: Icon(RatelIcons.close,
                    size: 18, color: context.palette.muted),
              ),
          ],
        ),
      );

  Widget _noMatches(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: RatelSpace.lg),
        child: Text(
          context.l10n.searchNoMatches(_query),
          style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.body,
              color: context.palette.muted),
        ),
      );

  Widget _empty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🎭', style: TextStyle(fontSize: 56)),
              const SizedBox(height: RatelSpace.md),
              Text(context.l10n.roleplayEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.bodyLg,
                      color: context.palette.muted)),
            ],
          ),
        ),
      );
}
