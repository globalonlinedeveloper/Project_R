import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// RATEL entrypoint — minimal boot during the Session 35 UI reset.
///
/// The full front end (design system + every screen + the auth/settings/Supabase
/// wiring) was removed in the S35 teardown so each screen can be rebuilt from
/// the owner's Claude designs. The backend engines survive untouched in
/// `lib/services/**` and `lib/content/**` (and in git history) and will be wired
/// back in as the new screens land. The live site shows the placeholder below
/// while that rebuild is in progress.
void main() {
  runApp(const ProviderScope(child: RatelApp()));
}

/// Placeholder app shell shown while the UI is rebuilt. A bare Material app with
/// a single "rebuilding" scaffold — no routing, no design system, no backend
/// wiring yet (intentionally minimal so `main` always boots and deploys).
class RatelApp extends StatelessWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFEF9F27),
        brightness: Brightness.light,
      ),
      home: const _RebuildingScaffold(),
    );
  }
}

class _RebuildingScaffold extends StatelessWidget {
  const _RebuildingScaffold();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Ratel',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "We're rebuilding the experience.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Check back soon.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
