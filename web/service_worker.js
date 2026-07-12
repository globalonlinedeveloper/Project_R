// Ratel service worker — versioned, offline-capable PWA shell.
//
// WHY THIS EXISTS (PROJECT_STATE lane "L-1"; session-craft §18):
//   The site historically shipped with `flutter build web --pwa-strategy=none`
//   (i.e. NO service worker) because Flutter's built-in offline-first worker
//   serves a STALE cached bundle for one reload after every deploy — real users
//   reloaded, saw the OLD shell, and concluded nothing had shipped. That stopgap
//   also left the app with ZERO offline capability, so the "offline" PRO-marketing
//   claim was unbacked.
//
//   This worker fixes both, honestly and without the stale trap:
//     * APP SHELL + app code (navigations, flutter_bootstrap.js, main.dart.js,
//       flutter.js) are NETWORK-FIRST -> an online visitor ALWAYS gets the newest
//       deploy; the cache is used only as an offline fallback. This is the exact
//       property whose absence forced --pwa-strategy=none.
//     * Secondary same-origin assets (canvaskit, fonts, icons, bundled JSON) use
//       STALE-WHILE-REVALIDATE -> instant from cache, refreshed in the background;
//       this is what actually makes the shell usable OFFLINE after a first visit.
//     * Cross-origin requests (Supabase, the R2 content CDN, the AI relay) are
//       NEVER intercepted or cached — dynamic/auth'd data must always hit network.
//     * Caches are VERSIONED (names carry SW_VERSION); `activate` purges every
//       older generation, so a strategy bump cleanly evicts stale caches.
//     * skipWaiting + clients.claim (+ registration updateViaCache:'none' in
//       index.html) -> a new worker takes control promptly; no client is left on
//       a superseded worker.
//
//   The worker is a PROGRESSIVE ENHANCEMENT: every strategy falls back to the
//   network on error, so a bad cache can never brick the app.

const SW_VERSION = 'v1';
const SHELL_CACHE = 'ratel-shell-' + SW_VERSION;
const RUNTIME_CACHE = 'ratel-runtime-' + SW_VERSION;
const CACHE_ALLOWLIST = [SHELL_CACHE, RUNTIME_CACHE];

// Stable-named entry points, precached so the FIRST offline load works.
// Hashed/secondary assets are populated at runtime by stale-while-revalidate.
const SHELL_ASSETS = ['./', 'index.html', 'flutter_bootstrap.js', 'manifest.json', 'favicon.png'];

const OFFLINE_HTML =
  '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">' +
  '<title>Offline — Ratel</title>' +
  '<body style="font-family:system-ui,sans-serif;padding:2.5rem;color:#1c1c1c;background:#E4E0D5">' +
  '<h1>You are offline</h1><p>Reconnect to load the latest Ratel.</p></body>';

// App code + documents that must be FRESH whenever the network is reachable.
function isAppCode(pathname) {
  return /\/(flutter_bootstrap\.js|main\.dart\.js|flutter\.js|flutter_service_worker\.js)$/.test(pathname);
}

self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(SHELL_CACHE)
      .then(function (cache) { return cache.addAll(SHELL_ASSETS); })
      .catch(function () { /* never fail install on one missing asset */ })
      .then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys()
      .then(function (keys) {
        return Promise.all(keys
          .filter(function (k) { return k.indexOf('ratel-') === 0 && CACHE_ALLOWLIST.indexOf(k) === -1; })
          .map(function (k) { return caches.delete(k); }));
      })
      .then(function () { return self.clients.claim(); })
  );
});

// Navigations: network-first, refresh the cached shell, fall back to it offline.
async function handleNavigation(request) {
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      const cache = await caches.open(SHELL_CACHE);
      cache.put('index.html', response.clone());
    }
    return response;
  } catch (e) {
    const cache = await caches.open(SHELL_CACHE);
    const shell = (await cache.match('index.html')) || (await cache.match('./'));
    if (shell) return shell;
    return new Response(OFFLINE_HTML, { status: 503, headers: { 'Content-Type': 'text/html; charset=utf-8' } });
  }
}

// App code: network-first (freshest deploy online), cache fallback offline.
async function networkFirst(request, cacheName) {
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
    }
    return response;
  } catch (e) {
    const cached = await caches.match(request);
    return cached || Response.error();
  }
}

// Assets: serve cache immediately, revalidate in the background.
async function staleWhileRevalidate(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);
  const network = fetch(request)
    .then(function (response) {
      if (response && response.ok) cache.put(request, response.clone());
      return response;
    })
    .catch(function () { return cached; });
  return cached || network;
}

self.addEventListener('fetch', function (event) {
  const request = event.request;
  if (request.method !== 'GET') return;                 // never cache mutations
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;      // never touch cross-origin (Supabase / R2 / AI relay)

  if (request.mode === 'navigate') {
    event.respondWith(handleNavigation(request));
  } else if (isAppCode(url.pathname)) {
    event.respondWith(networkFirst(request, SHELL_CACHE));
  } else {
    event.respondWith(staleWhileRevalidate(request, RUNTIME_CACHE));
  }
});
