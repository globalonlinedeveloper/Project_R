// Ratel PRO-themed capture (INC-10 verification): log in as the PRO test user,
// apply each world theme via its picker card, and screenshot Home so E1
// (per-world animated backdrop) and E2 (per-world vehicle) can be verified.
//
// Approach: drive the real login form, then apply each theme by TAPPING its
// picker card as the (unlocked) PRO user -> _onCardTap persists + re-skins LIVE
// via activeWorldProvider, NO reload. (Seed+reload was clobbered by the authed
// boot re-syncing the account's default Daylight theme; a live tap isn't.)
//
// Credentials come ONLY from env (RATEL_PRO_EMAIL / RATEL_PRO_PASSWORD, wired
// from GitHub Actions secrets) -- never hard-coded, never logged.
//
// Evidence: Home under FOUR themes in one run --
//   * Daylight (baseline; backdrop 'none' => flat cream is CORRECT here)
//   * Space  (galaxy -- the ONE wired world: stars backdrop + PodTraveller) == CONTROL
//   * Ocean  (should be 'bubbles' underwater + Submarine)  == E1/E2 under test
//   * Forest (should be 'fireflies' + Leaf glider)          == E1/E2 second sample
// If Space shows stars but Ocean/Forest show flat cream + the badger traveller,
// E1 + E2 are confirmed live under PRO.

import { chromium } from 'playwright';
import fs from 'node:fs';
import path from 'node:path';

const arg = (name, def) => {
  const i = process.argv.indexOf('--' + name);
  return i >= 0 && process.argv[i + 1] ? process.argv[i + 1] : def;
};
const BASE = arg('base', 'http://127.0.0.1:8080').replace(/\/+$/, '');
const OUT = arg('out', 'screenshots-pro');
const DSF = parseInt(arg('dsf', '2'), 10);
const VIEWPORT = { width: 390, height: 844 };
const EMAIL = process.env.RATEL_PRO_EMAIL || '';
const PASSWORD = process.env.RATEL_PRO_PASSWORD || '';
const WT_KEY = 'flutter.ratel.settings.worldTheme';
const TABS = ['library', 'leagues', 'quests', 'profile'];

const SETTLE_BOOT = 4500;
const SETTLE_ROUTE = 1800;
const SETTLE_SCROLL = 900;
const NAV_TIMEOUT = 45000;

fs.mkdirSync(OUT, { recursive: true });
const log = (...a) => console.log('[pro-capture]', ...a);
const report = [];
const note = (line) => { report.push(line); log(line); };

