# Ratel — design-vs-LIVE screenshot pipeline

Captures every screen of the **built** Ratel web app so we can compare the
owner's 68 design shots (`Apps/RATEL/design_conformance/design_screens/`, mapped
in `SCREEN_MAP.md`) against what actually renders live.

This is **CI-only** — it reuses the exact `deploy-web.yml` build so the shots
match `learnwithratel.com`. Nothing here touches Flutter/UI code or deploys.

## What runs (`.github/workflows/screenshots-live.yml`)

1. Build the web app with the same flags as `deploy-web.yml`
   (`flutter build web --release --base-href "/" --pwa-strategy=none` + the
   `--dart-define`s). Degrades gracefully without secrets (a keyless build boots
   straight to Home as a local guest — no Welcome gate).
2. Serve `build/web` on `127.0.0.1:8080` (plain static server; hash routes are
   client-side).
3. Run `capture.mjs` in Chromium at a **390x844** mobile viewport, entering as
   guest, and screenshotting every screen.
4. Upload everything as the **`ratel-live-screenshots`** artifact.

Trigger: **Actions → screenshots-live → Run workflow**, or push the
`ci/live-screenshots` branch.

## What gets captured (`capture.mjs` + `routes.mjs`)

- **Every route** enumerated from `lib/app/router.dart` (~33), each named to
  `SCREEN_MAP.md`: `06_home_00.png`, `14_library_00.png`, …
  (`x-…` = a real route with no numbered design shot).
- **Below the fold** — long screens are scrolled and re-shot (`_01`, `_02`).
- **Full-coverage interaction layer** — on the main screens, Flutter's
  accessibility tree is enabled and **every labelled button is tapped** to
  capture the sheet / dialog / sub-screen behind it
  (`45_settings__tap-privacy.png`, `06_home__tap-diamonds.png`, …). This is how
  the route-less designs get captured: Courses sheet (#7/8), Diamonds sheet
  (#13), Subscription (#47/48), Redeem (#49), Invite (#50), Privacy (#62–64),
  Help (#65–67), logout confirm (#68), avatar picker (#61).
- **Wizards** — onboarding (#2–4) and placement (#5) advance step-by-step
  (`__step-02`, `__step-03`).
- `manifest.json` + `INDEX.md` map every file → route → design shot(s).

### Honest limits
- Guest, canvas taps are **best-effort**: an unlabelled control is skipped,
  never faked. A denylist blocks destructive/purchase actions
  (subscribe/buy/delete/logout-confirm/restore).
- **Four designed screens do not exist in the app yet** (per `AUDIT.md`):
  Courses full screen, Streak (#11), Energy (#12), Chat tutor (#22/27). No tap
  can capture what isn't built.
- Themes **#51–59 are DEFERRED** — only the `/themes` grid is shot; theme-applied
  variants are not.

## How guest entry works (no login)
The first-launch Welcome gate only shows when Supabase is configured AND no
choice is persisted (`main.dart` → `shouldShowWelcomeGate`). It clears when
`authChoice != null` (prefs key `ratel.auth.choice`). On web that is
`localStorage['flutter.ratel.auth.choice']`, so the script pre-seeds it before
any page load. `location.hash` is the reliable signal for whether the gate
redirected us; a click-guest fallback covers the rare miss.

## Optional: rough visual diff (`visual_diff.mjs`)
`node visual_diff.mjs --shots screenshots --design design_screens` builds a
`design | live | diff-heatmap` composite per mapped screen. The design set is
**not in the repo**, so the CI step **skips cleanly unless a `design_screens/`
folder is present** in this directory. To run it locally, copy the owner's
`design_screens/` here (or download the artifact and diff against the mounted
`Apps/RATEL/design_conformance/design_screens/`). It's an overlay aid, not a
pass/fail gate.

## Run locally (optional)
```bash
cd tool/live_capture
npm install
npx playwright install --with-deps chromium
# from repo root, after `flutter build web ...`:
python3 -m http.server 8080 --directory ../../build/web &
node capture.mjs --base http://127.0.0.1:8080 --out screenshots
```
