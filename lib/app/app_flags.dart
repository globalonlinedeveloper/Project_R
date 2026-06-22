import 'package:flutter/foundation.dart';

/// First-run gate (in-memory; real persistence is a Stage-3 concern — R-O1
/// keeps learner-state as interfaces/stubs locally). The router redirect reads
/// it; onboarding flips it true on completion.
final ValueNotifier<bool> onboardingComplete = ValueNotifier<bool>(false);
