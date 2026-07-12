// Behavioural test for web/service_worker.js — runs the REAL worker source in a
// node:vm sandbox with mocked Cache/fetch/clients and dispatches synthetic
// install/activate/fetch events. Proves the caching STRATEGIES behave correctly
// (a source string-match cannot catch a logic inversion like cache-first where
// network-first is required). Run in CI by the `web-pwa-gate` job: `node --test`.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

const SW_SOURCE = readFileSync('web/service_worker.js', 'utf8');
const ORIGIN = 'https://learnwithratel.com';
const absUrl = (k) => new URL(typeof k === 'string' ? k : k.url, ORIGIN + '/').href;

class MockCache {
  constructor() { this.map = new Map(); }
  async match(req) { return this.map.get(absUrl(req)); }
  async put(req, res) { this.map.set(absUrl(req), res); }
  async addAll(list) { for (const k of list) this.map.set(absUrl(k), new Response('precached', { status: 200 })); }
}

function makeEnv({ online = true, seed = {} } = {}) {
  const stores = new Map();
  for (const [name, entries] of Object.entries(seed)) {
    const c = new MockCache();
    for (const [k, v] of Object.entries(entries)) c.map.set(absUrl(k), v);
    stores.set(name, c);
  }
  const caches = {
    async open(name) { if (!stores.has(name)) stores.set(name, new MockCache()); return stores.get(name); },
    async match(req) { for (const c of stores.values()) { const r = await c.match(req); if (r) return r; } return undefined; },
    async keys() { return [...stores.keys()]; },
    async delete(name) { return stores.delete(name); },
  };
  const fetchCalls = [];
  const listeners = {};
  const ctx = {
    caches, console, Response, Request, URL,
    location: { origin: ORIGIN },
    fetch: async (req) => {
      const u = typeof req === 'string' ? req : req.url;
      fetchCalls.push(u);
      if (!online) throw new TypeError('Failed to fetch');
      return new Response('network:' + u, { status: 200, headers: { 'Content-Type': 'text/plain' } });
    },
    clients: { claimed: false, claim() { this.claimed = true; return Promise.resolve(); } },
    skipWaiting() { ctx._skipWaiting = true; return Promise.resolve(); },
    addEventListener: (type, handler) => { listeners[type] = handler; },
  };
  ctx.self = ctx;
  vm.createContext(ctx);
  vm.runInContext(SW_SOURCE, ctx);
  return { ctx, listeners, stores, fetchCalls };
}

const req = (url, { mode = 'no-cors', method = 'GET' } = {}) =>
  ({ url: absUrl(url), mode, method });

async function runLifecycle(listener) {
  let p; listener({ waitUntil: (x) => { p = x; } }); await p;
}
async function runFetch(listeners, request) {
  let responded = false, value;
  listeners.fetch({ request, respondWith: (x) => { responded = true; value = x; }, waitUntil: () => {} });
  return { responded, response: responded ? await value : undefined };
}

test('install precaches the shell and calls skipWaiting', async () => {
  const { ctx, listeners, stores } = makeEnv();
  await runLifecycle(listeners.install);
  assert.equal(ctx._skipWaiting, true);
  const shell = stores.get('ratel-shell-v1');
  assert.ok(shell && shell.map.size >= 5, 'shell assets precached');
  assert.ok(await shell.match('index.html'));
});

test('activate purges older cache generations and claims clients', async () => {
  const { ctx, listeners, stores } = makeEnv({
    seed: { 'ratel-shell-v0': { old: new Response('x') }, 'ratel-runtime-v0': { old: new Response('y') }, 'ratel-shell-v1': {} },
  });
  await runLifecycle(listeners.activate);
  assert.equal(stores.has('ratel-shell-v0'), false, 'old shell purged');
  assert.equal(stores.has('ratel-runtime-v0'), false, 'old runtime purged');
  assert.equal(stores.has('ratel-shell-v1'), true, 'current kept');
  assert.equal(ctx.clients.claimed, true);
});

test('NAVIGATION online returns the fresh network shell (no stale bundle)', async () => {
  const { listeners } = makeEnv({ online: true, seed: { 'ratel-shell-v1': { 'index.html': new Response('STALE', { status: 200 }) } } });
  const { responded, response } = await runFetch(listeners, req('/', { mode: 'navigate' }));
  assert.ok(responded);
  assert.match(await response.text(), /^network:/);
});

test('NAVIGATION offline falls back to the cached shell', async () => {
  const { listeners } = makeEnv({ online: false, seed: { 'ratel-shell-v1': { 'index.html': new Response('CACHED-SHELL', { status: 200 }) } } });
  const { response } = await runFetch(listeners, req('/deep/route', { mode: 'navigate' }));
  assert.equal(await response.text(), 'CACHED-SHELL');
});

test('NAVIGATION offline with no cache yields the 503 offline page', async () => {
  const { listeners } = makeEnv({ online: false });
  const { response } = await runFetch(listeners, req('/', { mode: 'navigate' }));
  assert.equal(response.status, 503);
  assert.match(await response.text(), /offline/i);
});

test('APP CODE online is network-first (fresh over a stale cache)', async () => {
  const { listeners } = makeEnv({ online: true, seed: { 'ratel-shell-v1': { '/flutter_bootstrap.js': new Response('STALE-BOOT', { status: 200 }) } } });
  const { response } = await runFetch(listeners, req('/flutter_bootstrap.js'));
  assert.match(await response.text(), /^network:/, 'must serve network, not the stale cache');
});

test('APP CODE offline falls back to cache', async () => {
  const { listeners } = makeEnv({ online: false, seed: { 'ratel-shell-v1': { '/main.dart.js': new Response('CACHED-MAIN', { status: 200 }) } } });
  const { response } = await runFetch(listeners, req('/main.dart.js'));
  assert.equal(await response.text(), 'CACHED-MAIN');
});

test('ASSET is stale-while-revalidate (cache served immediately when present)', async () => {
  const { listeners, fetchCalls } = makeEnv({ online: true, seed: { 'ratel-runtime-v1': { '/assets/fonts/x.otf': new Response('CACHED-FONT', { status: 200 }) } } });
  const { response } = await runFetch(listeners, req('/assets/fonts/x.otf'));
  assert.equal(await response.text(), 'CACHED-FONT');
  assert.ok(fetchCalls.some((u) => u.endsWith('/assets/fonts/x.otf')), 'revalidates in the background');
});

test('ASSET not cached falls through to network and populates the runtime cache', async () => {
  const { listeners, stores } = makeEnv({ online: true });
  const { response } = await runFetch(listeners, req('/assets/img/logo.png'));
  assert.match(await response.text(), /^network:/);
  const runtime = stores.get('ratel-runtime-v1');
  assert.ok(runtime && await runtime.match('/assets/img/logo.png'), 'asset cached for offline');
});

test('CROSS-ORIGIN requests are never intercepted (Supabase / R2 / AI relay)', async () => {
  const { listeners } = makeEnv();
  const { responded } = await runFetch(listeners, req('https://fkbmodjtxatrqcghhfba.supabase.co/rest/v1/x', { mode: 'cors' }));
  assert.equal(responded, false, 'cross-origin must pass straight through to the network');
});

test('NON-GET requests are never intercepted or cached', async () => {
  const { listeners } = makeEnv();
  const { responded } = await runFetch(listeners, req('/', { mode: 'navigate', method: 'POST' }));
  assert.equal(responded, false);
});
