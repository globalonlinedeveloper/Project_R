/// AUTH-1 (S112): first-launch Welcome/auth gate — policy + wiring seams.
///
/// Owner steer (S111): "user will register and login; now it's directly
/// showing the home page." The app used to boot an anonymous session
/// automatically; the gate makes that an EXPLICIT first-launch choice —
/// Register / Log in / Continue as guest — without regressing the guest-first
/// path: the guest button runs the same anonymous boot, once, by choice.
///
/// Policy: the gate shows ONLY on a configured build's first launch — no live
/// session and no persisted choice. Returning users (live session, or a
/// persisted choice) skip straight in. Local/keyless builds (and therefore
/// every pre-AUTH-1 test) never gate: every provider below defaults OFF /
/// no-op, so surfaces stay byte-identical until `main` overrides them.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SharedPreferences key for the persisted first-launch choice.
const String kAuthChoicePrefKey = 'ratel.auth.choice';

/// Persisted when the user taps "Continue as guest" on the Welcome gate.
const String kAuthChoiceGuest = 'guest';

/// Persisted when a session is established from the gate (login / signup),
/// so a later signed-out boot still skips the gate (Settings keeps the
/// sign-in entry — the gate is a first-launch surface, not a login wall).
const String kAuthChoiceAccount = 'account';

/// Pure policy (unit-tested): show the Welcome gate only when the build is
/// configured for accounts AND there is no live session AND no choice has
/// been persisted. Guests, returning users, and keyless builds never gate.
bool shouldShowWelcomeGate({
  required bool configured,
  required bool hasSession,
  required bool choiceMade,
}) =>
    configured && !hasSession && !choiceMade;

/// Whether the router must redirect to /welcome. Defaults false (no gate) so
/// every existing surface/test is byte-identical; `main` overrides the initial
/// value on a gated boot and the Welcome actions flip it off.
final welcomeGateNeededProvider = StateProvider<bool>((ref) => false);

/// Persists the first-launch choice ([kAuthChoiceGuest]/[kAuthChoiceAccount]).
/// Default no-op (tests / keyless builds); `main` overrides with a
/// SharedPreferences writer.
final authChoicePersisterProvider =
    Provider<Future<void> Function(String choice)>(
        (ref) => (String choice) async {});

/// The explicit "Continue as guest" action: boots the anonymous Supabase
/// session that pre-AUTH-1 builds started automatically at launch. Best-effort
/// by contract — offline or anon-disabled stays a local guest, NEVER an error.
/// Default no-op; `backend_wiring` supplies the real one when configured.
final guestEntryProvider =
    Provider<Future<void> Function()>((ref) => () async {});
