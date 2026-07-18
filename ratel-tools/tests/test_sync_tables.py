"""BACKFILL — provenance tests for schema/sql/0012_sync_tables.sql: the TWELVE live
public tables snapshotted in S166 (ai_usage, claim_tokens, item_bank, learner_theta,
profiles, saved_words, user_adventure_progress, user_earned_stamps, user_outfits,
user_progress_daily, user_settings, user_study_stats). Every object is ALREADY LIVE
(applied direct to Supabase; captured via read-only introspection); these tests pin
its structure + RLS on a DISPOSABLE pgserver so the repo snapshot is verifiable +
regression-guarded. The live Supabase project is NEVER touched.
[R-M3 · R-K6 · R-B8 · R-I2 · R-I9 · R-L6]

The harness applies 0001 (structure-only) then this file. auth.users is shimmed in
the preamble: 11 of the 12 tables (all but item_bank) FK to auth.users(id), and
pgserver has no auth tables. auth.uid() is the harness JWT-sub GUC shim.
"""
import pathlib
import sys
import tempfile

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402

USERA = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
USERB = "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"

# item_bank has no user FK; every other backfilled table references auth.users(id).
SYNC_PREAMBLE = """
CREATE TABLE IF NOT EXISTS auth.users (id uuid PRIMARY KEY);
GRANT USAGE ON SCHEMA public TO authenticated, anon, service_role;
"""

ALL_TABLES = [
    "ai_usage", "claim_tokens", "item_bank", "learner_theta", "profiles",
    "saved_words", "user_adventure_progress", "user_earned_stamps",
    "user_outfits", "user_progress_daily", "user_settings", "user_study_stats",
]
AUTH_FK_TABLES = sorted(set(ALL_TABLES) - {"item_bank"})


@pytest.fixture()
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_sync_")
    harness = rls_harness.Harness(
        pgserver, d, ["0012_sync_tables.sql"], extra_preamble=SYNC_PREAMBLE)
    yield harness
    harness.cleanup()


def _seed_users(cur):
    for u in (USERA, USERB):
        cur.execute("INSERT INTO auth.users(id) VALUES (%s::uuid) ON CONFLICT DO NOTHING", (u,))


# ---- structure -------------------------------------------------------------

def test_all_twelve_tables_present(h):
    with h.session() as cur:
        cur.execute(
            "SELECT table_name FROM information_schema.tables "
            "WHERE table_schema='public' AND table_name = ANY(%s)", (ALL_TABLES,))
        got = {r[0] for r in cur.fetchall()}
    assert got == set(ALL_TABLES), f"missing tables: {set(ALL_TABLES) - got}"


def test_rls_enabled_on_all_twelve(h):
    with h.session() as cur:
        cur.execute(
            "SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace "
            "WHERE n.nspname='public' AND c.relname = ANY(%s) AND c.relrowsecurity", (ALL_TABLES,))
        rls_on = {r[0] for r in cur.fetchall()}
    assert rls_on == set(ALL_TABLES), f"RLS not enabled on: {set(ALL_TABLES) - rls_on}"


def test_auth_users_fk_on_eleven_not_item_bank(h):
    with h.session() as cur:
        cur.execute(
            "SELECT c.relname FROM pg_constraint con JOIN pg_class c ON c.oid=con.conrelid "
            "WHERE con.contype='f' AND con.confrelid='auth.users'::regclass "
            "AND c.relname = ANY(%s)", (ALL_TABLES,))
        fk = {r[0] for r in cur.fetchall()}
    assert fk == set(AUTH_FK_TABLES), f"auth.users FK mismatch: {set(AUTH_FK_TABLES) ^ fk}"
    assert "item_bank" not in fk


def test_check_constraints_present(h):
    want = {
        "ai_usage_voice_seconds_check", "ai_usage_chat_msgs_check",
        "user_progress_daily_xp_check", "user_settings_daily_goal_check",
        "user_study_stats_correct_check", "user_study_stats_study_seconds_check",
        "user_study_stats_check", "profiles_handle_format",
    }
    with h.session() as cur:
        cur.execute("SELECT conname FROM pg_constraint "
                    "WHERE contype='c' AND connamespace='public'::regnamespace")
        got = {r[0] for r in cur.fetchall()}
    assert want <= got, f"missing check constraints: {want - got}"


def test_expected_policies_present(h):
    want = {
        ("ai_usage", "ai_usage_select_own"),
        ("item_bank", "item_bank_read"),
        ("learner_theta", "learner_theta_own"),
        ("profiles", "profiles_select_own"),
        ("profiles", "profiles_insert_own"),
        ("profiles", "profiles_update_own"),
        ("saved_words", "saved_words_own"),
        ("user_settings", "user_settings_own"),
    }
    with h.session() as cur:
        cur.execute("SELECT tablename, policyname FROM pg_policies WHERE schemaname='public'")
        got = {(r[0], r[1]) for r in cur.fetchall()}
    assert want <= got, f"missing policies: {want - got}"
    # claim_tokens has RLS on but NO policy (deny-all to clients).
    assert not any(t == "claim_tokens" for t, _ in got)


