// Ratel design-vs-LIVE capture: walk every route of the built Flutter web app at
// a 390x844 mobile viewport, enter as guest, screenshot each screen, then (Full
// mode) tap through every labelled button to also capture the sheets, dialogs
// and sub-screens behind them.
//
// Usage:
//   node capture.mjs --base http://127.0.0.1:8080 --out screenshots [--dsf 2]
//                    [--interact 1] [--max-buttons 8]
//
// Flutter web renders into a <canvas> (CanvasKit), so we do NOT depend on DOM
// widgets. Three facts make this robust (verified vs router.dart / main.dart /
// auth_gate.dart at base main d44476f):
//   1. Hash routing: every screen is reachable at <base>/#/<route>. Navigating
//      is a full page load per route -> clean boot, no state bleed or looping-
//      animation carryover between screens.
//   2. Welcome gate: only shows when Supabase is configured AND no choice is
//      persisted; main.dart clears it when authChoice != null (prefs key
//      `ratel.auth.choice` -> web localStorage `flutter.ratel.auth.choice`). We
//      pre-seed a valid-JSON '"guest"' before any load (safe under every
//      shared_preferences_web encoding: decodes to `guest`, or reads non-null,
//      never throws), so the gate is skipped deterministically. A click-guest
//      fallback (detected via location.hash) covers the unlikely miss.
//   3. Buttons: enabling Flutter's accessibility tree turns every tappable into
//      a <flt-semantics> node with an aria-label; we tap its centre coordinate
//      (the tap hits the canvas underneath). Best-effort by contract — an
//      unlabelled control is skipped, never faked. A denylist blocks
//      destructive/purchase actions.

import { chromium } from 'playwright';
import { routes, unrouted } from './routes.mjs';
import fs from 'node:fs';
import path from 'node:path';

const arg = (name, def) => {
  const i = process.argv.indexOf('--' + name);
  return i >= 0 && process.argv[i + 1] ? process.argv[i + 1] : def;
};
const BASE = arg('base', 'http://127.0.0.1:8080').replace(/\/+$/, '');
const OUT = arg('out', 'screenshots');
const DSF = parseInt(arg('dsf', '2'), 10);
const INTERACT = arg('interact', '1') !== '0';
const PER_SCREEN_CAP = parseInt(arg('max-buttons', '8'), 10);
const VIEWPORT = { width: 390, height: 844 };
const SETTLE_BOOT = 3500;
const SETTLE_ROUTE = 1500;
const SETTLE_SCROLL = 900;
const SETTLE_TAP = 1200;
const MAX_SCROLLS = 2;
const NAV_TIMEOUT = 45000;
const START_MS = Date.now();
const BUDGET_MS = parseInt(arg('budget-min', '28'), 10) * 60000; // stop interaction after this; base shots always run first
const overBudget = () => Date.now() - START_MS > BUDGET_MS;

// Actions we must never trigger while blindly walking buttons.
const DENY = /(subscribe|\bbuy\b|\bbuy\s|purchase|checkout|pay\s?now|confirm\s?purchase|upgrade\s?now|delete\s+account|delete\s+my\s+account|\berase\b|sign\s?out|log\s?out|restore|continue with (apple|google|facebook))/i;

fs.mkdirSync(OUT, { recursive: true });
const log = (...a) => console.log('[capture]', ...a);
const slugify = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 34) || 'x';

