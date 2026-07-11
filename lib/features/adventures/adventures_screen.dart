import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/adventures/adventure_progress_controller.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Adventures (🗺️, INF-8) -- the FREE branching-dialogue library, rendered as
/// the design 4.12 DISTRICT cards (L-4, screen-review B-10): each CEFR band is
/// a district (the owner-confirmed honest grouping over real authored content,
/// S131 -- the mock's named districts were sample data) with the design card
/// grammar: gradient tinted header, `n/m explored` progress, ✓ Done pill,
/// current-district mascot, and per-scene ✓/▶ explored states off the
/// device-local [AdventureProgressController]. Rows open the branching
/// [AdventurePlayerScreen]. Pure authored content (choose-your-path, no
/// wrong answers) -- NO live AI, no fabricated conversation. A course with none
/// yet shows an HONEST empty state. [R-D10 - R-B3 - R-J1]
class AdventuresScreen extends ConsumerWidget {
  const AdventuresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CourseScenario> items =
        ref.watch(courseSpineProvider).adventures;
    final Set<String> explored =
        ref.watch(adventureProgressControllerProvider);
    final Map<String, CourseScenario> byId = <String, CourseScenario>{
      for (final CourseScenario s in items) s.id: s,
    };
    final List<AdventureDistrict> districts =
        const AdventureExplorationEngine().districts(
      <AdventureRef>[
        for (final CourseScenario s in items)
          AdventureRef(id: s.id, band: s.cefr),
      ],
      explored,
    );

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
        title: Text(context.l10n.adventuresTitle,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: RatelSpace.lg),
            child: Center(
                child: RatelChip(
                    label: context.l10n.adventuresFreeChip,
                    tone: RatelChipTone.green)),
          ),
        ],
      ),
      body: items.isEmpty
          ? _empty(context)
          : ListView(
              key: const ValueKey<String>('screen-adventures'),
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              children: <Widget>[
                Text(
                  context.l10n.adventuresIntro,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: context.palette.muted),
                ),
                const SizedBox(height: RatelSpace.lg),
                for (final AdventureDistrict d in districts) ...<Widget>[
                  _districtCard(context, d, byId, explored),
                  const SizedBox(height: RatelSpace.lg),
                ],
              ],
            ),
    );
  }

  /// One district card (design 4.12): gradient band header (emoji · band
  /// name · `n/m explored`) + the design's current-district mascot / ✓ Done
  /// pill, over the district's scene tiles. Tints for the first four bands
  /// are the design's own district pairs; C1/C2 derive from the design accent
  /// set with the same darken treatment (noted S131). The mascot is STATIC —
  /// no looping animation (reduce-motion floor + the 11 pumpAndSettle trap).
  Widget _districtCard(BuildContext context, AdventureDistrict d,
      Map<String, CourseScenario> byId, Set<String> explored) {
    final _DistrictStyle style = _kDistrictStyles[d.band] ??
        const _DistrictStyle(
            '🗺️', RatelColors.blue, RatelColors.districtMoveDark, null);
    final String name = style.englishName == null
        ? d.band
        : '${d.band} · ${ratelCefrLevelDisplayName(context, style.englishName!)}';
    return Container(
      key: ValueKey<String>('adventure-district-${d.band}'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.palette.white,
        borderRadius: BorderRadius.circular(RatelRadius.featureLg),
        border: Border.all(color: context.palette.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: RatelSpace.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[style.tint, style.tint2],
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(style.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: RatelSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(name,
                          style: TextStyle(
                              fontFamily: RatelFont.display,
                              fontWeight: RatelType.extraBold,
                              fontSize: 17,
                              color: RatelColors.white)),
                      Text(
                          context.l10n.adventureDistrictProgress(
                              d.doneCount, d.total),
                          key: ValueKey<String>(
                              'adventure-district-progress-${d.band}'),
                          style: TextStyle(
                              fontFamily: RatelFont.body,
                              fontSize: RatelType.caption,
                              fontWeight: RatelType.semiBold,
                              color: RatelColors.white
                                  .withValues(alpha: 0.85))),
                    ],
                  ),
                ),
                if (d.isCurrent)
                  Text('🦡',
                      key: ValueKey<String>(
                          'adventure-district-current-${d.band}'),
                      style: const TextStyle(fontSize: 28)),
                if (d.allDone)
                  Container(
                    key: ValueKey<String>('adventure-district-done-${d.band}'),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: RatelColors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(context.l10n.adventureDistrictDone,
                        style: TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.caption,
                            fontWeight: RatelType.extraBold,
                            color: RatelColors.white)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(RatelSpace.md),
            child: Column(
              children: <Widget>[
                for (final AdventureRef r in d.refs)
                  if (byId[r.id] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: RatelSpace.sm),
                      child: _sceneTile(context, byId[r.id]!, style.tint,
                          explored: explored.contains(r.id)),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// M-3 (screen review §2): the scene-script preview sheet — the SAME sheet
  /// grammar as the Home lesson preview (kicker / title / meta / primary CTA),
  /// filled with the REAL authored opening scene: speaker + line + the actual
  /// branching choices. Pure data off [CourseScenario.scenes]; nothing invented.
  void _showScenePreview(BuildContext context, CourseScenario s) {
    final int decisions =
        s.scenes.where((CourseScene sc) => sc.isDecision).length;
    final CourseScene? opening = s.scenes.isEmpty ? null : s.scenes.first;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(RatelRadius.featureLg))),
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(RatelSpace.xl),
        child: Column(
          key: const ValueKey<String>('adventure-preview-sheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(sheetContext.l10n.adventureSheetKicker(s.cefr),
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.caption,
                    fontWeight: RatelType.semiBold,
                    color: sheetContext.palette.muted)),
            const SizedBox(height: 4),
            Text(s.title,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.screenTitle,
                    color: sheetContext.palette.ink)),
            const SizedBox(height: 4),
            Text(
                '${sheetContext.l10n.adventureScenesCount(s.scenes.length)} · '
                '${sheetContext.l10n.adventureChoicePoints(decisions)}'
                '${s.goal != null && s.goal!.isNotEmpty ? ' · ${s.goal!}' : ''}',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: sheetContext.palette.muted)),
            if (opening != null) ...<Widget>[
              const SizedBox(height: RatelSpace.md),
              Text(sheetContext.l10n.adventureOpeningScene,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.caption,
                      fontWeight: RatelType.semiBold,
                      color: sheetContext.palette.muted)),
              const SizedBox(height: RatelSpace.sm),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    key: const ValueKey<String>('adventure-preview-script'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${opening.speaker}: ${opening.line}',
                          style: TextStyle(
                              fontFamily: RatelFont.body,
                              fontSize: RatelType.body,
                              height: 1.45,
                              color: sheetContext.palette.ink)),
                      for (final CourseChoice ch in opening.choices)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: RatelSpace.sm, left: RatelSpace.md),
                          child: Text('› ${ch.label}',
                              style: TextStyle(
                                  fontFamily: RatelFont.body,
                                  fontSize: RatelType.body,
                                  height: 1.3,
                                  color: sheetContext.palette.muted)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
              key: const ValueKey<String>('adventure-preview-start'),
              label: sheetContext.l10n.adventureStart,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push(
                    '/adventure?scenario=${Uri.encodeComponent(s.id)}');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// One scene tile (design 4.12 row): 42px icon box · title/sub · trailing
  /// status circle — explored = white ✓ on green + tinted border/bg, else ▶
  /// in the district tint. Keeps the M-3 long-press preview + the stable
  /// `adventure-row-{id}` key.
  Widget _sceneTile(BuildContext context, CourseScenario s, Color tint,
      {required bool explored}) {
    final String subtitle = s.goal == null || s.goal!.isEmpty
        ? (s.world ?? context.l10n.adventuresFallbackWorld)
        : s.goal!;
    return Semantics(
      button: true,
      child: GestureDetector(
        key: ValueKey<String>('adventure-row-${s.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            context.push('/adventure?scenario=${Uri.encodeComponent(s.id)}'),
        // M-3: long-press opens the REAL scene-script preview.
        onLongPress: () => _showScenePreview(context, s),
        child: Container(
          padding: const EdgeInsets.all(RatelSpace.md),
          decoration: BoxDecoration(
            color: explored
                ? Color.alphaBlend(
                    tint.withValues(alpha: 0.10), context.palette.cream2)
                : context.palette.cream2,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: explored ? tint : context.palette.border, width: 1.5),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.palette.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🗺️', style: TextStyle(fontSize: 23)),
              ),
              const SizedBox(width: RatelSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.title,
                        style: TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: 15,
                            fontWeight: RatelType.semiBold,
                            color: context.palette.ink),
                        overflow: TextOverflow.ellipsis),
                    Text(subtitle,
                        style: TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.caption,
                            fontWeight: RatelType.semiBold,
                            color: context.palette.muted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: RatelSpace.sm),
              Container(
                key: ValueKey<String>(
                    'adventure-row-status-${s.id}-${explored ? 'done' : 'open'}'),
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: explored
                      ? RatelColors.green
                      : tint.withValues(alpha: 0.16),
                ),
                child: Text(explored ? '✓' : '▶',
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: 12,
                        fontWeight: RatelType.extraBold,
                        color: explored ? RatelColors.white : tint)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.xl),
          child: Column(
            key: const ValueKey<String>('screen-adventures'),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🗺️', style: TextStyle(fontSize: 56)),
              const SizedBox(height: RatelSpace.md),
              Text(context.l10n.adventuresEmpty,
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


/// Per-band district chrome (design 4.12). The first four pairs are the
/// design mock's own district tints byte-exact (Café/Market/Move/Friends);
/// C1/C2 derive from the design accent set (red · deep navy) with the same
/// darken treatment. [englishName] feeds [ratelCefrLevelDisplayName] so the
/// header localizes; an unknown band falls back to the band code + 🗺️.
class _DistrictStyle {
  const _DistrictStyle(this.emoji, this.tint, this.tint2, this.englishName);

  final String emoji;
  final Color tint;
  final Color tint2;
  final String? englishName;
}

const Map<String, _DistrictStyle> _kDistrictStyles = <String, _DistrictStyle>{
  'A1': _DistrictStyle('☕', RatelColors.districtCafe,
      RatelColors.districtCafeDark, 'Beginner'),
  'A2': _DistrictStyle('🛒', RatelColors.green,
      RatelColors.districtMarketDark, 'Elementary'),
  'B1': _DistrictStyle('✈️', RatelColors.blue,
      RatelColors.districtMoveDark, 'Intermediate'),
  'B2': _DistrictStyle('🎉', RatelColors.purple,
      RatelColors.districtFriendsDark, 'Upper intermediate'),
  'C1': _DistrictStyle('🧭', RatelColors.districtRed,
      RatelColors.districtRedDark, 'Advanced'),
  'C2': _DistrictStyle('🏛️', RatelColors.districtNavy,
      RatelColors.districtNavyDark, 'Proficient'),
};
