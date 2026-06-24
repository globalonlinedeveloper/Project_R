// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// AUDIT-2 [R-M5 · R-M8 · R-K6] — Dart audit-sink adapters that back the no-op M2
// ModerationAuditSink (lib/services/ai_relay/moderation.dart) + M8 GrantAuditSink
// (lib/services/billing/grant_guard.dart) seams with a DURABLE write to the AUDIT-1 store
// (schema/sql/0008 record_audit_event), behind the SAME injected [HttpTransport] seam the
// AI relay + Play verifier use. So grant / anti-abuse denials + moderation verdicts persist
// for incident response / abuse forensics instead of evaporating (R-M5; R-M8 abuse trail).
//
// The two seams each declare a method named `record` with DIFFERENT signatures, so one
// class cannot implement both. Shape: a shared [AuditEventWriter] (the HTTP dispatch core)
// + two thin adapters ([HttpModerationAuditSink], [HttpGrantAuditSink]) over ONE writer, so
// a single configured transport powers both. [AuditSinks] bundles them.
//
// Server-side by construction: these run in the Deno relay / grant host that already holds
// the Supabase service-role key, injected at request time from the runtime secret store per
// the M7 ServiceRoleKeyContract (lib/services/identity/service_role_contract.dart) — the key
// is NEVER hard-coded here (empty default) and the M7 secret-scan keeps the repo clean.
//
// Fail-soft for the CALLER: a security decision (deny / block) has ALREADY been made by the
// time we audit, so an audit write must NEVER throw back into that hot path or undo it. The
// void seam methods dispatch fire-and-forget; failures route to [AuditEventWriter.onError]
// and are swallowed. Durability at go-live comes from the server host + retry, not the
// client. Unconfigured => no-op (transport untouched) so an un-wired build never calls out.
//
// PII discipline (R-M5 / the R-M1 allow-list): `detail` carries ONLY low-cardinality,
// allow-listed fields (stage, source, deviceId) — NEVER raw content / prompts / transcripts
// (the seams already refuse to echo offending text). user_id is the pseudonymous account id
// and is NULL for moderation (the moderation seam carries no user) — no persistent id leaks.
//
// GO-LIVE STOP: inject the real Supabase REST base URL + service-role key (server-side, from
// Deno.env), override the providers, and stand up the Deno host chaining the moderation /
// grant decision -> these sinks -> record_audit_event.

import 'dart:convert';

import '../ai_relay/gemini_relay.dart' show HttpLikeRequest, HttpLikeResponse, HttpTransport;
import '../ai_relay/moderation.dart' show ModerationAuditSink, ModerationVerdict;
import '../billing/grant_guard.dart' show GrantAuditSink, GrantDecision, GrantSource;

/// Connection config for the AUDIT-1 store's RPC endpoint. Empty baseUrl / serviceRoleKey
/// => unconfigured (no-op; transport never touched). The service-role key is read ONLY
/// server-side from the runtime secret store at go-live (M7 ServiceRoleKeyContract); it is
/// NEVER hard-coded here and the M7 secret-scan keeps the repo clean.
class AuditConfig {
  const AuditConfig({this.baseUrl = '', this.serviceRoleKey = ''});

  final String baseUrl;
  final String serviceRoleKey;

  bool get isConfigured => baseUrl.isNotEmpty && serviceRoleKey.isNotEmpty;
}

/// Shared writer: POSTs ONE event to record_audit_event behind the injected [HttpTransport].
/// Stateless apart from the injected transport/config, so it is exhaustively unit-testable
/// with no network. Best-effort + fail-soft: never throws into the caller.
class AuditEventWriter {
  AuditEventWriter({
    required this.transport,
    this.config = const AuditConfig(),
    this.timeout = const Duration(seconds: 10),
    this.onError,
  });

  final HttpTransport transport;
  final AuditConfig config;
  final Duration timeout;

  /// Optional observability hook for a failed / skipped send. Never rethrows into the caller.
  final void Function(String reason)? onError;

  /// The most recent in-flight (or completed) write, exposed so the fire-and-forget adapters
  /// are deterministically testable. Null until the first [dispatch]. Resolves to the
  /// [recordEvent] result; never rejects.
  Future<bool>? lastWrite;

