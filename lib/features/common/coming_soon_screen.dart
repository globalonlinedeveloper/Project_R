import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';

/// An HONEST placeholder for a destination whose backend does not exist yet
/// (design spec §6 owner-decisions: diamonds/Shop, leagues, quests, friends,
/// achievements, notifications, …) OR a real screen not yet built. It NEVER
/// shows fabricated data — it states plainly that the feature is coming and why,
/// honouring the charter "don't fake depth".
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.emoji,
    required this.blurb,
  });

  final String title;
  final String emoji;
  final String blurb;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: RatelSpace.lg),
              const RatelChip(
                label: 'Coming soon',
                tone: RatelChipTone.amber,
                filled: true,
              ),
              const SizedBox(height: RatelSpace.md),
              Text(
                blurb,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: RatelFont.body,
                  color: context.palette.muted,
                  fontSize: RatelType.bodyLg,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
