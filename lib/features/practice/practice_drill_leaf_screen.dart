import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';

/// Which honest Practice-hub drill leaf to render. Each drill on the hub whose
/// exercise has NO real backend yet routes here (INC-3 / AUDIT P-2·P-3·P-4)
/// instead of a faked exercise: an honest empty state keyed off REAL practice
/// history, plus a plain go-live note. NEVER shows an invented exercise or a
/// fabricated count.
enum PracticeDrill { mistakes, weak, listening, speaking, writing, smart }

/// Honest "coming / empty" leaf for a Practice-hub drill with no engine yet.
///
/// HONEST (§6 "don't fake depth"): these drills (mistakes review, weak words,
/// listening, speaking, guided writing, and the Smart-review adaptive mix) have
/// no dedicated exercise wired in this build. Rather than fabricate one, the hub
/// routes here to a real empty state — it draws its framing from the learner's
/// genuine practice history and states plainly that nothing is pre-filled. The
/// only adaptive queue that is real today (the FSRS due list) lives under
/// "My Words"; this leaf points there when relevant.
class PracticeDrillLeafScreen extends StatelessWidget {
  const PracticeDrillLeafScreen({super.key, required this.drill});

  final PracticeDrill drill;

  ({String title, String emoji, Color tint}) _meta(BuildContext context) {
    switch (drill) {
      case PracticeDrill.mistakes:
        return (
          title: context.l10n.practiceDrillMistakesTitle,
          emoji: '📝',
          tint: RatelColors.coral,
        );
      case PracticeDrill.weak:
        return (
          title: context.l10n.practiceDrillWeakTitle,
          emoji: '🧠',
          tint: RatelColors.purple,
        );
      case PracticeDrill.listening:
        return (
          title: context.l10n.practiceDrillListeningTitle,
          emoji: '🎧',
          tint: RatelColors.blue,
        );
      case PracticeDrill.speaking:
        return (
          title: context.l10n.practiceDrillSpeakingTitle,
          emoji: '🎤',
          tint: RatelColors.green,
        );
      case PracticeDrill.writing:
        return (
          title: context.l10n.practiceDrillWritingTitle,
          emoji: '✍️',
          tint: RatelColors.amber,
        );
      case PracticeDrill.smart:
        return (
          title: context.l10n.practiceSmartReviewTitle,
          emoji: '⚡',
          tint: RatelColors.teal,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ({String title, String emoji, Color tint}) m = _meta(context);
    // The Smart-review leaf names its ONE real backing queue (FSRS due) so the
    // honesty note is accurate; the other drills have no live queue at all.
    final bool isSmart = drill == PracticeDrill.smart;
    final String body = isSmart
        ? context.l10n.practiceSmartReviewEmpty
        : context.l10n.practiceDrillEmptyBody(m.title.toLowerCase());

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
          m.title,
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
          key: const ValueKey<String>('screen-practice-drill'),
          padding: const EdgeInsets.fromLTRB(
              RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            RatelCard(
              color: context.palette.cream2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: m.tint.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Text(m.emoji, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: RatelSpace.md),
                      Expanded(
                        child: Text(
                          context.l10n.practiceDrillEmptyTitle,
                          style: TextStyle(
                              fontFamily: RatelFont.display,
                              fontWeight: RatelType.extraBold,
                              fontSize: RatelType.cardTitle,
                              color: context.palette.ink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpace.md),
                  Text(
                    body,
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
            if (isSmart)
              RatelButton(
                label: context.l10n.practiceDrillMyWordsTitle,
                onPressed: () => context.push('/my-words'),
              )
            else
              RatelButton(
                label: context.l10n.practiceStartLesson,
                onPressed: () => context.push('/daily-quiz'),
              ),
            const SizedBox(height: RatelSpace.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RatelSpace.sm),
              child: Text(
                context.l10n.practiceDrillComingNote(m.title.toLowerCase()),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted,
                    height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
