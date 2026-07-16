import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';

/// Practice hub (🎯) — design spec #9/#10, reached from the Library "Practice
/// hub" row (`/practice`). The skill-strength + drills landing: an "always free"
/// header, a SKILL STRENGTH panel, a 3-stat row, seven drill rows, and the
/// "⚡ Smart review" adaptive CTA. Rebuilt in INC-3 (the old `/practice` was the
/// saved-words FSRS review, now DEMOTED to the "My Words" drill leaf at
/// `/my-words` — the engine is unchanged, just re-routed).
///
/// HONESTY (§6 / AUDIT P-2·P-3·P-4 — "don't fake depth"): every tile is wired to
/// a REAL source or honestly stubbed, never fabricated.
///   * Words learned  = the REAL per-course saved-words count (R-G9 intake).
///   * This week XP    = the REAL league-week XP (snapshot `xpWeekEarned`).
///   * Accuracy        = the REAL cumulative graded accuracy (StudyStats); shown
///                       as "—" until the learner has genuinely graded answers.
///   * Skill strength  = NO per-skill mastery engine exists → an honest empty
///                       note, NOT invented Vocab/Listening/Grammar/Speaking %s.
///   * Mistakes / Weak / Listening / Speaking / Guided-writing drills = no
///                       dedicated backend → each routes to an honest empty leaf
///                       ([PracticeDrillLeafScreen]), never a faked exercise.
///   * Roleplay drill  = the REAL `/roleplay` scenario list.
///   * My Words        = the REAL FSRS saved-words review (`/my-words`).
///   * Smart review    = the adaptive mix; its one real backing queue (FSRS due)
///                       lives under My Words, which the leaf points to.
class PracticeHubScreen extends ConsumerWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int wordsLearned = ref.watch(savedWordsControllerProvider).count;
    final int weekXp = ref.watch(learnerControllerProvider).xpWeekEarned;
    final StudyStats stats = ref.watch(studyStatsControllerProvider);
    final double? accuracy = stats.accuracy;

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
          context.l10n.practiceTitle,
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
          key: const ValueKey<String>('screen-practice'),
          padding: const EdgeInsets.fromLTRB(
              RatelSpace.screen, RatelSpace.sm, RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            Text(
              context.l10n.practiceSubtitle,
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted),
            ),
            const SizedBox(height: RatelSpace.lg),
            _skillStrengthPanel(context, wordsLearned, weekXp, accuracy),
            const SizedBox(height: RatelSpace.lg),
            ..._drillRows(context),
            const SizedBox(height: RatelSpace.md),
            _smartReviewCta(context),
          ],
        ),
      ),
    );
  }

  // ---- SKILL STRENGTH panel + the 3-stat row --------------------------------
  Widget _skillStrengthPanel(
      BuildContext context, int wordsLearned, int weekXp, double? accuracy) {
    return RatelCard(
      key: const ValueKey<String>('practice-skill-strength'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RatelSectionHeader(label: context.l10n.practiceSkillStrength),
          const SizedBox(height: RatelSpace.md),
          // No per-skill mastery engine exists (AUDIT P-2) → an HONEST empty
          // note in place of fabricated Vocab/Listening/Grammar/Speaking bars.
          Text(
            context.l10n.practiceSkillNoData,
            key: const ValueKey<String>('practice-skill-nodata'),
            style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.small,
                color: context.palette.muted,
                height: 1.4),
          ),
          const SizedBox(height: RatelSpace.md),
          Divider(color: context.palette.border, height: 1),
          const SizedBox(height: RatelSpace.md),
          Row(
            children: <Widget>[
              _stat(context, '$wordsLearned',
                  context.l10n.practiceStatWordsLearned),
              _stat(context, '$weekXp', context.l10n.practiceStatThisWeek),
              // Accuracy is REAL (StudyStats) but honestly "—" until graded.
              _stat(
                context,
                accuracy == null
                    ? context.l10n.practiceStatEmptyValue
                    : '${(accuracy * 100).round()}%',
                context.l10n.practiceStatAccuracy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) => Expanded(
        child: Column(
          children: <Widget>[
            Text(value,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.screenTitle,
                    color: context.palette.ink)),
            const SizedBox(height: RatelSpace.xs),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.caption,
                    color: context.palette.muted)),
          ],
        ),
      );

  // ---- The 7 drill rows -----------------------------------------------------
  List<Widget> _drillRows(BuildContext context) => <Widget>[
        _drill(
          context,
          keyId: 'practice-drill-mistakes',
          emoji: '📝',
          tint: RatelColors.coral,
          title: context.l10n.practiceDrillMistakesTitle,
          subtitle: context.l10n.practiceDrillMistakesSub,
          onTap: () => context.push('/practice-drill', extra: 'mistakes'),
        ),
        _drill(
          context,
          keyId: 'practice-drill-weak',
          emoji: '🧠',
          tint: RatelColors.purple,
          title: context.l10n.practiceDrillWeakTitle,
          subtitle: context.l10n.practiceDrillWeakSub,
          onTap: () => context.push('/practice-drill', extra: 'weak'),
        ),
        _drill(
          context,
          keyId: 'practice-drill-listening',
          emoji: '🎧',
          tint: RatelColors.blue,
          title: context.l10n.practiceDrillListeningTitle,
          subtitle: context.l10n.practiceDrillListeningSub,
          onTap: () => context.push('/practice-drill', extra: 'listening'),
        ),
        _drill(
          context,
          keyId: 'practice-drill-speaking',
          emoji: '🎤',
          tint: RatelColors.green,
          title: context.l10n.practiceDrillSpeakingTitle,
          subtitle: context.l10n.practiceDrillSpeakingSub,
          onTap: () => context.push('/practice-drill', extra: 'speaking'),
        ),
        _drill(
          context,
          keyId: 'practice-drill-roleplay',
          emoji: '💬',
          tint: RatelColors.navy,
          title: context.l10n.practiceDrillRoleplayTitle,
          subtitle: context.l10n.practiceDrillRoleplaySub,
          onTap: () => context.push('/roleplay'),
        ),
        _drill(
          context,
          keyId: 'practice-drill-mywords',
          emoji: '📖',
          tint: RatelColors.purple,
          title: context.l10n.practiceDrillMyWordsTitle,
          subtitle: context.l10n.practiceDrillMyWordsSub,
          onTap: () => context.push('/my-words'),
        ),
        _drill(
          context,
          keyId: 'practice-drill-writing',
          emoji: '✍️',
          tint: RatelColors.amber,
          title: context.l10n.practiceDrillWritingTitle,
          subtitle: context.l10n.practiceDrillWritingSub,
          onTap: () => context.push('/practice-drill', extra: 'writing'),
        ),
      ];

  Widget _drill(
    BuildContext context, {
    required String keyId,
    required String emoji,
    required Color tint,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: RatelSpace.sm),
        child: RatelCard(
          key: ValueKey<String>(keyId),
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.md, vertical: RatelSpace.xs),
          child: RatelListRow(
            leadingEmoji: emoji,
            leadingColor: tint,
            title: title,
            subtitle: subtitle,
            onTap: onTap,
          ),
        ),
      );

  // ---- ⚡ Smart review CTA ---------------------------------------------------
  Widget _smartReviewCta(BuildContext context) => RatelCard(
        key: const ValueKey<String>('practice-smart-review'),
        gradient: const LinearGradient(
          colors: <Color>[RatelColors.teal, RatelColors.tealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => context.push('/practice-drill', extra: 'smart'),
        child: Column(
          children: <Widget>[
            const Text('⚡', style: TextStyle(fontSize: 28)),
            const SizedBox(height: RatelSpace.xs),
            Text(
              context.l10n.practiceSmartReviewTitle,
              style: const TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: RatelType.extraBold,
                  fontSize: RatelType.cardTitle,
                  color: RatelColors.onColor),
            ),
            const SizedBox(height: RatelSpace.xs),
            Text(
              context.l10n.practiceSmartReviewSub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: RatelColors.onColor),
            ),
          ],
        ),
      );
}