  /// Builds the Supabase RPC POST (visible for shape assertions). Body keys mirror the SQL
  /// fn parameters exactly: p_category / p_action / p_user_id / p_detail.
  HttpLikeRequest buildRequest({
    required String category,
    required String action,
    String? userId,
    Map<String, Object?> detail = const <String, Object?>{},
  }) {
    final payload = <String, Object?>{
      'p_category': category,
      'p_action': action,
      'p_user_id': userId,
      'p_detail': detail,
    };
    return HttpLikeRequest(
      method: 'POST',
      url: '${config.baseUrl}/rest/v1/rpc/record_audit_event',
      headers: <String, String>{
        'apikey': config.serviceRoleKey,
        'authorization': 'Bearer ${config.serviceRoleKey}',
        'content-type': 'application/json',
      },
      body: jsonEncode(payload),
    );
  }

  /// Awaitable core. No-op (transport untouched) when unconfigured. NEVER throws: a non-2xx,
  /// transport error / timeout, or encode error is routed to [onError] and swallowed. Returns
  /// true only on a 2xx durable write.
  Future<bool> recordEvent({
    required String category,
    required String action,
    String? userId,
    Map<String, Object?> detail = const <String, Object?>{},
  }) async {
    if (!config.isConfigured) {
      onError?.call('unconfigured');
      return false;
    }
    try {
      final request = buildRequest(
        category: category,
        action: action,
        userId: userId,
        detail: detail,
      );
      final HttpLikeResponse resp = await transport(request).timeout(timeout);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        onError?.call('non-2xx status ${resp.statusCode}');
        return false;
      }
      return true;
    } catch (e) {
      // Fail-soft: the security decision already happened; never surface the upstream body.
      onError?.call('audit write failed: ${e.runtimeType}');
      return false;
    }
  }

  /// Fire-and-forget dispatch for the void seam methods: starts the write and stores it in
  /// [lastWrite] (so tests can await it) WITHOUT blocking the caller. [recordEvent] never
  /// rejects, so the unawaited future is safe.
  void dispatch({
    required String category,
    required String action,
    String? userId,
    Map<String, Object?> detail = const <String, Object?>{},
  }) {
    lastWrite = recordEvent(
      category: category,
      action: action,
      userId: userId,
      detail: detail,
    );
  }
}

/// M2 moderation seam adapter. Records every classification: category `'moderation'`,
/// action = `verdict.name`, user_id NULL (the moderation seam carries no user), detail
/// `{stage}`. PII-minimal — the verdict + stage only, never the moderated text.
class HttpModerationAuditSink implements ModerationAuditSink {
  const HttpModerationAuditSink(this.writer);

  final AuditEventWriter writer;

  @override
  void record({required String stage, required ModerationVerdict verdict}) {
    writer.dispatch(
      category: 'moderation',
      action: verdict.name,
      detail: <String, Object?>{'stage': stage},
    );
  }
}

/// M8 grant seam adapter. Records every grant decision: category `'grant'`, action =
/// `decision.name`, user_id = the pseudonymous `userId`, detail `{source, deviceId}`. The
/// deviceId is allow-listed for per-device abuse forensics (R-M8), not user content.
class HttpGrantAuditSink implements GrantAuditSink {
  const HttpGrantAuditSink(this.writer);

  final AuditEventWriter writer;

  @override
  void record(
    GrantDecision decision, {
    required String userId,
    required String deviceId,
    required GrantSource source,
  }) {
    writer.dispatch(
      category: 'grant',
      action: decision.name,
      userId: userId,
      detail: <String, Object?>{'source': source.name, 'deviceId': deviceId},
    );
  }
}

/// Convenience bundle: both seam adapters over ONE shared [AuditEventWriter], so a single
/// configured transport powers moderation + grant auditing. Wire at go-live; the default is
/// unconfigured (no-op).
class AuditSinks {
  AuditSinks._(this.writer)
      : moderation = HttpModerationAuditSink(writer),
        grant = HttpGrantAuditSink(writer);

  factory AuditSinks({
    required HttpTransport transport,
    AuditConfig config = const AuditConfig(),
    void Function(String reason)? onError,
  }) =>
      AuditSinks._(AuditEventWriter(
        transport: transport,
        config: config,
        onError: onError,
      ));

  final AuditEventWriter writer;
  final HttpModerationAuditSink moderation;
  final HttpGrantAuditSink grant;
}
