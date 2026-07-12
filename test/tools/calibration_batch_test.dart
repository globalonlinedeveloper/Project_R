import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import 'package:ratel/services/data_access/supabase_calibration_store.dart';
import 'package:ratel/services/learning/learning.dart';

/// Monthly item re-calibration BATCH entry-point (R-G3 go-live tail) — the job
/// the `.github/workflows/calibrate.yml` scheduled workflow runs.
///
/// It reuses the SHIPPED, tested engine UNCHANGED: it wraps a service-role
/// [SupabaseClient] in [SupabaseCalibrationStore] and runs [CalibrationRunner]
/// over each course, writing back only the items the thin-data guard actually
/// re-fit. It runs as a `flutter test` because the engine depends on Flutter
/// packages (riverpod / supabase_flutter) and Flutter is already set up in CI.
///
/// DORMANT BY DEFAULT: with no `SUPABASE_URL` / `SUPABASE_SERVICE_ROLE_KEY` in
/// the environment — the case for normal CI, and for the monthly schedule until
/// the owner adds the service-role secret — it prints a skip line and returns,
/// so it NEVER touches production until the owner has both applied the item-bank
/// migration AND set the secret.
void main() {
  test('monthly item re-calibration (skips unless SUPABASE_* env is set)',
      () async {
    final Map<String, String> env = Platform.environment;
    final String? url = env['SUPABASE_URL'];
    final String? serviceKey = env['SUPABASE_SERVICE_ROLE_KEY'];
    if (url == null ||
        url.isEmpty ||
        serviceKey == null ||
        serviceKey.isEmpty) {
      // ignore: avoid_print
      print('[calibrate] SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY not set — '
          'skipping (dormant until the service-role secret is added).');
      return;
    }

    final SupabaseClient client = SupabaseClient(url, serviceKey);
    final SupabaseCalibrationStore store =
        SupabaseCalibrationStore.fromClient(client);
    const CalibrationRunner runner = CalibrationRunner();

    final List<String> courses = await _resolveCourses(client, env);
    if (courses.isEmpty) {
      // ignore: avoid_print
      print('[calibrate] no courses found in item_bank — nothing to do.');
      return;
    }

    int totalWritten = 0;
    for (final String course in courses) {
      final CalibrationRunReport report =
          await runner.runItemCalibration(store, course);
      totalWritten += report.writtenCount;
      // ignore: avoid_print
      print('[calibrate] $course: ${report.itemCount} items · '
          '${report.writtenCount} re-fit · '
          '${report.verbatimCount} kept verbatim.');
    }
    // ignore: avoid_print
    print('[calibrate] done: ${courses.length} course(s), '
        '$totalWritten item(s) updated.');
  }, timeout: const Timeout(Duration(minutes: 30)));
}

/// Course list: explicit `CALIBRATION_COURSES=es,en,…`, else the distinct
/// `target_locale`s already present in the durable item bank.
Future<List<String>> _resolveCourses(
    SupabaseClient client, Map<String, String> env) async {
  final String? explicit = env['CALIBRATION_COURSES'];
  if (explicit != null && explicit.trim().isNotEmpty) {
    return explicit
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
  }
  final List<Map<String, dynamic>> rows = await client
      .from(SupabaseCalibrationStore.itemBankTable)
      .select('target_locale');
  return rows
      .map((Map<String, dynamic> r) => (r['target_locale'] ?? '').toString())
      .where((String s) => s.isNotEmpty)
      .toSet()
      .toList();
}
