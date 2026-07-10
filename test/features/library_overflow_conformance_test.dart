// S115-L7 · UXA "Library copy + overflow guards" conformance.
// Ships: B-9 search-hint copy · A-8/A-9 BottomNav label ellipsis · B-11 Adventure
// ending Wrap · D-14/D-15 Friends trailing-cluster narrow-width guard.
// (B-7/B-8 AI-Tutor card copy+fill DEFERRED — owner bundle base-HTML vs scrap
//  b-lib.png conflict = an owner taste/iteration call; see §G AWAITING OWNER.)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/adventures/adventure_player_screen.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

const CourseSpine _emptySpine =
    CourseSpine(courseCode: 'es', units: <CourseUnit>[]);

CourseSpine _advSpine() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      adventures: <CourseScenario>[
        CourseScenario(
          id: 'adv1',
          kind: 'adventure',
          title: 'The market',
          cefr: 'A1',
          scenes: <CourseScene>[
            CourseScene(
                sceneId: 'a1',
                speaker: 'narrator',
                line: 'You reach a fork.',
                choices: <CourseChoice>[
                  CourseChoice(label: 'Go right', nextSceneId: 'a3'),
                ]),
            CourseScene(
                sceneId: 'a3', speaker: 'narrator', line: 'You find a park.'),
          ],
        ),
      ],
    );

Widget _host(Widget child, {double width = 360}) => MaterialApp(
      theme: RatelTheme.light(),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );

void main() {
  // ---- B-9 : search field hint reads "…stories…" (owner bundle b-lib :194) ----
  testWidgets('B-9 search field hint says "stories" not "pages"',
      (WidgetTester tester) async {
    final router = buildRouter();
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_emptySpine),
        settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(const AppSettings(reduceMotion: true))),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    router.go('/search');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final TextField field = tester.widget<TextField>(
        find.byKey(const ValueKey<String>('search-field')));
    expect(field.decoration!.hintText, 'Search lessons, words, stories…');
    expect(field.decoration!.hintText, isNot(contains('pages')));
  });

  // ---- A-8/A-9 : BottomNav labels single-line ellipsized; no overflow @360 ----
  testWidgets('A-9 BottomNav labels are maxLines:1 + ellipsis (no overflow @360)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        _host(RatelBottomNav(currentIndex: 0, onTap: (int i) {}), width: 360));
    await tester.pump();
    expect(tester.takeException(), isNull);
    final Iterable<Text> navLabels = tester
        .widgetList<Text>(find.byType(Text))
        .where((Text t) => (t.style?.fontSize ?? 0) == 10);
    expect(navLabels.length, 5);
    for (final Text t in navLabels) {
      expect(t.maxLines, 1);
      expect(t.overflow, TextOverflow.ellipsis);
    }
  });

  // ---- B-11 : Adventure ending buttons in a Wrap; no overflow @360 ----
  testWidgets('B-11 Adventure ending uses a Wrap with no overflow @360',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_advSpine()),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AdventurePlayerScreen(scenarioId: 'adv1')),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('adventure-choice-0')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey<String>('adventure-ending')), findsOneWidget);
    expect(find.byType(Wrap), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  // ---- D-14/D-15 : Friends-style rows (long name + wide trailing) fit @360.
  //      Mirrors _requestRow (Accept + compact close) & _friendRow (chip +
  //      compact ⋯ menu) trailing clusters after the compaction fix. ----
  testWidgets('D-14/D-15 friends-style trailing clusters fit @360',
      (WidgetTester tester) async {
    final Widget requestRow = RatelListRow(
      leadingEmoji: '🦊',
      title: 'Maximiliana Featherstonehaugh-Wellington',
      subtitle: '@maximiliana_featherstonehaugh',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        SizedBox(
            width: 92,
            child: RatelButton(
                label: 'Accept',
                variant: RatelButtonVariant.success,
                expand: false,
                onPressed: () {})),
        const SizedBox(width: RatelSpace.xs),
        IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: const Icon(RatelIcons.close),
            onPressed: () {}),
      ]),
    );
    final Widget friendRow = RatelListRow(
      leadingEmoji: '🐼',
      title: 'Maximiliana Featherstonehaugh-Wellington',
      subtitle: '@maximiliana · 1,640 XP this week',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        const RatelChip(label: 'Passed you', tone: RatelChipTone.coral),
        const SizedBox(width: RatelSpace.xs),
        PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: const Text('⋯'),
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'x', child: Text('Remove')),
                ]),
      ]),
    );
    await tester.pumpWidget(_host(
        Column(children: <Widget>[requestRow, friendRow]),
        width: 360));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Maximiliana'), findsWidgets);
  });
}
