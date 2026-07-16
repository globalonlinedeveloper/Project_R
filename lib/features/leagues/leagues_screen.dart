import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/leagues/leagues_controller.dart';
import 'package:ratel/features/home/diamonds_sheet.dart';
import 'package:ratel/features/home/economy_glyph.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';
import 'package:ratel/services/leagues/leagues.dart';

/// Leagues tab (🏆) — design spec §4.3, now backed by the REAL [LeaguesEngine]
/// ([R-I6]): a weekly tiered leaderboard with promotion / demotion zones, ranked
/// by the learner's REAL weekly XP. Honesty (charter "don't fake depth"): the
/// cohort is the signed-in learner ALONE — one real row, real weekly XP — with an
/// explicit note that real rivals appear as Ratel grows. We NEVER render a
/// fabricated leaderboard. The current tier is the entry tier (Bronze) until the
/// scheduled weekly cohort-close (go-live wiring) promotes you.
class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final LeagueStatus status = ref.watch(leagueStatusProvider);
    final int unread = ref.watch(unreadNotificationsCountProvider);
    final CourseSpine spine = ref.watch(courseSpineProvider);
    final RatelPalette p = context.palette;

    return Container(
      key: const ValueKey<String>('tab-leagues'),
      color: p.cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // R-L11 inbox surface: the top-bar bell + unread badge open the
            // in-app notifications feed (a real, learner-derived count).
            RatelTopBar(
              flagEmoji: courseFlagEmoji(spine.courseCode),
              langCode: courseLangCode(spine.courseCode),
              streak: snap.streakDays,
              energy: snap.energy,
              diamonds: formatCount(snap.diamonds),
              streakFreeze: snap.streakFreezes > 0 ? snap.streakFreezes : null,
              unreadNotifications: unread,
              onDiamondsTap: () => showDiamondsSheet(context, snap.diamonds),
              onNotificationsTap: () => context.push('/notifications'),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(leaguesSyncProvider.notifier).refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    RatelSpace.screen,
                    RatelSpace.lg,
                    RatelSpace.screen,
                    RatelSpace.xl,
                  ),
                  children: <Widget>[
                    _TierHeaderCard(status: status),
                    const SizedBox(height: RatelSpace.cardGap),
                    _StatusCard(status: status),
                    const SizedBox(height: RatelSpace.lg),
                    RatelSectionHeader(
                      label: status.isSolo
                          ? context.l10n.leaguesYourGroup
                          : context.l10n.leaguesThisWeek(status.cohortSize),
                    ),
                    const SizedBox(height: RatelSpace.sm),
                    ..._standings(status),
                    if (status.isSolo) ...<Widget>[
                      const SizedBox(height: RatelSpace.xs),
                      const _SoloNote(),
                    ],
                    const SizedBox(height: RatelSpace.lg),
                    _RulesFootnote(status: status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The ten-tier accent colours (raw hex lives only in tokens; this maps the
/// pure-engine [LeagueTier] onto those tokens).
Color _tierColor(LeagueTier t) => switch (t) {
  LeagueTier.bronze => RatelColors.tierBronze,
  LeagueTier.silver => RatelColors.tierSilver,
  LeagueTier.gold => RatelColors.tierGold,
  LeagueTier.sapphire => RatelColors.tierSapphire,
  LeagueTier.ruby => RatelColors.tierRuby,
  LeagueTier.emerald => RatelColors.tierEmerald,
  LeagueTier.amethyst => RatelColors.tierAmethyst,
  LeagueTier.pearl => RatelColors.tierPearl,
  LeagueTier.obsidian => RatelColors.tierObsidian,
  LeagueTier.diamond => RatelColors.tierDiamond,
};

/// Ranked rows with promotion/demotion zone dividers at the real boundaries
/// (none show for a solo cohort — everyone is in the promotion zone).
List<Widget> _standings(LeagueStatus status) {
  final List<LeagueStanding> s = status.standings;
  final List<Widget> out = <Widget>[];
  for (int i = 0; i < s.length; i++) {
    final LeagueStanding cur = s[i];
    final LeagueStanding? prev = i > 0 ? s[i - 1] : null;
    if (cur.isDemotion && (prev == null || !prev.isDemotion)) {
      out.add(const _ZoneDivider(promotion: false));
    }
    out.add(_StandingRow(standing: cur));
    final LeagueStanding? next = i + 1 < s.length ? s[i + 1] : null;
    if (cur.isPromotion && next != null && !next.isPromotion) {
      out.add(const _ZoneDivider(promotion: true));
    }
  }
  return out;
}

void _showTierLadder(BuildContext context, LeagueTier current) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.palette.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RatelRadius.featureLg),
      ),
    ),
    builder: (BuildContext context) {
      final RatelPalette p = context.palette;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            RatelSpace.screen,
            0,
            RatelSpace.screen,
            RatelSpace.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  context.l10n.leaguesTiers,
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.cardTitle,
                    color: p.ink,
                  ),
                ),
              ),
              Text(
                context.l10n.leaguesYoureIn(ratelLeagueTierName(context, current.label)),
                style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: p.muted,
                ),
              ),
              const SizedBox(height: RatelSpace.md),
              for (final LeagueTier t in LeaguesEngine.ladder.reversed)
                _LadderRow(tier: t, here: t == current),
            ],
          ),
        ),
      );
    },
  );
}

