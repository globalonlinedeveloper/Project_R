import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme.dart';

/// RATEL entrypoint.
///
/// P1 foundation — increment 1 wires the design-system [RatelTheme]. The
/// go_router 5-tab shell and the lib/services-bridging controllers land in the
/// later foundation increments; `main` stays a themed placeholder deploy until
/// the first real screen (Home) is rebuilt on top of this foundation.
void main() {
  runApp(const ProviderScope(child: RatelApp()));
}

/// Root app — Material 3 with the Ratel theme. Replaced by the routed shell
/// (`MaterialApp.router`) once the navigation increment lands.
class RatelApp extends StatelessWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: RatelTheme.light(),
      home: const _BootScaffold(),
    );
  }
}

class _BootScaffold extends StatelessWidget {
  const _BootScaffold();

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(RatelSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Ratel', style: t.displayLarge),
                const SizedBox(height: RatelSpace.md),
                Text(
                  "We're rebuilding the experience.",
                  textAlign: TextAlign.center,
                  style: t.titleMedium,
                ),
                const SizedBox(height: RatelSpace.xs),
                Text(
                  'Check back soon.',
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: RatelColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
