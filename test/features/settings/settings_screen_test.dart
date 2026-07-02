// Settings "World" row → the full-screen Themes picker (replaces the old
// _pickWorld bottom-sheet). Greenfield: no settings test existed before.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/features/themes/themes_screen.dart';

void main() {
  testWidgets('the Settings "World" row pushes the /themes picker',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GoRouter router = buildRouter();
    await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump();
    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    final Finder worldRow = find.text('World');
    await tester.ensureVisible(worldRow);
    await tester.tap(worldRow);
    await tester.pumpAndSettle();

    expect(find.byType(ThemesScreen), findsOneWidget);
  });
}
