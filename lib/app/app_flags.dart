import 'package:flutter/foundation.dart';

/// First-run gate (in-memory; real persistence is a Stage-3 concern — R-O1
/// keeps learner-state as interfaces/stubs locally). The router redirect reads
/// it; onboarding flips it true on completion.
final ValueNotifier<bool> onboardingComplete = ValueNotifier<bool>(false);

/// Guest-first entry gate (R-L1). Only consulted when [authEnabled] is on: the
/// router shows the Welcome screen until the user picks an entry path
/// ("Continue as guest" for now; Sign-up/Login arrive in later increments).
/// Kept separate from [onboardingComplete] so guest-first users still flow
/// through onboarding after Welcome.
final ValueNotifier<bool> welcomeSeen = ValueNotifier<bool>(false);

/// Auth foundation gate (R-L1). OFF by default so `main` behaviour is unchanged
/// while the Supabase identity + Login/guest flow are built behind it; flip with
/// `--dart-define=RATEL_AUTH=true` once the flow is CI-green.
const bool authEnabled = bool.fromEnvironment('RATEL_AUTH');

/// Live auth-session state for routing (R-L1). Set from the restored Supabase
/// session on launch and toggled by login / logout; the router observes it so a
/// returning authed user skips Welcome and a logout returns to it. In-memory
/// like the other first-run gates — the durable source is the Supabase session.
final ValueNotifier<bool> signedIn = ValueNotifier<bool>(false);
