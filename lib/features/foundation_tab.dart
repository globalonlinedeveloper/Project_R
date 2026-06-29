import 'package:flutter/material.dart';

import 'package:ratel/core/core.dart';

/// A P1-foundation placeholder for a tab screen: the real [RatelTopBar] chrome
/// + the screen title + an honest note. The P2 screen agents replace the body
/// with the real design — this proves the shell + nav + controller wiring
/// end-to-end without faking screen content.
class FoundationTab extends StatelessWidget {
  const FoundationTab({
    super.key,
    required this.title,
    this.topBar,
    this.note,
  });

  final String title;
  final Widget? topBar;
  final Widget? note;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ?topBar,
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(RatelSpace.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('🦡', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: RatelSpace.md),
                    Text(title, style: t.headlineMedium, textAlign: TextAlign.center),
                    if (note != null) ...<Widget>[
                      const SizedBox(height: RatelSpace.sm),
                      DefaultTextStyle.merge(
                        textAlign: TextAlign.center,
                        style: t.bodySmall ?? const TextStyle(),
                        child: note!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
