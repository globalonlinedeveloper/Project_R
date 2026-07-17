import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/data_access/supabase_user_state_stores.dart';
import 'package:ratel/services/adventures/adventure_progress_store.dart';
import 'package:ratel/services/adventures/prefs_adventure_progress_store.dart';
import 'package:ratel/services/notifications/earned_stamps_store.dart';
import 'package:ratel/services/notifications/prefs_earned_stamps_store.dart';
import 'package:ratel/services/preferences/prefs_settings_store.dart';
import 'package:ratel/services/preferences/prefs_ui_locale_store.dart';
import 'package:ratel/services/preferences/prefs_immersion_mode_store.dart';
import 'package:ratel/services/preferences/ui_locale_store.dart';
import 'package:ratel/services/preferences/immersion_mode_store.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/services/progress/prefs_xp_history_store.dart';
import 'package:ratel/services/progress/xp_history_store.dart';
import 'package:ratel/services/progress/prefs_study_stats_store.dart';
import 'package:ratel/services/progress/study_stats_store.dart';
import 'package:ratel/services/economy/outfits_store.dart';
import 'package:ratel/services/economy/prefs_outfits_store.dart';
import 'package:ratel/services/billing/billing.dart';

import 'app/auth_gate.dart';
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
///
/// AUTH-1 (S112): the first launch of a configured build shows the Welcome
/// gate (Register / Log in / Continue as guest) — the anonymous session now
/// starts on the persisted guest CHOICE instead of unconditionally at boot;
/// returning users (live session or persisted choice) skip straight in.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<Override> overrides = <Override>[];

  // (0) Device prefs first (AUTH-1): the persisted first-launch choice decides
  // whether the anonymous session may auto-resume (returning guest) and
  // whether the Welcome gate must show (first configured launch).
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    // keep null: every consumer below falls back to its in-memory default
  }
  String? authChoice;
  try {
    authChoice = prefs?.getString(kAuthChoicePrefKey);
  } catch (_) {}

  // (1) Backend seams: live Supabase when configured, else local defaults.
  overrides.addAll(await initBackendOverrides(
      guestChosen: authChoice == kAuthChoiceGuest));

  // (1b) AUTH-1 Welcome gate: compute the boot decision + wire persistence.
  bool welcomeGate = false;
  if (supabaseConfigured()) {
    bool hasSession = false;
    try {
      hasSession = Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      // Backend init failed above -> no session; the gate still only shows on
      // configured builds and every entry action stays best-effort.
    }
    welcomeGate = shouldShowWelcomeGate(
      configured: true,
      hasSession: hasSession,
      choiceMade: authChoice != null,
    );
  }
  overrides.add(welcomeGateNeededProvider.overrideWith((ref) => welcomeGate));
  final SharedPreferences? choicePrefs = prefs;
  if (choicePrefs != null) {
    overrides.add(
        authChoicePersisterProvider.overrideWithValue((String choice) async {
      try {
        await choicePrefs.setString(kAuthChoicePrefKey, choice);
      } catch (_) {
        // best-effort: worst case the gate re-shows next launch
      }
    }));
  }

  // (2) On-device settings persistence (best-effort) — wrapped by the U-lane
  // cross-device sync decorators when the backend is configured (S110): the
  // device store stays the instant boot cache, every save write-throughs to
  // the own-row Supabase tables, and hydration below pulls + merges the
  // durable rows. Guests and keyless boots stay byte-identical to plain prefs.
  final List<Future<void>> hydrations = <Future<void>>[];
  if (prefs != null) {
    try {
      SettingsStore settings = PrefsSettingsStore(prefs);
      XpHistoryStore xpHistory = PrefsXpHistoryStore(prefs);
      StudyStatsStore studyStats = PrefsStudyStatsStore(prefs);
      OutfitsStore outfits = PrefsOutfitsStore(prefs);
      // D-13 earn stamps: device-local only (like the pre-S110 stores) — a
      // cross-device synced column is a future owner-gated migration.
      EarnedStampsStore earnedStamps = PrefsEarnedStampsStore(prefs);
      // L-4 adventure exploration: device-local only (same owner-gated
      // cross-device-migration posture as xpHistory/earnedAt, S126/S131).
      AdventureProgressStore adventureProgress =
          PrefsAdventureProgressStore(prefs);
      // L-2 app-shell language override: device-local only (the synced
      // user_settings row is fixed-column — a cross-device column is an
      // owner-gated migration, S126 precedent).
      final UiLocaleStore uiLocale = PrefsUiLocaleStore(prefs);
      // INC-14 immersion flag: device-local only (same fixed-column
      // posture as the UI-locale override above — a synced column is a
      // future owner-gated migration).
      final ImmersionModeStore immersionMode =
          PrefsImmersionModeStore(prefs);
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
          // S131d (L-3): the two remaining device-local stores go synced.
          final SupabaseEarnedStampsStore syncedStamps =
              SupabaseEarnedStampsStore(client, earnedStamps);
          final SupabaseAdventureProgressStore syncedAdventures =
              SupabaseAdventureProgressStore(client, adventureProgress);
          hydrations.addAll(<Future<void>>[
            syncedSettings.hydrate(),
            syncedXp.hydrate(),
            syncedStats.hydrate(),
            syncedOutfits.hydrate(),
            syncedStamps.hydrate(),
            syncedAdventures.hydrate(),
          ]);
          settings = syncedSettings;
          xpHistory = syncedXp;
          studyStats = syncedStats;
          outfits = syncedOutfits;
          earnedStamps = syncedStamps;
          adventureProgress = syncedAdventures;
        } catch (_) {
          // backend unavailable: keep the plain device stores
        }
      }
      overrides.add(settingsStoreProvider.overrideWithValue(settings));
      overrides.add(xpHistoryStoreProvider.overrideWithValue(xpHistory));
      overrides.add(studyStatsStoreProvider.overrideWithValue(studyStats));
      overrides.add(outfitsStoreProvider.overrideWithValue(outfits));
      overrides.add(
          earnedStampsStoreProvider.overrideWithValue(earnedStamps));
      overrides.add(adventureProgressStoreProvider
          .overrideWithValue(adventureProgress));
      overrides.add(uiLocaleStoreProvider.overrideWithValue(uiLocale));
      overrides.add(
          immersionModeStoreProvider.overrideWithValue(immersionMode));
    } catch (_) {
      // keep the in-memory settings default
    }
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

  // (3b) L-5b entitlements seed (S114): read own profiles.is_pro once at boot
  // (rides the capped wait below); any failure leaves the free default.
  bool bootIsPro = false;
  if (supabaseConfigured()) {
    try {
      hydrations.add(fetchIsPro(Supabase.instance.client)
          .then((bool v) => bootIsPro = v));
    } catch (_) {}
  }

  // U-lane hydration (S110): pull the durable user-state rows ONCE before the
  // first frame so controllers boot on the merged truth — hard-capped so a
  // slow network can never hold boot hostage (fail-open to device state).
  if (hydrations.isNotEmpty) {
    try {
      await Future.wait(hydrations)
          .timeout(const Duration(milliseconds: 2500));
    } catch (_) {/* fail-open: device state boots, sync rides later saves */}
  }

  // L-5b: seed the reactive pro flag with the boot fetch result (false when
  // keyless / signed-out / fetch failed — free tier).
  overrides.add(proStatusProvider.overrideWith((ref) => bootIsPro));

  runApp(RatelCourseRoot(
    baseOverrides: overrides,
    initialContent: content,
    initialCourse: courseCode,
    availableCourses: courses,
    prefs: prefs,
  ));
}
