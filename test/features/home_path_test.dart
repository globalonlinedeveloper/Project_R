import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/home/learning_path_view.dart';
import 'package:ratel/features/home/path_connector.dart';
import 'package:ratel/features/home/path_geometry.dart';
import 'package:ratel/features/home/path_node.dart';
import 'package:ratel/features/home/path_node_state.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

// WS2 big home-path rewrite (SPEC_HOME_PATH): the serpentine learning path is
// laid out by the pure [computePathGeometry] (absolute lanes 130/260 + sin
// wobble, 90/108 spacing) and rendered by [LearningPathView] (dotted trail +
// positioned nodes + section dividers + bobbing badger). Checkpoint = the LAST
// lesson of each unit (owner rule). Motion honours the reduce-motion HARD floor.
// Pure widgets bound to REAL content — no dummy data.

CourseLesson _l(String id) => CourseLesson(
      id: id,
      title: id.toUpperCase(),
      cefr: 'A1',
      exercises: <CourseExercise>[
        CourseExercise(
            id: '${id}_x', exerciseType: 'mcq', prompt: 'p', accepted: const <String>['a']),
      ],
    );

// 5 nodes: idx0 a, idx1 b, idx2 c(=last of unit0 → checkpoint), idx3 d,
// idx4 e(=last of unit1 → checkpoint).
CourseSpine _spine() => CourseSpine(courseCode: 'es', units: <CourseUnit>[
      CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Level A1', lessons: <CourseLesson>[
        _l('a'), _l('b'), _l('c'),
      ]),
      CourseUnit(section: 'SECTION 2 · LEVEL A2', title: 'Level A2', lessons: <CourseLesson>[
        _l('d'), _l('e'),
      ]),
    ]);

Widget _host(Widget child) =>
    MaterialApp(theme: RatelTheme.light(), home: Scaffold(body: child));

LearningPathView _view({
  required int active,
  bool reduceMotion = true,
  Key? activeNodeKey,
  void Function(PathNodeData)? onNodeTap,
}) {
  final PathGeometry g = computePathGeometry(spine: _spine(), activeIndex: active);
  return LearningPathView(
    nodes: g.nodes,
    contentHeight: g.contentHeight,
    sectionDividers: <PathSectionDivider>[
      for (final PathDivider d in g.dividers)
        PathSectionDivider(label: d.label, y: d.y),
    ],
    bannerKicker: 'SECTION 1 · LEVEL A1',
    bannerUnitTitle: 'Level A1',
    reduceMotion: reduceMotion,
    activeNodeKey: activeNodeKey,
    onNodeTap: onNodeTap,
  );
}

