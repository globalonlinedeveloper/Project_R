import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/data_access/supabase_user_state_stores.dart';
import 'package:ratel/services/preferences/prefs_settings_store.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/services/progress/prefs_xp_history_store.dart';
import 'package:ratel/services/progress/xp_history_store.dart';
import 'package:ratel/services/progress/prefs_study_stats_store.dart';
import 'package:ratel/services/progress/study_stats_store.dart';
import 'package:ratel/services/economy/outfits_store.dart';
import 'package:ratel/services/economy/prefs_outfits_store.dart';

import 'app/backend_wiring.dart';
import 'app/content_wiring.dart';
import 'app/course_switch.dart';
import 'features/settings/settings_controller.dart';

/// RATEL entrypoint — boots the design-system theme + the go_router 5-tab shell.
/// Best-effort wirings, each failing safe to a local default so the app ALWAYS
/// boots: (1) the Supabase-backed data-access + identity seams when the build
/// carries the publishable config (else in-memory / guest); (2) on-device
/// settings persistence (else in-memory settings); (3) the authored course
/// spine projected from the bundled content batch (else an honest empty path).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<Override> overrides = <Override>[];

  // (1) Backend seams: live Supabase when configured, else local defaults.
  overrides.addAll(await initBackendOverrides());

  // (2) On-device settings persistence (best-effort) — wrapped by the U-lane
  // cross-device sync decorators when the backend is configured (S110): the
  // device store stays the instant boot cache, every save write-throughs to
  // the own-row Supabase tables, and hydration below pulls + merges the
  // durable rows. Guests and keyless boots stay byte-identical to plain prefs.
  SharedPreferences? prefs;
  final List<Future<void>> hydrations = <Future<void>>[];
  try {
    prefs = await SharedPreferences.getInstance();
    SettingsStore settings = PrefsSettingsStore(prefs);
    XpHistoryStore xpHistory = PrefsXpHistoryStore(prefs);
    StudyStatsStore studyStats = PrefsStudyStatsStore(prefs);
    OutfitsStore outfits = PrefsOutfitsStore(prefs);
    if (supabaseConfigured()) {
      try {
        final SupabaseClient client = Supabase.instance.client;
        final SupabaseSettingsStore syncedSettings =
            SupabaseSettingsStore(client, settings);
        final SupabaseXpHistoryStore syncedXp =
            SupabaseXpHistoryStore(client, xpHistory);
        final SupabaseStudyStatsStore syncedStats =
            SupabaseStudyStatsStore(client, studyStats);
        final SupabaseOutfitsStore syncedOutfits =
            SupabaseOutfitsStore(client, outfits);
        hydrations.addAll(<Future<void>>[
          syncedSettings.hydrate(),
          syncedXp.hydrate(),
          syncedStats.hydrate(),
          syncedOutfits.hydrate(),
        ]);
        settings = syncedSettings;
        xpHistory = syncedXp;
        studyStats = syncedStats;
        outfits = syncedOutfits;
      } catch (_) {
        // backend unavailable: keep the plain device stores
      }
    }
    overrides.add(settingsStoreProvider.overrideWithValue(settings));
    overrides.add(xpHistoryStoreProvider.overrideWithValue(xpHistory));
    overrides.add(studyStatsStoreProvider.overrideWithValue(studyStats));
    overrides.add(outfitsStoreProvider.overrideWithValue(outfits));
  } catch (_) {
    // keep the in-memory settings default
  }

  // (3) Content-driven learning path: project the SELECTED bundled course
  // batch (INF-3 — persisted course code; ES default so existing learners
  // see no change) + the manifest-derived course list for the picker.
  String courseCode = kDefaultCourseCode;
  try {
    courseCode = prefs?.getString(kCoursePrefKey) ?? kDefaultCourseCode;
  } catch (_) {}
  final List<Override> content =
      await initContentOverrides(course: courseCode);
  final List<String> courses = await availableCourseCodes();

  // U-lane hydration (S110): pull the durable user-state rows ONCE before the
  // first frame so controllers boot on the merged truth — hard-capped so a
  // slow network can never hold boot hostage (fail-open to device state).
  if (hydrations.isNotEmpty) {
    try {
      await Future.wait(hydrations)
          .timeout(const Duration(milliseconds: 2500));
    } catch (_) {/* fail-open: device state boots, sync rides later saves */}
  }

  runApp(RatelCourseRoot(
    baseOverrides: overrides,
    initialContent: content,
    initialCourse: courseCode,
    availableCourses: courses,
    prefs: prefs,
  ));
}
