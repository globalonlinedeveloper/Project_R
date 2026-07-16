import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/adventures/adventure_progress_controller.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Adventures (🗺️, INF-8) -- the FREE branching-dialogue library, rendered as
/// the design 4.12 DISTRICT cards (L-4, screen-review B-10): the owner's four
/// NAMED districts (Café & Food / Market Square / On the Move / Making Friends,
/// S153 -- supersedes the old S131 "CEFR-band / sample-data" note now that
/// fresh screenshots #29/#30 show the named places) with the design card
/// grammar: gradient tinted header, `n/m explored` progress, ✓ Done pill,
/// current-district mascot, and per-scene ✓/▶ explored states off the
/// device-local [AdventureProgressController]. Adventure content has NO district
/// field -- only `world` free-text -- so the district (and each scene's
/// medallion) is DERIVED deterministically from the real authored signal by
/// [districtOf] / [_medallionOf], the honest derive-don't-fabricate pattern
/// INC-4 used for roleplay categories. Rows open the branching
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
    // Reduce-motion double-floor (toggle + OS), the home_screen expression.
    final bool reduceMotion = MediaQuery.of(context).disableAnimations ||
        ref.watch(reduceMotionProvider);
    final Map<String, CourseScenario> byId = <String, CourseScenario>{
      for (final CourseScenario s in items) s.id: s,
    };
    final List<AdventureDistrict> districts =
        const AdventureExplorationEngine().districts(
      <AdventureRef>[
        for (final CourseScenario s in items)
          AdventureRef(id: s.id, kind: districtOf(s)),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.adventuresTitle,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    color: context.palette.ink,
                    fontSize: RatelType.cardTitle)),
            Text(context.l10n.adventuresHeaderSub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.caption,
                    fontWeight: RatelType.semiBold,
                    color: context.palette.muted)),
          ],
        ),
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
                Container(
                  key: const ValueKey<String>('adventures-hero'),
                  padding: const EdgeInsets.all(RatelSpace.md),
                  decoration: BoxDecoration(
                    color: context.palette.white,
                    borderRadius: BorderRadius.circular(RatelRadius.featureLg),
                    border:
                        Border.all(color: context.palette.border, width: 1.5),
                  ),
                  child: Row(
                    children: <Widget>[
                      _BobbingMascot(
                          size: 42,
                          period: const Duration(milliseconds: 2800),
                          reduceMotion: reduceMotion),
                      const SizedBox(width: RatelSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(context.l10n.adventuresHeroTitle,
                                style: TextStyle(
                                    fontFamily: RatelFont.display,
                                    fontWeight: RatelType.extraBold,
                                    fontSize: 15,
                                    color: context.palette.ink)),
                            Text(context.l10n.adventuresHeroSub,
                                style: TextStyle(
                                    fontFamily: RatelFont.body,
                                    fontSize: 12.5,
                                    fontWeight: RatelType.semiBold,
                                    color: context.palette.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RatelSpace.lg),
                for (final AdventureDistrict d in districts) ...<Widget>[
                  _districtCard(context, d, byId, explored,
                      reduceMotion: reduceMotion),
                  const SizedBox(height: RatelSpace.lg),
                ],
              ],
            ),
    );
  }

  /// One district card (design 4.12): gradient header (district emoji · the
  /// owner's NAMED district name · `n/m explored`) + the design's current-
  /// district mascot / ✓ Done pill, over the district's scene tiles. Each of
  /// the four districts (Café & Food ☕ / Market Square 🛒 / On the Move ✈️ /
  /// Making Friends 🎉) carries the design's own tint pair, keyed by the stable
  /// district id (S153). The current-district mascot bobs (design rbob 2.4s)
  /// via [_BobbingMascot], static under the reduce-motion double-floor.
  Widget _districtCard(BuildContext context, AdventureDistrict d,
      Map<String, CourseScenario> byId, Set<String> explored,
      {required bool reduceMotion}) {
    final _DistrictStyle style = _kDistrictStyles[d.kind] ??
        _kDistrictStyles[AdventureDistrictKind.cafe]!;
    final String name = _districtName(context, d.kind);
    return Container(
      key: ValueKey<String>('adventure-district-${d.id}'),
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
                              'adventure-district-progress-${d.id}'),
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
                  KeyedSubtree(
                    key: ValueKey<String>(
                        'adventure-district-current-${d.id}'),
                    child: _BobbingMascot(
                        size: 28,
                        period: const Duration(milliseconds: 2400),
                        reduceMotion: reduceMotion),
                  ),
                if (d.allDone)
                  Container(
                    key: ValueKey<String>('adventure-district-done-${d.id}'),
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

  /// One scene tile (design 4.12 row): 42px medallion box · title/sub ·
  /// trailing status circle — explored = white ✓ on green + tinted border/bg,
  /// else ▶ in the district tint. The medallion emoji + tint are DERIVED per
  /// scene from its real authored text by [_medallionOf] (design #29/#30 varied
  /// per-scene icons, C-A6) — replacing the old single fixed 🗺️. Keeps the M-3
  /// long-press preview + the stable `adventure-row-{id}` key.
  Widget _sceneTile(BuildContext context, CourseScenario s, Color tint,
      {required bool explored}) {
    final String subtitle = s.goal == null || s.goal!.isEmpty
        ? (s.world ?? context.l10n.adventuresFallbackWorld)
        : s.goal!;
    final ({String emoji, Color tint}) medallion = _medallionOf(s);
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
                  color: medallion.tint.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Text(medallion.emoji, style: const TextStyle(fontSize: 23)),
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
                child: Text(
                    explored
                        ? '✓'
                        // ▶ is a directional pictogram: mirror it in RTL.
                        : (Directionality.of(context) == TextDirection.rtl
                            ? '◀'
                            : '▶'),
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


/// Localized header name for a NAMED district (labels come from ARB — the
/// district name is l10n-driven, never a hard-coded literal). [C-A1]
String _districtName(BuildContext context, AdventureDistrictKind kind) {
  switch (kind) {
    case AdventureDistrictKind.cafe:
      return context.l10n.adventureDistrictCafe;
    case AdventureDistrictKind.market:
      return context.l10n.adventureDistrictMarket;
    case AdventureDistrictKind.move:
      return context.l10n.adventureDistrictMove;
    case AdventureDistrictKind.friends:
      return context.l10n.adventureDistrictFriends;
  }
}

/// Pure, deterministic derivation of a scenario's NAMED district from its real
/// authored text (world + title + goal, lower-cased). Adventure content has no
/// district field, so this is an ORDER-SENSITIVE keyword map (first family that
/// matches wins), NOT a fabricated field or re-authored content — the honest
/// derive-don't-fabricate pattern INC-4 used for roleplay categories. Anything
/// unmatched falls back to [AdventureDistrictKind.cafe] (we keep to the four
/// owner-locked districts and never invent a fifth). [C-A1 · S153 · R-B3]
///
/// Order rationale: **On the Move** is checked before **Café & Food** so a
/// "café at the airport / bus stop café" resolves by the stronger travel
/// signal, while a plain "small café in town" falls through. **Making Friends**
/// is checked ahead of the café default so a neighbourly/greeting scene ("help
/// your neighbour find her lost cat", "your first morning at school") lands
/// socially rather than defaulting.
AdventureDistrictKind districtOf(CourseScenario s) {
  final String hay =
      '${s.world ?? ''} ${s.title} ${s.goal ?? ''}'.toLowerCase();

  bool has(List<String> keys) {
    for (final String k in keys) {
      if (hay.contains(k)) return true;
    }
    return false;
  }

  // On the Move — airport / station / bus / taxi / train / street / city /
  // hotel / trip / travel / directions / platform / apartment / move.
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
    'platform',
    'flight',
    'apartment',
    'moving',
    'weekend trip',
  ])) {
    return AdventureDistrictKind.move;
  }

  // Market Square — market / shop / store / buy / price / grocery / stall /
  // vendor.
  if (has(<String>[
    'market',
    'shop',
    'store',
    'buy',
    'price',
    'grocery',
    'stall',
    'vendor',
  ])) {
    return AdventureDistrictKind.market;
  }

  // Making Friends — friend / party / meet / introduce / neighbour /
  // classmate / greet / hello / invite / social / school.
  if (has(<String>[
    'friend',
    'party',
    'meet',
    'introduce',
    'neighbour',
    'neighbor',
    'classmate',
    'greet',
    'hello',
    'invite',
    'social',
    'school',
  ])) {
    return AdventureDistrictKind.friends;
  }

  // Café & Food — café / coffee / bakery / restaurant / food / order / bill /
  // meal / menu / drink. Also the DEFAULT for anything unmatched.
  return AdventureDistrictKind.cafe;
}

/// Per-scene medallion (emoji + tint) derived deterministically from the same
/// real signal, replacing the single fixed 🗺️ scene icon (design #29/#30 varied
/// per-scene icons, C-A6). Tints are [RatelColors] tokens — no raw hex in
/// features (token_lint). Default keeps 🗺️ so an unmatched scene still reads as
/// an adventure. [C-A6]
({String emoji, Color tint}) _medallionOf(CourseScenario s) {
  final String hay =
      '${s.world ?? ''} ${s.title} ${s.goal ?? ''}'.toLowerCase();

  bool has(List<String> keys) {
    for (final String k in keys) {
      if (hay.contains(k)) return true;
    }
    return false;
  }

  if (has(<String>['receipt', 'bill', 'invoice'])) {
    return (emoji: '🧾', tint: RatelColors.districtCafe);
  }
  if (has(<String>['plane', 'airport', 'flight'])) {
    return (emoji: '✈️', tint: RatelColors.blue);
  }
  if (has(<String>['compass', 'directions', 'map', 'way', 'lost'])) {
    return (emoji: '🧭', tint: RatelColors.blue);
  }
  if (has(<String>['hotel', 'apartment', 'room'])) {
    return (emoji: '🏨', tint: RatelColors.blue);
  }
  if (has(<String>['money', 'pay', 'price', 'cash', 'bill'])) {
    return (emoji: '💰', tint: RatelColors.green);
  }
  if (has(<String>['fruit', 'apple', 'food', 'meal', 'grocery', 'market'])) {
    return (emoji: '🍎', tint: RatelColors.green);
  }
  if (has(<String>['friend', 'greet', 'hello', 'meet', 'introduce',
      'neighbour', 'neighbor', 'party'])) {
    return (emoji: '👋', tint: RatelColors.purple);
  }
  if (has(<String>['café', 'cafe', 'coffee', 'bakery', 'restaurant', 'drink',
      'menu', 'order'])) {
    return (emoji: '☕', tint: RatelColors.districtCafe);
  }
  return (emoji: '🗺️', tint: RatelColors.blue);
}

/// Per-district header chrome (design 4.12). Each of the owner's four NAMED
/// districts carries the design mock's own tint pair, keyed by the stable
/// [AdventureDistrictKind] (S153 — supersedes the old A1…C2 band keying). The
/// header NAME is resolved separately via [_districtName] (l10n-driven).
class _DistrictStyle {
  const _DistrictStyle(this.emoji, this.tint, this.tint2);

  final String emoji;
  final Color tint;
  final Color tint2;
}

const Map<AdventureDistrictKind, _DistrictStyle> _kDistrictStyles =
    <AdventureDistrictKind, _DistrictStyle>{
  AdventureDistrictKind.cafe: _DistrictStyle(
      '☕', RatelColors.districtCafe, RatelColors.districtCafeDark),
  AdventureDistrictKind.market: _DistrictStyle(
      '🛒', RatelColors.green, RatelColors.districtMarketDark),
  AdventureDistrictKind.move: _DistrictStyle(
      '✈️', RatelColors.blue, RatelColors.districtMoveDark),
  AdventureDistrictKind.friends: _DistrictStyle(
      '🎉', RatelColors.purple, RatelColors.districtFriendsDark),
};


/// The design's `rbob` idle bounce for the 🦡 mascot glyph (translateY
/// 0 → -7 → 0, ease-in-out, infinite), mirroring the `PathTraveller`
/// controller lifecycle: no controller is even created under reduce-motion —
/// the emoji renders static (the a11y double-floor, and the §11 harness rule:
/// suites that pumpAndSettle this screen set `reduceMotion: true`).
class _BobbingMascot extends StatefulWidget {
  const _BobbingMascot({
    required this.size,
    required this.period,
    required this.reduceMotion,
  });

  final double size;
  final Duration period;
  final bool reduceMotion;

  @override
  State<_BobbingMascot> createState() => _BobbingMascotState();
}

class _BobbingMascotState extends State<_BobbingMascot>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (!widget.reduceMotion) _start();
  }

  void _start() {
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant _BobbingMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion && _controller != null) {
      _controller!.dispose();
      _controller = null;
    } else if (!widget.reduceMotion && _controller == null) {
      _start();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget glyph =
        Text('🦡', style: TextStyle(fontSize: widget.size));
    final AnimationController? c = _controller;
    if (c == null) return glyph;
    return AnimatedBuilder(
      animation: c,
      builder: (BuildContext context, Widget? child) => Transform.translate(
        // One sine arc per period: 0 at the loop seam (calm), -7 mid-loop.
        offset: Offset(0, -7 * math.sin(math.pi * c.value)),
        child: child,
      ),
      child: glyph,
    );
  }
}
