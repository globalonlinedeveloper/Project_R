import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/learning/fsrs.dart' show FsrsRating;

/// My Words (📖) — the saved-words spaced-repetition review, reached from the
/// Practice hub "My Words" drill row (`/my-words`). Demoted from the old
/// `/practice` root to a hub leaf (INC-3); the engine is UNCHANGED. Each due
/// word is a flashcard graded Again / Hard / Good / Easy, folded through the
/// REAL FSRS-6 scheduler ([R-G5]) which reschedules its next due date; the queue
/// and the "words" count come from the REAL per-course dedup intake ([R-G9]).
///
/// HONEST (§6 "don't fake depth"): the due queue, the per-grade FSRS intervals
/// and the rescheduling are real engine output; a word's revealed meaning is the
/// authored lesson picture (emoji) — never an invented translation; a word with
/// no stored picture is an honest self-graded recall. The empty / caught-up
/// states show the REAL counts, never fabricated stats. Scheduling persists
/// in-session (like every R-O1 counter); the durable cross-restart store
/// (Supabase `user_item_state`) is the flagged go-live plug.
class MyWordsScreen extends ConsumerStatefulWidget {
  const MyWordsScreen({super.key});

  @override
  ConsumerState<MyWordsScreen> createState() => _MyWordsScreenState();
}

class _MyWordsScreenState extends ConsumerState<MyWordsScreen> {
  /// Snapshot of the cards captured when a review session starts; null when no
  /// session is running. Reviewing pushes a card's due date into the future, so
  /// the session iterates this fixed queue instead of a live-shrinking one.
  List<SavedWordCard>? _queue;
  int _idx = 0;
  bool _revealed = false;
  int _reviewed = 0;

  void _start() {
    final DateTime now = ref.read(clockProvider)();
    final List<SavedWordCard> due =
        ref.read(savedWordsControllerProvider).dueCards(now);
    if (due.isEmpty) {
      return;
    }
    setState(() {
      _queue = due;
      _idx = 0;
      _revealed = false;
      _reviewed = 0;
    });
  }

  void _grade(FsrsRating rating) {
    final List<SavedWordCard>? q = _queue;
    if (q == null || _idx >= q.length) {
      return;
    }
    ref
        .read(savedWordsControllerProvider.notifier)
        .review(q[_idx].key, rating);
    setState(() {
      _reviewed += 1;
      _idx += 1;
      _revealed = false;
    });
  }

