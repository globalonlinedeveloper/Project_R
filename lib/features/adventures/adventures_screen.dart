import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import 'adventure_model.dart';

/// Adventures map (R-L4a): themed districts as cards with programmatic
/// (token-driven) art. Tapping a district enters its scripted scene. Real art
/// + content are owner-authored later; this is a working placeholder.
class AdventuresScreen extends StatelessWidget {
  const AdventuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return RatelScreen(
      title: 'Adventures',
      child: ListView(
        key: const Key('adventures-screen'),
        children: [
          const SizedBox(height: RatelSpacing.sm),
          Text('Explore real-world scenes', style: RatelType.headline),
          const SizedBox(height: RatelSpacing.xs),
          Text(
            'Practice speaking through short, scripted role-plays.',
            style: RatelType.body.copyWith(color: t.onSurfaceVariant),
          ),
          const SizedBox(height: RatelSpacing.lg),
          for (final a in adventuresCatalog) ...[
            _DistrictCard(
              adventure: a,
              onTap: () => context.push('/scene/${a.firstScene.id}'),
            ),
            const SizedBox(height: RatelSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _DistrictCard extends StatelessWidget {
  const _DistrictCard({required this.adventure, required this.onTap});
  final Adventure adventure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cafe = adventure.kind == DistrictKind.cafe;
    final band = cafe ? t.primary : t.accent;
    final onBand = cafe ? t.onPrimary : t.onAccent;
    final icon = cafe ? Icons.local_cafe_rounded : Icons.storefront_rounded;
    return RatelCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: band,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(RatelSpacing.radiusLg)),
            ),
            child: Center(child: Icon(icon, size: 44, color: onBand)),
          ),
          Padding(
            padding: const EdgeInsets.all(RatelSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(adventure.title, style: RatelType.title),
                const SizedBox(height: RatelSpacing.xs),
                Text(adventure.subtitle,
                    style: RatelType.body.copyWith(color: t.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
