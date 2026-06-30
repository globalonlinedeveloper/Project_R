import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/search/search.dart';

/// Global SEARCH screen (📚 Library → 🔍, R-L12). Searches the learner's REAL
/// published catalogue — authored course lessons, saved words and real app
/// destinations — through the pure [GlobalSearch] engine, debounced ~350 ms (the
/// locked 300–400 ms). Every hit is type-tagged and taps straight through to a
/// genuine route.
///
/// HONESTY (charter "don't fake depth"): titles + tags at launch (the locked
/// R-L12 bar). Full sentence/gloss text, a server content index, multi-course
/// scope and recent/trending are the spec's deferred fast-follow — shown here as
/// an honest note, never a faked result. Story/podcast hits arrive with the §6
/// media engine.
class LibrarySearchScreen extends ConsumerStatefulWidget {
  const LibrarySearchScreen({super.key});

  @override
  ConsumerState<LibrarySearchScreen> createState() =>
      _LibrarySearchScreenState();
}

class _LibrarySearchScreenState extends ConsumerState<LibrarySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _query = '');
  }

  /// Persist a genuine search into the device-local recent list (R-L12).
  void _remember(String q) {
    if (q.trim().isEmpty) return;
    ref.read(appSettingsControllerProvider.notifier).addRecentSearch(q);
  }

  /// Re-run a tapped recent query.
  void _runRecent(String q) {
    _debounce?.cancel();
    _controller.text = q;
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    setState(() => _query = q);
  }

  /// Project the live providers into the engine's lightweight inputs.
  List<SearchableLesson> _lessons(CourseSpine spine) => <SearchableLesson>[
        for (final CourseUnit u in spine.units)
          for (final CourseLesson l in u.lessons)
            SearchableLesson(
                id: l.id,
                title: l.title,
                cefr: l.cefr,
                unitTitle: u.title,
                terms: _termsOf(l)),
      ];

  /// The lesson's REAL published exercise text (prompts + accepted answers),
  /// bounded — full-text search matches it below titles (R-L12 fast-follow).
  List<String> _termsOf(CourseLesson l) {
    final List<String> out = <String>[];
    for (final CourseExercise e in l.exercises) {
      if (e.prompt.isNotEmpty) out.add(e.prompt);
      out.addAll(e.accepted);
      if (out.length > 24) break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final CourseSpine spine = ref.watch(courseSpineProvider);
    final List<SavedWordCard> cards =
        ref.watch(savedWordsControllerProvider).cards;
    final List<SearchableWord> words = <SearchableWord>[
      for (final SavedWordCard c in cards)
        SearchableWord(word: c.word, glyph: c.glyph),
    ];
    final List<SearchHit> hits = GlobalSearch.run(_query,
        lessons: _lessons(spine), words: words);
    final bool hasQuery = _query.trim().isNotEmpty;

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
        title: Text(
          'Search',
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.sm, RatelSpace.screen, RatelSpace.md),
              child: _field(context),
            ),
            Expanded(
              child: hasQuery ? _results(context, hits) : _idle(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context) => Container(
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
                key: const ValueKey<String>('search-field'),
                controller: _controller,
                autofocus: true,
                onChanged: _onChanged,
                onSubmitted: _remember,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.ink),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Search lessons, words, pages…',
                  hintStyle: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: context.palette.muted),
                ),
              ),
            ),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                key: const ValueKey<String>('search-clear'),
                onTap: _clear,
                child: Icon(RatelIcons.close,
                    size: 18, color: context.palette.muted),
              ),
          ],
        ),
      );

  Widget _results(BuildContext context, List<SearchHit> hits) {
    if (hits.isEmpty) return _noMatch(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          RatelSpace.screen, 0, RatelSpace.screen, RatelSpace.xl),
      itemCount: hits.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: RatelSpace.sm),
      itemBuilder: (BuildContext context, int i) =>
          i == hits.length ? _footer(context) : _row(context, hits[i]),
    );
  }

  Widget _idle(BuildContext context) {
    final List<String> recents =
        ref.watch(appSettingsControllerProvider).recentSearches;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          RatelSpace.screen, 0, RatelSpace.screen, RatelSpace.xl),
      children: <Widget>[
        if (recents.isNotEmpty) ...<Widget>[
          Row(
            children: <Widget>[
              const Expanded(child: RatelSectionHeader(label: 'Recent')),
              GestureDetector(
                key: const ValueKey<String>('recent-clear'),
                onTap: () => ref
                    .read(appSettingsControllerProvider.notifier)
                    .clearRecentSearches(),
                child: Text('Clear',
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        fontWeight: RatelType.semiBold,
                        color: context.palette.muted)),
              ),
            ],
          ),
          const SizedBox(height: RatelSpace.sm),
          Wrap(
            spacing: RatelSpace.sm,
            runSpacing: RatelSpace.sm,
            children: <Widget>[
              for (final String q in recents) _recentChip(context, q),
            ],
          ),
          const SizedBox(height: RatelSpace.lg),
        ],
        const RatelSectionHeader(label: 'Jump to'),
        const SizedBox(height: RatelSpace.sm),
        for (final SearchDestination d in kSearchDestinations.take(6)) ...<Widget>[
          _row(
            context,
            SearchHit(
              kind: SearchHitKind.destination,
              title: d.title,
              subtitle: d.subtitle,
              route: d.route,
              tag: 'Page',
              emoji: d.emoji,
            ),
          ),
          const SizedBox(height: RatelSpace.sm),
        ],
        const SizedBox(height: RatelSpace.sm),
        _note(context,
            'Searching titles, tags and lesson content across your course, saved words and pages. A server content index and trending are the remaining R-L12 fast-follow — nothing here is faked.'),
      ],
    );
  }

  Widget _recentChip(BuildContext context, String q) => GestureDetector(
        onTap: () => _runRecent(q),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.md, vertical: RatelSpace.sm),
          decoration: BoxDecoration(
            color: context.palette.cream2,
            borderRadius: BorderRadius.circular(RatelRadius.pill),
            border: Border.all(color: context.palette.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🕘', style: TextStyle(fontSize: 13)),
              const SizedBox(width: RatelSpace.xs),
              Text(q,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.ink)),
            ],
          ),
        ),
      );

  Widget _noMatch(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.xl,
            RatelSpace.screen, RatelSpace.xl),
        children: <Widget>[
          const Center(child: Text('🔍', style: TextStyle(fontSize: 40))),
          const SizedBox(height: RatelSpace.md),
          Center(
            child: Text(
              'No matches for “${_query.trim()}”',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: RatelType.extraBold,
                  fontSize: RatelType.cardTitle,
                  color: context.palette.ink),
            ),
          ),
          const SizedBox(height: RatelSpace.md),
          _note(context,
              'Searches your published course lessons, saved words and app pages (titles + tags). Stories/podcasts and full-text are the R-L12 fast-follow — never faked.'),
        ],
      );

  Widget _row(BuildContext context, SearchHit h) => GestureDetector(
        onTap: () {
          _remember(_query);
          context.push(h.route);
        },
        child: Container(
          padding: const EdgeInsets.all(RatelSpace.md),
          decoration: BoxDecoration(
            color: context.palette.white,
            borderRadius: BorderRadius.circular(RatelRadius.card),
            border: Border.all(color: context.palette.border),
          ),
          child: Row(
            children: <Widget>[
              Text(h.emoji ?? '🔎', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: RatelSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(h.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: RatelFont.display,
                            fontWeight: RatelType.semiBold,
                            fontSize: RatelType.body,
                            color: context.palette.ink)),
                    Text(h.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.small,
                            color: context.palette.muted)),
                  ],
                ),
              ),
              const SizedBox(width: RatelSpace.sm),
              RatelChip(label: h.tag),
            ],
          ),
        ),
      );

  Widget _footer(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: RatelSpace.md),
        child: _note(context,
            'Titles + tags at launch. Full-text, stories/podcasts and multi-course scope are the R-L12 fast-follow — never faked.'),
      );

  Widget _note(BuildContext context, String text) => Container(
        padding: const EdgeInsets.all(RatelSpace.md),
        decoration: BoxDecoration(
          color: context.palette.cream2,
          borderRadius: BorderRadius.circular(RatelRadius.card),
        ),
        child: Text(text,
            style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.small,
                color: context.palette.muted)),
      );
}