  void _endSession() {
    setState(() {
      _queue = null;
      _idx = 0;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SavedWordsState vocab = ref.watch(savedWordsControllerProvider);
    final DateTime now = ref.read(clockProvider)();
    final List<SavedWordCard>? q = _queue;

    final List<Widget> children;
    if (q != null && _idx < q.length) {
      children = _reviewBody(q[_idx], _idx, q.length);
    } else if (q != null) {
      children = _completeBody();
    } else if (vocab.count == 0) {
      children = _emptyBody(context);
    } else {
      children = _overviewBody(context, vocab, now);
    }

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(RatelIcons.arrowBack, color: context.palette.ink),
          onPressed: () => _queue != null ? _endSession() : context.pop(),
        ),
        title: Text(
          context.l10n.practiceDrillMyWordsTitle,
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
        child: ListView(
          key: const ValueKey<String>('screen-my-words'),
          padding: const EdgeInsets.fromLTRB(
              RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
          children: children,
        ),
      ),
    );
  }

  // ---- Overview: has saved words; show the due queue / caught-up ------------
  List<Widget> _overviewBody(
      BuildContext context, SavedWordsState vocab, DateTime now) {
    final int due = vocab.dueCount(now);
    return <Widget>[
      _hero(vocab.count, due),
      const SizedBox(height: RatelSpace.cardGap),
      if (due > 0)
        RatelButton(
          label: context.l10n.practiceReviewWords(due),
          onPressed: _start,
        )
      else
        _caughtUpCard(vocab, now),
      const SizedBox(height: RatelSpace.lg),
      RatelSectionHeader(label: context.l10n.practiceYourWords),
      const SizedBox(height: RatelSpace.sm),
      for (final SavedWordCard c in vocab.cards) _wordRow(c, now),
      const SizedBox(height: RatelSpace.lg),
      _scheduleNote(),
    ];
  }

  Widget _hero(int count, int due) => RatelCard(
        gradient: const LinearGradient(
          colors: <Color>[RatelColors.teal, RatelColors.tealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: <Widget>[
            const Text('🗂️', style: TextStyle(fontSize: 32)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(context.l10n.practiceSavedWordsCount(count),
                      style: const TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.screenTitle,
                          color: RatelColors.onColor)),
                  Text(
                      due > 0
                          ? context.l10n.practiceDueForReview(due)
                          : context.l10n.practiceAllUpToDate,
                      style: const TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: RatelColors.onColor)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _caughtUpCard(SavedWordsState vocab, DateTime now) {
    final DateTime? next = vocab.nextDueAt(now);
    final String tail = next == null
        ? ''
        : context.l10n.practiceNextTail(_relative(next.difference(now)));
    return RatelCard(
      color: context.palette.cream2,
      child: Row(
        children: <Widget>[
          const Text('🎉', style: TextStyle(fontSize: 22)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Text(context.l10n.practiceCaughtUp(tail),
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.muted)),
          ),
          RatelChip(label: context.l10n.practiceZeroDue, tone: RatelChipTone.neutral),
        ],
      ),
    );
  }

  Widget _wordRow(SavedWordCard c, DateTime now) {
    final bool due = c.isDue(now);
    return Padding(
      padding: const EdgeInsets.only(bottom: RatelSpace.sm),
      child: RatelCard(
        child: Row(
          children: <Widget>[
            Text(c.glyph ?? '🔖', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(c.word,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: context.palette.ink)),
                  Text(
                      due
                          ? context.l10n.practiceDueNow
                          : context.l10n.practiceDueWhen(
                              _relative(c.dueAt!.difference(now))),
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: context.palette.muted)),
                ],
              ),
            ),
            const SizedBox(width: RatelSpace.sm),
            RatelChip(
              label: due
                  ? context.l10n.practiceChipDue
                  : context.l10n.practiceChipScheduled,
              tone: due ? RatelChipTone.amber : RatelChipTone.neutral,
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleNote() => Padding(
        padding: EdgeInsets.symmetric(horizontal: RatelSpace.sm),
        child: Text(
          context.l10n.practiceScheduleNote,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.small,
              color: context.palette.muted,
              height: 1.4),
        ),
      );

  // ---- Empty: no saved words yet -------------------------------------------
  List<Widget> _emptyBody(BuildContext context) => <Widget>[
        RatelCard(
          color: context.palette.cream2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text('🔖', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: RatelSpace.md),
                  Expanded(
                    child: Text(context.l10n.practiceNoSavedWords,
                        style: TextStyle(
                            fontFamily: RatelFont.display,
                            fontWeight: RatelType.extraBold,
                            fontSize: RatelType.cardTitle,
                            color: context.palette.ink)),
                  ),
                ],
              ),
              const SizedBox(height: RatelSpace.md),
              Text(
                context.l10n.practiceSaveWordHint,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.muted,
                    height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: RatelSpace.lg),
        RatelButton(
          label: context.l10n.practiceStartLesson,
          onPressed: () => context.push('/daily-quiz'),
        ),
      ];

  // ---- Review session: one flashcard ---------------------------------------
  List<Widget> _reviewBody(SavedWordCard card, int idx, int total) => <Widget>[
        RatelProgressBar(value: total == 0 ? 0 : idx / total),
        const SizedBox(height: RatelSpace.sm),
        Center(
          child: Text(context.l10n.practiceWordOf(idx + 1, total),
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted)),
        ),
        const SizedBox(height: RatelSpace.lg),
        _flashcard(card),
        const SizedBox(height: RatelSpace.lg),
        if (!_revealed)
          RatelButton(
            label: context.l10n.practiceShowAnswer,
            onPressed: () => setState(() => _revealed = true),
          )
        else
          ..._gradeButtons(card),
      ];

  Widget _flashcard(SavedWordCard card) => RatelCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: RatelSpace.xl, horizontal: RatelSpace.md),
          child: Column(
            children: <Widget>[
              Center(
                child: Text(card.word,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.screenTitle,
                        color: context.palette.ink)),
              ),
              if (_revealed) ...<Widget>[
                const SizedBox(height: RatelSpace.lg),
                if (card.glyph != null)
                  Center(
                      child:
                          Text(card.glyph!, style: const TextStyle(fontSize: 64)))
                else
                  Center(
                    child: Text(
                      context.l10n.practiceRecallHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.body,
                          color: context.palette.muted),
                    ),
                  ),
              ],
            ],
          ),
        ),
      );

  List<Widget> _gradeButtons(SavedWordCard card) {
    final SavedWordsController ctrl =
        ref.read(savedWordsControllerProvider.notifier);
    Widget btn(FsrsRating r, String label, RatelButtonVariant v) => RatelButton(
          label: context.l10n
              .practiceGradeInterval(label, ctrl.projectedIntervalDays(card, r)),
          variant: v,
          onPressed: () => _grade(r),
        );
    return <Widget>[
      Row(
        children: <Widget>[
          Expanded(
              child:
                  btn(FsrsRating.again, context.l10n.practiceGradeAgain,
                      RatelButtonVariant.danger)),
          const SizedBox(width: RatelSpace.sm),
          Expanded(
              child:
                  btn(FsrsRating.hard, context.l10n.practiceGradeHard,
                      RatelButtonVariant.secondary)),
        ],
      ),
      const SizedBox(height: RatelSpace.sm),
      Row(
        children: <Widget>[
          Expanded(
              child:
                  btn(FsrsRating.good, context.l10n.practiceGradeGood,
                      RatelButtonVariant.primary)),
          const SizedBox(width: RatelSpace.sm),
          Expanded(
              child:
                  btn(FsrsRating.easy, context.l10n.practiceGradeEasy,
                      RatelButtonVariant.success)),
        ],
      ),
      const SizedBox(height: RatelSpace.md),
      Center(
        child: Text(context.l10n.practiceFsrsGradeNote,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.small,
                color: context.palette.muted)),
      ),
    ];
  }

  // ---- Session complete -----------------------------------------------------
  List<Widget> _completeBody() => <Widget>[
        RatelCard(
          gradient: const LinearGradient(
            colors: <Color>[RatelColors.teal, RatelColors.tealDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            children: <Widget>[
              const Text('🎉', style: TextStyle(fontSize: 40)),
              const SizedBox(height: RatelSpace.sm),
              Text(context.l10n.practiceReviewComplete,
                  style: const TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.screenTitle,
                      color: RatelColors.onColor)),
              const SizedBox(height: RatelSpace.sm),
              Text(
                  context.l10n.practiceReviewedSummary(_reviewed),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: RatelColors.onColor)),
            ],
          ),
        ),
        const SizedBox(height: RatelSpace.lg),
        RatelButton(label: context.l10n.practiceDone, onPressed: _endSession),
      ];

  String _relative(Duration d) {
    if (d.inDays >= 1) {
      return d.inDays == 1
          ? context.l10n.practiceRelTomorrow
          : context.l10n.practiceRelInDays(d.inDays);
    }
    if (d.inHours >= 1) {
      return context.l10n.practiceRelInHours(d.inHours);
    }
    if (d.inMinutes >= 1) {
      return context.l10n.practiceRelInMinutes(d.inMinutes);
    }
    return context.l10n.practiceRelSoon;
  }
}
