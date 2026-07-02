import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/preferences/app_settings.dart';

/// Themes picker (design spec §(d)-5 / §(d)-6) — a full-screen 2-column grid of
/// world cards that RESTYLES the whole app live on tap. Replaces the old tiny
/// `_pickWorld` bottom-sheet in Settings; reached from Settings → "World".
///
/// Each card shows the world's `--bg → --bg2` gradient swatch, three palette
/// dots (accent / gold / text), the label + "Vehicle · X", a ✓ when it is the
/// active world and a 🔒 PRO badge when locked. The two free worlds (light,
/// savanna) — and, for a Pro learner, every world — select + persist via
/// [AppSettingsController.setWorldTheme], which re-skins the whole app instantly
/// (a live preview; the screen stays put so more worlds can be tried). A locked
/// Pro world routes to the paywall instead; it NEVER fakes selection of a locked
/// world (mirrors the retired sheet's invariant).
///
/// Every colour resolves to a [RatelColors]/palette or `world.palette` token —
/// no raw literals — so the design-token charter (token_lint_test) stays green.
///
/// Traces R-WT3 (persisted world-theme selection) surfaced over the R-WT1
/// world-theme seam (palette swatch · accent dots · traveller vehicle).
class ThemesScreen extends ConsumerWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeWorld active = ref.watch(activeWorldProvider);
    final bool isPro = ref.watch(isProProvider);

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
        title: Text('Themes',
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
                RatelSpace.screen, 0, RatelSpace.screen, RatelSpace.sm),
            child: Text(
              'Restyles the whole app — tap to preview live',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.xs, RatelSpace.screen, RatelSpace.xl),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: RatelSpace.md,
                mainAxisSpacing: RatelSpace.md,
                // Owner-tunable (design has no Flutter aspect ratio); a golden
                // can lock it later. 0.82 matches the retired sheet's tiles and
                // leaves ample vertical headroom (no overflow).
                childAspectRatio: 0.82,
              ),
              itemCount: kThemeWorlds.length,
              itemBuilder: (BuildContext context, int i) {
                final ThemeWorld w = kThemeWorlds.values.elementAt(i);
                return _ThemeCard(
                  key: ValueKey<String>('theme-card-${w.id}'),
                  world: w,
                  selected: w.id == active.id,
                  locked: !w.isFree && !isPro,
                  onTap: () => _onCardTap(context, ref, w, isPro),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Design VM (`Ratel App.dc.html` L3257): `locked ? go('paywall') :
  /// setTheme(key)`. Live preview is automatic — `setWorldTheme` persists and
  /// re-skins via `activeWorldProvider` in `ratel_app.dart`; no pop, no separate
  /// preview/commit state.
  void _onCardTap(
      BuildContext context, WidgetRef ref, ThemeWorld w, bool isPro) {
    if (!w.isFree && !isPro) {
      context.push('/paywall?source=themes');
      return;
    }
    ref
        .read(appSettingsControllerProvider.notifier)
        .setWorldTheme(WorldTheme.values.byName(w.id));
  }
}

/// One world tile: a `--bg → --bg2` gradient swatch (with the three palette dots
/// + ✓/🔒 badges) over a label + "Vehicle · X" footer. Colours are pure
/// `world.palette` field reads plus [RatelColors] tokens (token-lint safe).
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    super.key,
    required this.world,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final ThemeWorld world;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final WorldPalette p = world.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(RatelRadius.featureLg),
          border: Border.all(
            color: selected ? p.accent : p.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                key: ValueKey<String>('theme-swatch-${world.id}'),
                padding: const EdgeInsets.all(RatelSpace.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[p.bg, p.bg2],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _dot(p.accent, 18),
                          const SizedBox(width: 7),
                          _dot(p.gold, 13),
                          const SizedBox(width: 7),
                          _dot(p.text, 10),
                        ],
                      ),
                    ),
                    if (locked)
                      Align(alignment: Alignment.topLeft, child: _proBadge()),
                    if (selected)
                      Align(alignment: Alignment.topRight, child: _checkBadge()),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  RatelSpace.md, RatelSpace.sm, RatelSpace.md, RatelSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    world.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.small,
                        color: p.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vehicle · ${world.vehicle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontWeight: RatelType.semiBold,
                        fontSize: RatelType.caption,
                        color: p.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _proBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: RatelColors.scrim,
          borderRadius: BorderRadius.circular(RatelRadius.pill),
        ),
        child: const Text('🔒 PRO',
            style: TextStyle(
                color: RatelColors.white,
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: 9,
                letterSpacing: 0.5)),
      );

  Widget _checkBadge() => Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: RatelColors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: RatelColors.shadow, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: const Text('✓',
            style: TextStyle(
                color: RatelColors.teal,
                fontWeight: RatelType.extraBold,
                fontSize: 13)),
      );
}