class _TierHeaderCard extends StatelessWidget {
  const _TierHeaderCard({required this.status});
  final LeagueStatus status;

  @override
  Widget build(BuildContext context) {
    final RatelPalette p = context.palette;
    final LeagueTier tier = status.tier;
    final Color tc = _tierColor(tier);
    final int days = status.daysRemaining;
    return RatelCard(
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tc.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(tier.emoji, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(height: RatelSpace.sm),
          Text(
            context.l10n.leaguesTierLeague(ratelLeagueTierName(context, tier.label)),
            style: TextStyle(
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              fontSize: RatelType.screenTitle,
              color: p.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.leaguesTopClimb(status.rules.promoteTop, days),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.small,
              color: p.muted,
            ),
          ),
          const SizedBox(height: RatelSpace.md),
          _TierLadderPill(onTap: () => _showTierLadder(context, tier)),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});
  final LeagueStatus status;

  @override
  Widget build(BuildContext context) {
    final RatelPalette p = context.palette;
    final LeagueStanding you = status.you;
    final Color zoneColor = you.isDemotion
        ? RatelColors.coral
        : you.isPromotion
        ? RatelColors.green
        : p.muted;
    final String zoneLabel = you.isDemotion
        ? context.l10n.leaguesDemotionZone
        : you.isPromotion
        ? context.l10n.leaguesPromotionZone
        : context.l10n.leaguesSafeZone;
    return RatelCard(
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '#${you.rank}',
                style: TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: RatelType.extraBold,
                  fontSize: RatelType.hero,
                  color: p.ink,
                ),
              ),
              Text(
                zoneLabel,
                style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontWeight: RatelType.semiBold,
                  fontSize: RatelType.small,
                  color: zoneColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: RatelSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${you.member.weeklyXp} XP',
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.cardTitle,
                    color: p.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status.isSolo
                      ? context.l10n.leaguesSoloCaption
                      : status.xpToRankAbove > 0
                      ? context.l10n.leaguesXpToRank(
                          status.xpToRankAbove, you.rank - 1)
                      : context.l10n.leaguesLeading,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: p.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.standing});
  final LeagueStanding standing;

