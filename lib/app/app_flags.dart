import 'package:flutter/foundation.dart';

/// First-run gate (in-memory; real persistence is a Stage-3 concern — R-O1
/// keeps learner-state as interfaces/stubs locally). The router redirect reads
/// it; onboarding flips it true on completion.
final ValueNotifier<bool> onboardingComplete = ValueNotifier<bool>(false);

/// Auth foundation gate (R-L1). OFF by default so `main` behaviour is unchanged
/// while the Supabase identity + Login/guest flow are built behind it; flip with
/// `--dart-define=RATEL_AUTH=true` once the flow is CI-green.
const bool authEnabled = bool.fromEnvironment('RATEL_AUTH');
