-- BUILD-AHEAD — not deployed; pending human review + go-live wiring.
--
-- PARTMAN-1 [Door #4 · R-M3] — rolling partition maintenance for review_log.
--
-- 0001_schema.sql declares review_log PARTITION BY RANGE (reviewed_at) with only two
-- STATIC monthly partitions (2026-06, 2026-07) and NO default partition. Once the calendar
-- passes the last static window, any INSERT with reviewed_at >= 2026-08-01 fails hard
-- ("no partition of relation \"review_log\" found for row") — a self-inflicted outage on a
-- fixed date. This function rolls the monthly window forward (and can prune old months),
-- so review_log keeps accepting writes without a schema migration.
--
-- It is the self-contained equivalent of pg_partman's run_maintenance (chosen over the
-- extension to avoid a hard dependency and keep the disposable test hermetic; Supabase
-- ships pg_partman, so the owner may instead swap this for partman.create_parent + a
-- pg_cron run_maintenance job). Schedule it monthly, WELL AHEAD of the window
-- (R-AUT-3 recalibration / pg_cron). Deliberately NO default partition: a default would
-- silently absorb out-of-range rows and then block creating that month's real partition
-- (cannot create a partition overlapping rows already in default) — pre-creation avoids
-- that trap entirely.
--
-- Server-only: EXECUTE is service_role ONLY (re-asserts 0002/0003 — clients never run DDL).
-- SECURITY DEFINER so the table owner's rights create/drop the partitions.
--
-- Apply to a DISPOSABLE pgserver DB only; the live Supabase project is never touched here.
-- DATA NOTE: pruning DROPS whole old partitions (irreversible data loss), so it is OPT-IN
-- (p_drop_before defaults NULL = never drop). The retention window is an owner / R-K3
-- data-minimization decision and is NOT encoded here.

CREATE OR REPLACE FUNCTION ensure_review_log_partitions(
  p_months_ahead integer DEFAULT 6,
  p_drop_before  date    DEFAULT NULL
) RETURNS TABLE(op text, part_name text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $fn$
DECLARE
  v_start date := date_trunc('month', (now() AT TIME ZONE 'UTC'))::date;
  v_lo    date;
  v_hi    date;
  v_name  text;
  v_child text;
  v_upper date;
BEGIN
  IF p_months_ahead < 0 THEN
    RAISE EXCEPTION 'p_months_ahead must be >= 0 (got %)', p_months_ahead
      USING ERRCODE = 'check_violation';
  END IF;

  -- (1) Roll the window forward: ensure a partition for current month .. +p_months_ahead.
  --     IF NOT EXISTS makes this idempotent and lets it coexist with the static
  --     2026_06/2026_07 partitions (same name + bounds => skipped, never an overlap error).
  FOR i IN 0..p_months_ahead LOOP
    v_lo   := (v_start + make_interval(months => i))::date;
    v_hi   := (v_lo + interval '1 month')::date;
    v_name := format('review_log_%s', to_char(v_lo, 'YYYY_MM'));
    EXECUTE format(
      'CREATE TABLE IF NOT EXISTS %I PARTITION OF %I FOR VALUES FROM (%L) TO (%L)',
      v_name, 'review_log', v_lo::text, v_hi::text);
    op := 'ensured'; part_name := v_name; RETURN NEXT;
  END LOOP;

  -- (2) Optional retention: drop whole monthly partitions whose entire range ends on or
  --     before p_drop_before. OPT-IN (NULL => skip). Bounds are derived from our own
  --     review_log_YYYY_MM naming, so a non-conforming child is never touched.
  IF p_drop_before IS NOT NULL THEN
    FOR v_child IN
      SELECT c.relname
        FROM pg_inherits inh
        JOIN pg_class c ON c.oid = inh.inhrelid
        JOIN pg_class p ON p.oid = inh.inhparent
       WHERE p.relname = 'review_log'
         AND c.relname ~ '^review_log_[0-9]{4}_[0-9]{2}$'
    LOOP
      v_upper := (to_date(right(v_child, 7), 'YYYY_MM') + interval '1 month')::date;
      IF v_upper <= p_drop_before THEN
        EXECUTE format('DROP TABLE IF EXISTS %I', v_child);
        op := 'dropped'; part_name := v_child; RETURN NEXT;
      END IF;
    END LOOP;
  END IF;

  RETURN;
END;
$fn$;

-- Least privilege: only the server (service_role) runs partition maintenance; a logged-in
-- client can neither EXECUTE the fn nor otherwise run DDL (re-asserts 0002 / 0003 / P0-3).
REVOKE ALL ON FUNCTION ensure_review_log_partitions(integer, date) FROM PUBLIC;
REVOKE ALL ON FUNCTION ensure_review_log_partitions(integer, date) FROM authenticated, anon;
GRANT EXECUTE ON FUNCTION ensure_review_log_partitions(integer, date) TO service_role;