void main() {
  group('PathNodeData.resolveState — index-vs-active + checkpoint', () {
    test('completed / current / locked truth table', () {
      PathNodeState r(int i, int a, bool cp) => PathNodeData.resolveState(
          index: i, activeIndex: a, isCheckpointFlag: cp);
      expect(r(1, 3, false), PathNodeState.done);
      expect(r(1, 3, true), PathNodeState.checkpoint); // completed checkpoint
      expect(r(3, 3, false), PathNodeState.active); // current
      expect(r(3, 3, true), PathNodeState.active); // current is always active
      expect(r(5, 3, false), PathNodeState.locked);
      expect(r(5, 3, true), PathNodeState.locked); // locked checkpoint = locked
    });
  });

  group('computePathGeometry — buildPath port', () {
    test('node/divider counts + banner metadata + monotonic y', () {
      final PathGeometry g = computePathGeometry(spine: _spine(), activeIndex: 5);
      expect(g.nodes.length, 5);
      expect(g.dividers.length, 2);
      expect(g.dividers[0].label, 'SECTION 1 · LEVEL A1');
      expect(g.dividers[1].label, 'SECTION 2 · LEVEL A2');
      // unit metadata carried per node.
      expect(g.nodes[0].unitNo, 1);
      expect(g.nodes[2].unitNo, 1);
      expect(g.nodes[3].unitNo, 2);
      expect(g.nodes[0].unitTitle, 'Level A1');
      expect(g.nodes[4].unitTitle, 'Level A2');
      // y strictly increases; contentHeight past the last node.
      for (int i = 1; i < g.nodes.length; i++) {
        expect(g.nodes[i].y > g.nodes[i - 1].y, isTrue);
      }
      expect(g.contentHeight > g.nodes.last.y, isTrue);
    });

    test('lanes alternate 130/260 within each unit (±14 wobble)', () {
      final PathGeometry g = computePathGeometry(spine: _spine(), activeIndex: 5);
      // unit0: l=0 left, l=1 right, l=2 left; unit1: l=0 left, l=1 right.
      expect((g.nodes[0].x - 130).abs() <= 14, isTrue);
      expect((g.nodes[1].x - 260).abs() <= 14, isTrue);
      expect((g.nodes[2].x - 130).abs() <= 14, isTrue);
      expect((g.nodes[3].x - 130).abs() <= 14, isTrue);
      expect((g.nodes[4].x - 260).abs() <= 14, isTrue);
      // nodes stay inside the 390 stage (no horizontal overflow).
      for (final PathNodeData n in g.nodes) {
        expect(n.x - 32 >= 0 && n.x + 32 <= kPathStageWidth, isTrue);
      }
    });

    test('last lesson of EACH unit is a checkpoint once completed (owner rule)', () {
      final PathGeometry g = computePathGeometry(spine: _spine(), activeIndex: 5);
      expect(g.nodes[2].state, PathNodeState.checkpoint); // last of unit 0
      expect(g.nodes[4].state, PathNodeState.checkpoint); // last of unit 1
      expect(g.nodes[0].state, PathNodeState.done);
      expect(g.nodes[1].state, PathNodeState.done);
      expect(g.nodes[3].state, PathNodeState.done);
    });

    test('cold start: node 0 active, everything after locked', () {
      final PathGeometry g = computePathGeometry(spine: _spine(), activeIndex: 0);
      expect(g.nodes[0].state, PathNodeState.active);
      expect(g.nodes[1].state, PathNodeState.locked);
      expect(g.nodes[2].state, PathNodeState.locked); // checkpoint, still locked
      expect(g.nodes[4].state, PathNodeState.locked);
    });

    test('a checkpoint lesson that is the CURRENT node renders active (not gold)', () {
      final PathGeometry g = computePathGeometry(spine: _spine(), activeIndex: 2);
      expect(g.nodes[2].state, PathNodeState.active); // c is last-of-unit0 but current
      // and a single-lesson unit stays a real active node when reached:
      final CourseSpine solo = CourseSpine(courseCode: 'es', units: <CourseUnit>[
        CourseUnit(section: 'S', title: 'Solo', lessons: <CourseLesson>[_l('x')]),
      ]);
      expect(computePathGeometry(spine: solo, activeIndex: 0).nodes.single.state,
          PathNodeState.active);
    });
  });

  group('PathConnectorPainter — paints safely', () {
    test('trail + constellation render + shouldRepaint', () {
      final PathGeometry g = computePathGeometry(spine: _spine(), activeIndex: 3);
      final PictureRecorder rec = PictureRecorder();
      final Canvas canvas = Canvas(rec);
      const Color c = Color(0xFF76746C);
      PathConnectorPainter(nodes: g.nodes, trailColor: c)
          .paint(canvas, const Size(390, 700));
      PathConnectorPainter(
        nodes: g.nodes,
        trailColor: c,
        constellation: true,
        constellationColor: const Color(0x80FFFFFF),
        starColor: const Color(0xFFFFFFFF),
      ).paint(canvas, const Size(390, 700));
      // < 2 nodes = safe no-op.
      PathConnectorPainter(nodes: const <PathNodeData>[], trailColor: c)
          .paint(canvas, const Size(10, 10));
      final PathConnectorPainter p = PathConnectorPainter(nodes: g.nodes, trailColor: c);
      expect(
          p.shouldRepaint(
              PathConnectorPainter(nodes: g.nodes, trailColor: const Color(0xFF000000))),
          isTrue);
      expect(p.shouldRepaint(PathConnectorPainter(nodes: g.nodes, trailColor: c)),
          isFalse);
    });
  });

  group('LearningPathView — assembled path', () {
    testWidgets('reduce-motion: settles (no ticker), shows START + banner + all nodes',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_view(active: 1)));
      await tester.pumpAndSettle(); // settles ⇒ no repeating ticker under the floor
      expect(find.text('START'), findsOneWidget);
      expect(find.text('Level A1'), findsOneWidget); // banner title
      expect(find.byType(PathNode), findsNWidgets(5));
    });

    testWidgets('motion ON: builds + animates without hanging', (WidgetTester tester) async {
      await tester.pumpWidget(_host(_view(active: 1, reduceMotion: false)));
      await tester.pump(); // first frame
      await tester.pump(const Duration(milliseconds: 200)); // advance the tickers
      expect(find.text('START'), findsOneWidget);
      expect(find.byType(PathNode), findsNWidgets(5));
      // unmount so the repeating controllers dispose cleanly.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('active node carries the key + fires onNodeTap with its data',
        (WidgetTester tester) async {
      PathNodeData? tapped;
      await tester.pumpWidget(_host(_view(
        active: 1,
        activeNodeKey: const ValueKey<String>('home-active-node'),
        onNodeTap: (PathNodeData n) => tapped = n,
      )));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('home-active-node')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('home-active-node')));
      expect(tapped, isNotNull);
      expect(tapped!.index, 1);
      expect(tapped!.isActive, isTrue);
    });
  });
}