  @override
  Widget build(BuildContext context) {
    final RatelPalette p = context.palette;
    final LeagueMember m = standing.member;
    final bool you = m.isYou;
    final bool medal = standing.rank <= 3;
    final String rankLabel = switch (standing.rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '${standing.rank}',
    };
    return Container(
      margin: const EdgeInsets.only(bottom: RatelSpace.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpace.md,
        vertical: RatelSpace.md,
      ),
      decoration: BoxDecoration(
        color: you ? RatelColors.teal.withValues(alpha: 0.12) : p.white,
        borderRadius: BorderRadius.circular(RatelRadius.card),
        border: Border.all(
          color: you ? RatelColors.teal : p.border,
          width: you ? 2 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 28,
            child: Text(
              rankLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: medal ? RatelFont.body : RatelFont.display,
                fontWeight: RatelType.semiBold,
                fontSize: medal ? 18 : RatelType.body,
                color: p.muted,
              ),
            ),
          ),
          const SizedBox(width: RatelSpace.sm),
          _medallion(context, m.avatarEmoji, standing.rank, you),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Text(
              you
                  ? context.l10n.leaguesYou
                  : (m.displayName.trim().isEmpty
                      ? context.l10n.profileLearner
                      : m.displayName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: you ? RatelType.extraBold : RatelType.semiBold,
                fontSize: RatelType.body,
                color: p.ink,
              ),
            ),
          ),
          const SizedBox(width: RatelSpace.sm),
          Text(
            '${m.weeklyXp} XP',
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontWeight: RatelType.semiBold,
              fontSize: RatelType.small,
              color: p.muted,
            ),
          ),
        ],
      ),
    );
  }

  /// The design's colored avatar MEDALLION (D-L5, design #31/#32): the
  /// learner's avatar emoji centred in a soft-tinted circle wrapped by a
  /// colored ring. The ring tint is DERIVED from real standing state — the
  /// signed-in learner ("you") reads teal (matching the You-row highlight),
  /// the podium ranks read the league tier-badge gold/silver/bronze tokens,
  /// and everyone else reads a stable teal accent. Tokens only (no raw hex).
  Widget _medallion(BuildContext context, String emoji, int rank, bool you) {
    final Color ring = you
        ? RatelColors.teal
        : switch (rank) {
            1 => RatelColors.tierGold,
            2 => RatelColors.tierSilver,
            3 => RatelColors.tierBronze,
            _ => RatelColors.teal,
          };
    return Container(
      key: const ValueKey<String>('league-medallion'),
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ring.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _ZoneDivider extends StatelessWidget {
  const _ZoneDivider({required this.promotion});
  final bool promotion;

  @override
  Widget build(BuildContext context) {
    final Color c = promotion ? RatelColors.green : RatelColors.coral;
    final String label = promotion
        ? context.l10n.leaguesZonePromotion
        : context.l10n.leaguesZoneDemotion;
    return Padding(
      padding: const EdgeInsets.only(bottom: RatelSpace.sm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(height: 1.5, color: c.withValues(alpha: 0.5)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RatelSpace.sm),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.caption,
                color: c,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Container(height: 1.5, color: c.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _SoloNote extends StatelessWidget {
  const _SoloNote();

  @override
  Widget build(BuildContext context) {
    final RatelPalette p = context.palette;
    return RatelCard(
      color: RatelColors.teal.withValues(alpha: 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('🦡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Text(
              context.l10n.leaguesSoloNote,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.small,
                color: p.muted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesFootnote extends StatelessWidget {
  const _RulesFootnote({required this.status});
  final LeagueStatus status;

  @override
  Widget build(BuildContext context) {
    final RatelPalette p = context.palette;
    return Text(
      context.l10n.leaguesPromoteRelegate(
          status.rules.promoteTop, status.rules.demoteBottom),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: RatelFont.body,
        fontSize: RatelType.caption,
        color: p.muted,
      ),
    );
  }
}

class _LadderRow extends StatelessWidget {
  const _LadderRow({required this.tier, required this.here});
  final LeagueTier tier;
  final bool here;

  @override
  Widget build(BuildContext context) {
    final RatelPalette p = context.palette;
    final Color tc = _tierColor(tier);
    return Container(
      margin: const EdgeInsets.only(bottom: RatelSpace.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpace.md,
        vertical: RatelSpace.md,
      ),
      decoration: BoxDecoration(
        color: here ? tc.withValues(alpha: 0.13) : p.white,
        borderRadius: BorderRadius.circular(RatelRadius.card),
        border: Border.all(color: here ? tc : p.border, width: here ? 2 : 1),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tc.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(tier.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Text(
              context.l10n.leaguesTierLeague(ratelLeagueTierName(context, tier.label)),
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.semiBold,
                fontSize: RatelType.body,
                color: p.ink,
              ),
            ),
          ),
          if (here)
            RatelChip(
              label: context.l10n.leaguesYouAreHere,
              tone: RatelChipTone.teal,
              filled: true,
            ),
        ],
      ),
    );
  }
}


/// D-9 — the "View all 10 tiers" affordance as a soft teal-tinted tappable pill
/// (design_spec/shots/Leagues_full.png shows a tonal pill + chevron, not a bare
/// secondary text link). Token-only tint (RatelColors.teal α0.14, pill radius).
class _TierLadderPill extends StatelessWidget {
  const _TierLadderPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RatelRadius.pill),
        child: Container(
          key: const ValueKey<String>('leagues-tier-pill'),
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.lg, vertical: RatelSpace.sm),
          decoration: BoxDecoration(
            color: RatelColors.teal.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(RatelRadius.pill),
          ),
          child: Text(
            context.l10n.leaguesViewAllTiers,
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontWeight: RatelType.semiBold,
              fontSize: RatelType.small,
              color: RatelColors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