async function waitForFlutter(page, settle) {
  // Bounded: match whichever host element this Flutter build emits, never hang.
  // (The 90s single-selector wait on flt-glass-pane timed out every nav when the
  // element name differed -> the whole job blew past the 55m cap. flutter-view is
  // created by the bootstrap; canvas appears once CanvasKit paints.)
  await page.waitForSelector('flutter-view, flt-glass-pane, flt-scene-host, canvas', { state: 'attached', timeout: 20000 }).catch(() => {});
  await page.waitForTimeout(settle);
}
const hashPath = (page) =>
  page.evaluate(() => (location.hash || '').replace(/^#/, '').split('?')[0]).catch(() => '');

async function gotoRoute(page, r, settle = SETTLE_ROUTE) {
  await page.goto(BASE + '/#' + r.route + (r.query || ''), { waitUntil: 'domcontentloaded', timeout: NAV_TIMEOUT }).catch((e) => log('nav error', r.route, e.message));
  await waitForFlutter(page, settle);
}

async function shoot(page, file) {
  await page.screenshot({ path: path.join(OUT, file), animations: 'disabled' }).catch((e) => log('shot failed', file, e.message));
  return file;
}

// ---- guest entry ----------------------------------------------------------
async function clickGuest(page) {
  try {
    const ph = await page.$('flt-semantics-placeholder, [aria-label*="accessibility" i]');
    if (ph) { await ph.click({ force: true }).catch(() => {}); await page.waitForTimeout(600); }
    const byText = page.getByText(/continue as guest|setting up/i);
    if (await byText.count().catch(() => 0)) await byText.first().click({ force: true, timeout: 3000 }).catch(() => {});
    else await page.mouse.click(VIEWPORT.width / 2, 520).catch(() => {});
  } catch (_) {}
}
async function enterGuest(page) {
  await page.goto(BASE + '/#/home', { waitUntil: 'domcontentloaded', timeout: NAV_TIMEOUT }).catch(() => {});
  await waitForFlutter(page, SETTLE_BOOT);
  for (let i = 0; i < 3; i++) {
    const h = await hashPath(page);
    if (!/welcome/.test(h)) { log('entered as guest (hash=/' + h + ')'); return true; }
    log(`welcome gate active (attempt ${i + 1}) — clicking "Continue as guest"`);
    await clickGuest(page);
    await page.waitForTimeout(2000);
    await page.goto(BASE + '/#/home', { waitUntil: 'domcontentloaded', timeout: NAV_TIMEOUT }).catch(() => {});
    await waitForFlutter(page, SETTLE_ROUTE);
  }
  log('WARNING: still gated after retries — capturing whatever renders');
  return false;
}

// ---- accessibility-tree helpers (interaction layer) -----------------------
async function enableSemantics(page) {
  for (let t = 0; t < 3; t++) {
    if (await page.$('flt-semantics')) return true;
    const ph = await page.$('flt-semantics-placeholder, [aria-label*="accessibility" i]');
    if (ph) { await ph.click({ force: true }).catch(() => {}); await page.waitForTimeout(500); }
    else await page.waitForTimeout(400);
  }
  return (await page.$('flt-semantics')) != null;
}
async function listInteractive(page) {
  return await page.$$eval(
    'flt-semantics[role="button"], flt-semantics[role="link"], flt-semantics[role="tab"], flt-semantics[aria-label]',
    (els) => {
      const seen = new Set(); const out = [];
      for (const e of els) {
        const label = (e.getAttribute('aria-label') || '').trim();
        if (!label) continue;
        const r = e.getBoundingClientRect();
        const vis = r.width > 6 && r.height > 6 && r.top < window.innerHeight - 2 && r.bottom > 2 && r.left < window.innerWidth && r.right > 0;
        if (!vis) continue;
        const key = label.toLowerCase();
        if (seen.has(key)) continue; seen.add(key);
        out.push({ label, role: e.getAttribute('role') || '', x: Math.round(r.left + r.width / 2), y: Math.round(r.top + r.height / 2), area: Math.round(r.width * r.height) });
      }
      return out;
    },
  ).catch(() => []);
}

// Tap every labelled button once (re-navigating to reset between taps) and shoot
// whatever it opens.
async function walkButtons(page, r, entry) {
  await gotoRoute(page, r);
  if (!(await enableSemantics(page))) {
    log(`  [interact] semantics unavailable on ${r.route} — skipping button walk`);
    entry.interaction = { semantics: false, buttons: [], shots: [] };
    return;
  }
  let btns = (await listInteractive(page)).filter((b) => !DENY.test(b.label));
  btns = btns.slice(0, r.cap || PER_SCREEN_CAP);
  entry.interaction = { semantics: true, buttons: btns.map((b) => b.label), shots: [] };
  for (const b of btns) {
    if (overBudget()) { log('  [interact] budget reached — stopping button walk'); break; }
    await gotoRoute(page, r);
    await enableSemantics(page);
    const node = (await listInteractive(page)).find((n) => n.label.toLowerCase() === b.label.toLowerCase());
    if (!node) continue;
    await page.mouse.click(node.x, node.y).catch(() => {});
    await page.waitForTimeout(SETTLE_TAP);
    const file = `${r.n}_${r.slug}__tap-${slugify(b.label)}.png`;
    entry.interaction.shots.push(await shoot(page, file));
    log(`  [interact] ${r.n} tapped "${b.label}" -> ${await hashPath(page)}`);
  }
}

// Wizard: tap the primary (largest) button N times, shooting each step.
async function runSequence(page, r, entry) {
  await gotoRoute(page, r);
  await enableSemantics(page);
  const steps = (r.sequence && r.sequence.taps) || 3;
  entry.sequence = { shots: [] };
  for (let s = 1; s <= steps; s++) {
    const btns = (await listInteractive(page)).filter((b) => !DENY.test(b.label)).sort((a, b) => b.area - a.area);
    if (!btns.length) break;
    await page.mouse.click(btns[0].x, btns[0].y).catch(() => {});
    await page.waitForTimeout(SETTLE_TAP);
    entry.sequence.shots.push(await shoot(page, `${r.n}_${r.slug}__step-${String(s + 1).padStart(2, '0')}.png`));
    log(`  [interact] ${r.n} sequence step ${s + 1}`);
  }
}

// ---- base route capture ---------------------------------------------------
async function captureRoute(page, r) {
  await gotoRoute(page, r);
  const landed = await hashPath(page);
  const landedRoute = '/' + landed;
  const redirected = landedRoute !== r.route;
  const frames = [await shoot(page, `${r.n}_${r.slug}_00.png`)];
  if (r.long) {
    for (let s = 1; s <= MAX_SCROLLS; s++) {
      await page.mouse.move(VIEWPORT.width / 2, VIEWPORT.height * 0.6);
      await page.mouse.wheel(0, Math.round(VIEWPORT.height * 0.82));
      await page.waitForTimeout(SETTLE_SCROLL);
      frames.push(await shoot(page, `${r.n}_${r.slug}_${String(s).padStart(2, '0')}.png`));
    }
  }
  log(`ok ${r.n} ${r.route} -> ${landedRoute}${redirected ? ' (REDIRECTED)' : ''} (${frames.length} frame[s])`);
  return { n: r.n, route: r.route, url: BASE + '/#' + r.route + (r.query || ''), label: r.label, design: r.design || [], landedHash: landedRoute, redirected, frames };
}

function writeIndex(out, manifest) {
  const total = manifest.reduce((a, m) => a + m.frames.length + (m.interaction ? m.interaction.shots.length : 0) + (m.sequence ? m.sequence.shots.length : 0), 0);
  let md = `# Ratel live screenshots — index\n\n`;
  md += `Captured ${new Date().toISOString()} · ${BASE} · ${VIEWPORT.width}x${VIEWPORT.height} @${DSF}x · ${manifest.length} routes · ${total} frames.\n\n`;
  md += `Naming: \`<SCREEN_MAP#>_<slug>_00\` = top of screen; \`_01/_02\` = scrolled; \`__step-NN\` = wizard step; \`__tap-<button>\` = sheet/dialog/sub-screen behind that button. \`x-...\` = a real route with no numbered design shot.\n\n`;
  md += `| # | Route | Label | Design | Frames | Sub-states | Note |\n|---|---|---|---|---|---|---|\n`;
  for (const m of manifest) {
    const sub = (m.interaction ? m.interaction.shots.length : 0) + (m.sequence ? m.sequence.shots.length : 0);
    md += `| ${m.n} | \`${m.route}\` | ${m.label} | ${(m.design || []).join(', ') || '—'} | ${m.frames.length} | ${sub || ''} | ${m.redirected ? 'redirected -> ' + m.landedHash : ''} |\n`;
  }
  md += `\n## Designed screens with no route\n\n`;
  for (const u of unrouted) md += `- **#${u.design.join('/')}** — ${u.label}\n`;
  fs.writeFileSync(path.join(out, 'INDEX.md'), md);
}

(async () => {
  const browser = await chromium.launch({ args: ['--no-sandbox', '--disable-dev-shm-usage', '--force-color-profile=srgb', '--hide-scrollbars'] });
  const context = await browser.newContext({
    viewport: VIEWPORT, deviceScaleFactor: DSF, isMobile: true, hasTouch: true,
    serviceWorkers: 'block', locale: 'en-US', colorScheme: 'light',
    userAgent: 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
  });
  await context.addInitScript(() => { try { window.localStorage.setItem('flutter.ratel.auth.choice', '"guest"'); } catch (e) {} });
  const page = await context.newPage();
  page.on('pageerror', (e) => log('pageerror:', String(e).slice(0, 160)));

  await enterGuest(page);

  const manifest = [];
  for (const r of routes) {
    const entry = await captureRoute(page, r);
    try {
      if (INTERACT && !overBudget()) {
        if (r.sequence) await runSequence(page, r, entry);
        if (r.interact) await walkButtons(page, r, entry);
      } else if (INTERACT && (r.interact || r.sequence)) {
        log(`time budget (${BUDGET_MS / 60000}m) reached — base-only from ${r.route} onward`);
      }
    } catch (e) { log(`interaction error on ${r.route}:`, e.message); }
    manifest.push(entry);
  }

  fs.writeFileSync(path.join(OUT, 'manifest.json'), JSON.stringify({ base: BASE, viewport: VIEWPORT, dsf: DSF, interact: INTERACT, capturedAt: new Date().toISOString(), routes: manifest, unrouted }, null, 2));
  writeIndex(OUT, manifest);
  const total = manifest.reduce((a, m) => a + m.frames.length + (m.interaction ? m.interaction.shots.length : 0) + (m.sequence ? m.sequence.shots.length : 0), 0);
  log(`done: ${total} screenshots across ${manifest.length} routes -> ${OUT}`);
  await browser.close();
})().catch((e) => { console.error(e); process.exit(1); });
