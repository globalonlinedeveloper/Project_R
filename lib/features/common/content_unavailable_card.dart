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
              'Content unavailable',
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
              'This $noun is not available right now. If you are '
              'offline, check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.body,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
              label: 'Go back',
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