async function waitForFlutter(page, settle) {
  await page.waitForSelector('flutter-view, flt-glass-pane, flt-scene-host, canvas', { state: 'attached', timeout: 20000 }).catch(() => {});
  await page.waitForTimeout(settle);
}
const hashPath = (page) =>
  page.evaluate(() => (location.hash || '').replace(/^#/, '').split('?')[0]).catch(() => '');

async function shoot(page, file) {
  await page.screenshot({ path: path.join(OUT, file), animations: 'disabled' }).catch((e) => log('shot failed', file, e.message));
  return file;
}
async function gotoRoute(page, route, settle = SETTLE_ROUTE) {
  await page.goto(BASE + '/#' + route, { waitUntil: 'domcontentloaded', timeout: NAV_TIMEOUT }).catch((e) => log('nav error', route, e.message));
  await waitForFlutter(page, settle);
}

async function listFields(page) {
  const raw = await page.$$eval(
    'input, textarea, [contenteditable="true"], flt-semantics[role="textbox"]',
    (els) => els.map((e) => {
      const r = e.getBoundingClientRect();
      return { label: (e.getAttribute('aria-label') || e.getAttribute('placeholder') || '').trim(), type: (e.getAttribute('type') || e.tagName).toLowerCase(), x: Math.round(r.left + r.width / 2), y: Math.round(r.top + r.height / 2), top: Math.round(r.top), w: Math.round(r.width), h: Math.round(r.height) };
    }).filter((f) => f.w > 20 && f.h > 8),
  ).catch(() => []);
  const seen = new Set(); const out = [];
  for (const f of raw.sort((a, b) => a.top - b.top)) {
    const k = f.x + ':' + f.top;
    if (seen.has(k)) continue; seen.add(k);
    out.push(f);
  }
  return out;
}

async function typeInto(page, field, value) {
  await page.mouse.click(field.x, field.y).catch(() => {});
  await page.waitForTimeout(350);
  await page.keyboard.insertText(value).catch(async () => { await page.keyboard.type(value, { delay: 25 }); });
  await page.waitForTimeout(250);
}

async function enableSemantics(page) {
  for (let t = 0; t < 5; t++) {
    if (await page.$('flt-semantics')) return true;
    const ph = await page.$('flt-semantics-placeholder, [aria-label*="accessibility" i], [aria-label*="Enable" i]');
    if (ph) { await ph.click({ force: true }).catch(() => {}); await page.waitForTimeout(500); }
    else await page.waitForTimeout(400);
  }
  return (await page.$('flt-semantics')) != null;
}

async function captureHome(page, tag) {
  if (!/\/home$/.test('/' + (await hashPath(page)))) await gotoRoute(page, '/home', SETTLE_ROUTE);
  const frames = [await shoot(page, `home_${tag}_00.png`)];
  for (let s = 1; s <= 2; s++) {
    await page.mouse.move(VIEWPORT.width / 2, VIEWPORT.height * 0.6);
    await page.mouse.wheel(0, Math.round(VIEWPORT.height * 0.8));
    await page.waitForTimeout(SETTLE_SCROLL);
    frames.push(await shoot(page, `home_${tag}_${String(s).padStart(2, '0')}.png`));
  }
  note(`  home[${tag}] captured (${frames.length} frames), hash=/${await hashPath(page)}`);
  return frames;
}

// E3 (INC-10): after a world is applied, visit each of the 4 non-Home tabs
// and shoot ONE frame so the app-wide animated WorldBackdrop revealed by the
// now-transparent tab root can be checked (Ocean bubbles / Forest fireflies
// in the gutters; Daylight stays flat cream). Routes are hash paths, like the
// rest of the script (gotoRoute -> `/#/library` etc.).
async function captureTabs(page, tag) {
  const shots = [];
  for (const name of TABS) {
    await gotoRoute(page, '/' + name, SETTLE_ROUTE);
    await page.waitForTimeout(700); // let the tab list + backdrop settle a frame
    shots.push(await shoot(page, `${name}_${tag}.png`));
    note(`  tab[${name}/${tag}] captured, hash=/${await hashPath(page)}`);
  }
  return shots;
}

// Apply a theme by TAPPING its picker card (deterministic 2-col grid at 390x844).
// PRO account = every world unlocked, so _onCardTap persists + re-skins LIVE via
// activeWorldProvider (no reload, no authed-boot clobber). Coords are CSS px from
// 40_themes_picker.png (row1 Daylight|Space; row2 Savanna|Ocean; row3 Forest|Candy).
async function applyThemeByTap(page, cfg) {
  await gotoRoute(page, '/themes', SETTLE_ROUTE);
  await page.waitForTimeout(800);
  await shoot(page, `themes_${cfg.label}_before.png`);
  await page.mouse.click(cfg.x, cfg.y).catch(() => {});
  await page.waitForTimeout(1500);
  const landed = await hashPath(page);
  const wt = await page.evaluate((k) => localStorage.getItem(k), WT_KEY).catch(() => null);
  const ok = wt && wt.includes(cfg.id);
  note(`  tap ${cfg.label} @(${cfg.x},${cfg.y}) -> hash=/${landed} worldTheme=${wt} ${ok ? 'OK' : (/paywall/.test(landed) ? '(PAYWALL!)' : '(unchanged?)')}`);
  await shoot(page, `themes_${cfg.label}_after.png`);
  await captureHome(page, cfg.label);
  await captureTabs(page, cfg.label); // E3: the 4 tabs under this world
  return { applied: !!ok, worldTheme: wt, landed: '/' + landed };
}

(async () => {
  const manifest = { base: BASE, viewport: VIEWPORT, dsf: DSF, startedAt: new Date().toISOString(), steps: {} };
  if (!EMAIL || !PASSWORD) note('WARNING: RATEL_PRO_EMAIL / RATEL_PRO_PASSWORD not set -- login WILL fail.');

  const browser = await chromium.launch({ args: ['--no-sandbox', '--disable-dev-shm-usage', '--force-color-profile=srgb', '--hide-scrollbars'] });
  const context = await browser.newContext({
    viewport: VIEWPORT, deviceScaleFactor: DSF, isMobile: true, hasTouch: true,
    serviceWorkers: 'block', locale: 'en-US', colorScheme: 'light',
    userAgent: 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
  });
  const page = await context.newPage();
  page.on('pageerror', (e) => log('pageerror:', String(e).slice(0, 160)));

  try {
    await gotoRoute(page, '/login', SETTLE_BOOT);
    await shoot(page, '00_login_boot.png');
    const semOk = await enableSemantics(page);
    await page.waitForTimeout(600);
    let fields = await listFields(page);
    if (fields.length < 2) { // one more nudge: tap near the email row to force Flutter to build the inputs
      await page.mouse.click(VIEWPORT.width / 2, 405).catch(() => {});
      await page.waitForTimeout(500);
      fields = await listFields(page);
    }
    note(`semantics=${semOk}`);
    note(`login fields: ${fields.length} -> ${fields.map((f) => `${f.type}:"${f.label}"@${f.top}`).join(' , ')}`);
    const emailField = fields.find((f) => /mail/i.test(f.label)) || fields[0];
    const pwField = fields.find((f) => /pass/i.test(f.label)) || fields[1] || fields[fields.length - 1];
    if (emailField) await typeInto(page, emailField, EMAIL);
    if (pwField && pwField !== emailField) await typeInto(page, pwField, PASSWORD);
    await shoot(page, '10_login_filled.png');
    await page.keyboard.press('Enter').catch(() => {});

    let landed = '';
    for (let i = 0; i < 24; i++) {
      await page.waitForTimeout(1000);
      landed = await hashPath(page);
      if (landed && !/login|welcome|signup/.test(landed)) break;
    }
    await waitForFlutter(page, SETTLE_ROUTE);
    await shoot(page, '30_after_login.png');
    const loginOk = !!landed && !/login|welcome|signup/.test(landed);
    manifest.steps.login = { ok: loginOk, landed: '/' + landed };
    note(`LOGIN ${loginOk ? 'OK' : 'FAILED'} -> /${landed}`);

    const ls = await page.evaluate((k) => ({ worldTheme: localStorage.getItem(k), keys: Object.keys(localStorage).filter((x) => /ratel|supabase|sb-|auth/i.test(x)) }), WT_KEY).catch(() => ({}));
    note(`post-login localStorage: worldTheme=${ls.worldTheme} · session/pref keys: ${(ls.keys || []).join(', ')}`);
    manifest.steps.localStorage = ls;

    await gotoRoute(page, '/themes');
    await shoot(page, '40_themes_picker.png');
    await page.mouse.wheel(0, 640); await page.waitForTimeout(SETTLE_SCROLL); await shoot(page, '40_themes_picker_1.png');
    await page.mouse.wheel(0, 640); await page.waitForTimeout(SETTLE_SCROLL); await shoot(page, '40_themes_picker_2.png');

    await captureHome(page, 'baseline_default');
    await captureTabs(page, 'baseline_default'); // E3 no-backdrop control (flat cream)
    manifest.steps.themes = {};
    for (const t of [
      { id: 'galaxy', label: 'space', x: 285, y: 195 },
      { id: 'ocean', label: 'ocean', x: 285, y: 415 },
      { id: 'forest', label: 'forest', x: 105, y: 640 },
    ]) {
      manifest.steps.themes[t.label] = await applyThemeByTap(page, t);
    }
  } catch (e) {
    note('FATAL: ' + (e && e.message ? e.message : String(e)));
    manifest.error = String(e && e.stack ? e.stack : e).slice(0, 400);
  } finally {
    manifest.finishedAt = new Date().toISOString();
    manifest.files = fs.readdirSync(OUT).filter((f) => f.endsWith('.png')).sort();
    fs.writeFileSync(path.join(OUT, 'manifest.json'), JSON.stringify(manifest, null, 2));
    let md = '# Ratel PRO-themed capture -- INC-10 E3 tab-backdrop verification (4 tabs)\n\n';
    md += 'Captured ' + manifest.startedAt + ' · ' + BASE + ' · ' + VIEWPORT.width + 'x' + VIEWPORT.height + ' @' + DSF + 'x\n\n';
    md += '## Login\n\n' + (manifest.steps.login ? (manifest.steps.login.ok ? 'OK signed in' : 'FAILED') + ' -- landed `' + manifest.steps.login.landed + '`' : 'not attempted') + '\n\n';
    md += '## Themes applied (tapped picker card, live re-skin)\n\n';
    for (const [k, v] of Object.entries(manifest.steps.themes || {})) md += '- **' + k + '** -- ' + (v.applied ? 'applied (worldTheme=' + v.worldTheme + ')' : 'NOT applied (worldTheme=' + v.worldTheme + ', landed ' + v.landed + ')') + '\n';
    md += '\n## What to look for (INC-10 E3 -- the 4 tabs)\n\n';
    md += 'E3 makes each tab root (`Container(color: cream)`) TRANSPARENT for backdrop worlds so the app-wide `WorldBackdrop` shows through -- the same 80%-opaque translucent scaffold as Home/Space provides the readability floor (20% backdrop bleed). Files: library/leagues/quests/profile `_screen.dart`.\n\n';
    md += '- **`{library,leagues,quests,profile}_ocean.png`** -- the animated **bubbles** underwater field should be visible in the gutters/margins around the cards, WITH section headers, card text, leaderboard rows and profile stats still clearly readable.\n';
    md += '- **`{...}_forest.png`** -- same, but the **fireflies** field bleeding through the tinted scaffold; content still readable.\n';
    md += '- **`{...}_baseline_default.png`** -- Daylight control: backdrop is `none`, so these MUST stay flat cream (no bleed). Correct no-backdrop baseline.\n';
    md += '- **Verdict:** if Ocean/Forest tabs reveal their backdrop in the gutters while content stays legible, and Daylight stays flat cream, **E3 is confirmed live under PRO** (tabs now match Home). A tab still painting solid cream over Ocean/Forest means its root did not go transparent.\n';
    md += '\n## Log\n\n```\n' + report.join('\n') + '\n```\n';
    fs.writeFileSync(path.join(OUT, 'PRO_CAPTURE_REPORT.md'), md);
    log('done -> ' + OUT + ' (' + manifest.files.length + ' png)');
    await browser.close();
  }
})().catch((e) => { console.error(e); process.exit(1); });
