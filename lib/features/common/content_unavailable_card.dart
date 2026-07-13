import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';

/// Q-2 (screen review 2026-07 §2): the honest "content unavailable" surface
/// for the content players (story / podcast / watch). Shown when the opened
/// passage id is not in the loaded course spine — which happens when the
/// content genuinely does not exist OR when the remote content path fell
/// back at boot (offline / CDN unreachable), so the copy names BOTH causes.
/// Deliberately NO spinner: the spine is resolved before the app boots
/// (fail-closed ladder in content_wiring), so nothing is loading here — a
/// spinner would fake progress that cannot arrive.
class ContentUnavailableCard extends StatelessWidget {
  const ContentUnavailableCard({required this.noun, super.key});

  /// 'story' | 'podcast' | 'video' — the player's content noun.
  final String noun;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RatelSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('\u{1F4E1}', style: TextStyle(fontSize: 56)),
            const SizedBox(height: RatelSpace.lg),
            Text(
              context.l10n.contentUnavailableTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.cardTitle,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: RatelSpace.sm),
            Text(
              context.l10n.contentUnavailableBody(ratelContentNoun(context, noun)),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.body,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
              label: context.l10n.commonGoBack,
              variant: RatelButtonVariant.secondary,
              expand: false,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
