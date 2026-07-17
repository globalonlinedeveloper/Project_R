/// INF-3 — restart-free selectable course. [RatelCourseRoot] owns the app's
/// ProviderScope: switching persists the code (SharedPreferences), reloads
/// the content overrides for the new course, and remounts the scope under a
/// fresh key — the whole app re-boots onto the selected curriculum in place,
/// no process restart. [CourseSwitchScope] exposes the current code, the
/// manifest-derived available codes, and the switch action to any screen
/// (Settings renders the picker). Fail-closed: a broken course asset falls
/// back through [initContentOverrides]'s ES-beachhead ladder.
/// [R-A3 · R-B3] course selection over the bundled authored catalogs.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratel/app/content_wiring.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/services/data_access/data_access.dart'
    show currentCourseCodeProvider;

/// Read-only view of the course selection + the switch action, visible to
/// every screen (it wraps the app ABOVE the router).
class CourseSwitchScope extends InheritedWidget {
  const CourseSwitchScope({
    required this.current,
    required this.available,
    required this.switchCourse,
    required super.child,
    super.key,
  });

  /// The course code the app is currently mounted on.
  final String current;

  /// Manifest-derived codes that ship a course batch in this build.
  final List<String> available;

  /// Persist + reload + remount onto [code] (no-op when already current).
  final Future<void> Function(String code) switchCourse;

  static CourseSwitchScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CourseSwitchScope>();

  @override
  bool updateShouldNotify(CourseSwitchScope oldWidget) =>
      oldWidget.current != current || oldWidget.available != available;
}

/// The app root: a ProviderScope whose content overrides follow the selected
/// course. `main` preloads the initial course's overrides so the first frame
/// renders the curriculum with no flash.
class RatelCourseRoot extends StatefulWidget {
  const RatelCourseRoot({
    required this.baseOverrides,
    required this.initialContent,
    required this.initialCourse,
    required this.availableCourses,
    this.prefs,
    this.childOverride,
    super.key,
  });

  /// Backend + prefs overrides — course-independent, kept across switches.
  final List<Override> baseOverrides;

  /// The preloaded content overrides for [initialCourse].
  final List<Override> initialContent;

  final String initialCourse;
  final List<String> availableCourses;

  /// Persistence for the selection (null → selection lives for this run only).
  final SharedPreferences? prefs;

  /// Test seam: replaces [RatelApp] as the remounting scope's child, so the
  /// switch machinery is testable without booting the whole app.
  final Widget? childOverride;

  @override
  State<RatelCourseRoot> createState() => _RatelCourseRootState();
}

class _RatelCourseRootState extends State<RatelCourseRoot> {
  late String _course = widget.initialCourse;
  late List<Override> _content = widget.initialContent;
  Key _scopeKey = UniqueKey();
  bool _switching = false;

  Future<void> _switch(String code) async {
    if (code == _course || _switching) return;
    _switching = true;
    try {
      try {
        await widget.prefs?.setString(kCoursePrefKey, code);
      } catch (_) {
        // persistence is best-effort; the in-run switch still happens
      }
      final List<Override> content = await initContentOverrides(course: code);
      if (!mounted) return;
      setState(() {
        _course = code;
        _content = content;
        _scopeKey = UniqueKey(); // remount: every provider re-boots on the
        // new spine; durable state reloads from its stores
      });
    } finally {
      _switching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CourseSwitchScope(
      current: _course,
      available: widget.availableCourses,
      switchCourse: _switch,
      child: ProviderScope(
        key: _scopeKey,
        overrides: <Override>[
          // INC-15: carry the live course code INTO the scope so the
          // LearnerController keys per-course state (xp/lessons/theta) on
          // the selected course; the scope remounts on switch (fresh key),
          // so this re-reads for free.
          currentCourseCodeProvider.overrideWithValue(_course),
          ...widget.baseOverrides,
          ..._content,
        ],
        child: widget.childOverride ?? const RatelApp(),
      ),
    );
  }
}