# ---- profiles identity + is_pro guard --------------------------------------

def test_profiles_handle_lowercase_ci_unique(h):
    with h.session() as cur:
        _seed_users(cur)
        cur.execute("INSERT INTO profiles(id,handle) VALUES (%s::uuid,'ratel')", (USERA,))
        with pytest.raises(h.Error):
            cur.execute("INSERT INTO profiles(id,handle) VALUES (%s::uuid,'ratel')", (USERB,))


def test_profiles_handle_format_check_rejects_invalid(h):
    with h.session() as cur:
        _seed_users(cur)
        with pytest.raises(h.Error):
            cur.execute("INSERT INTO profiles(id,handle) VALUES (%s::uuid,'Has Space')", (USERA,))


def test_profiles_is_pro_guard_blocks_self_promote(h):
    with h.session() as cur:
        _seed_users(cur)
        cur.execute("INSERT INTO profiles(id) VALUES (%s::uuid)", (USERA,))
    # definer-path: privileged writer but JWT role=authenticated => guard raises.
    with h.session() as cur:
        cur.execute("SELECT set_config('request.jwt.claims', %s, false)",
                    ('{"role":"authenticated"}',))
        with pytest.raises(h.Error) as ei:
            cur.execute("UPDATE profiles SET is_pro=true WHERE id=%s::uuid", (USERA,))
        assert "is_pro is managed server-side" in str(ei.value)
    # service-role writer => allowed.
    with h.session() as cur:
        cur.execute("SELECT set_config('request.jwt.claims', %s, false)",
                    ('{"role":"service_role"}',))
        cur.execute("UPDATE profiles SET is_pro=true WHERE id=%s::uuid", (USERA,))
        cur.execute("SELECT is_pro FROM profiles WHERE id=%s::uuid", (USERA,))
        assert cur.fetchone()[0] is True


# ---- RLS behaviour ---------------------------------------------------------

def test_own_row_isolation_settings_and_words(h):
    with h.session() as cur:
        _seed_users(cur)
        for u in (USERA, USERB):
            cur.execute("INSERT INTO user_settings(user_id) VALUES (%s::uuid)", (u,))
            cur.execute("INSERT INTO saved_words(user_id,course_id,normalized_lemma) "
                        "VALUES (%s::uuid,'es','hola')", (u,))
    with h.session(role="authenticated", sub=USERA) as cur:
        cur.execute("SELECT user_id FROM user_settings")
        assert [str(r[0]) for r in cur.fetchall()] == [USERA]
        # cannot create a row owned by B (WITH CHECK)
        with pytest.raises(h.Error):
            cur.execute("INSERT INTO saved_words(user_id,course_id,normalized_lemma) "
                        "VALUES (%s::uuid,'es','chau')", (USERB,))
        # cannot mutate B's hidden row (USING) — 0 rows affected
        cur.execute("UPDATE saved_words SET raw_word='x' WHERE user_id=%s::uuid", (USERB,))
        assert cur.rowcount == 0
    with h.session(role="authenticated", sub=USERB) as cur:
        cur.execute("SELECT user_id FROM saved_words")
        assert [str(r[0]) for r in cur.fetchall()] == [USERB]


def test_claim_tokens_denies_authenticated(h):
    with h.session() as cur:
        _seed_users(cur)
        cur.execute("INSERT INTO claim_tokens(token_hash,source_uid,expires_at) "
                    "VALUES ('h1',%s::uuid, now()+interval '1 day')", (USERA,))
    with h.session(role="authenticated", sub=USERA) as cur:
        with pytest.raises(h.Error):  # no table grant to authenticated => permission denied
            cur.execute("SELECT * FROM claim_tokens")


def test_item_bank_read_all_but_no_client_write(h):
    with h.session() as cur:
        cur.execute("INSERT INTO item_bank(target_locale,item_id) VALUES ('es','i1')")
    with h.session(role="authenticated", sub=USERA) as cur:
        cur.execute("SELECT count(*) FROM item_bank")
        assert cur.fetchone()[0] == 1                 # read-all policy
        with pytest.raises(h.Error):                  # only SELECT granted to authenticated
            cur.execute("INSERT INTO item_bank(target_locale,item_id) VALUES ('es','i2')")


def test_ai_usage_select_own_no_client_write(h):
    with h.session() as cur:
        _seed_users(cur)
        for u in (USERA, USERB):
            cur.execute("INSERT INTO ai_usage(user_id,day) VALUES (%s::uuid, current_date)", (u,))
    with h.session(role="authenticated", sub=USERA) as cur:
        cur.execute("SELECT user_id FROM ai_usage")
        assert [str(r[0]) for r in cur.fetchall()] == [USERA]   # SELECT-own
        with pytest.raises(h.Error):                            # only SELECT granted
            cur.execute("UPDATE ai_usage SET chat_msgs=5 WHERE user_id=%s::uuid", (USERA,))


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-q"]))
