import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-contract for the versioned offline PWA service worker (PROJECT_STATE
/// lane "L-1"; session-craft §18). These run inside the `flutter test` gate and
/// pin the two properties the worker exists to hold so they can never silently
/// regress: (1) the app shell + Flutter app-code are NETWORK-FIRST, so a fresh
/// deploy is never masked by a stale cache — the reason the site had shipped with
/// `--pwa-strategy=none` and no worker at all; and (2) the app is genuinely
/// offline-capable with VERSIONED, self-purging caches. The behavioural proof
/// (real cache/fetch mocks exercising each strategy) lives in the Node test
/// `test/web/service_worker.logic.test.mjs`, run by CI's `web-pwa-gate` job.
///
/// Live evidence for R-L13 (Offline mode & caching): before this worker the
/// site shipped with `--pwa-strategy=none` and no offline capability at all.
void main() {
  final String sw = File('web/service_worker.js').readAsStringSync();
  final String index = File('web/index.html').readAsStringSync();

  test('the service worker exists and is non-trivial', () {
    expect(File('web/service_worker.js').existsSync(), isTrue);
    expect(sw.length, greaterThan(1000));
  });

  test('index.html registers the worker, feature-detected + updateViaCache:none', () {
    expect(index, contains("'serviceWorker' in navigator"));
    expect(index, contains("register('service_worker.js'"));
    expect(index, contains("updateViaCache: 'none'"));
  });

  test('caches are versioned and older generations are purged on activate', () {
    expect(sw, contains('SW_VERSION'));
    expect(sw, contains('RUNTIME_CACHE'));
    expect(sw, contains("addEventListener('activate'"));
    expect(sw, contains('caches.delete'));
    expect(sw, contains('clients.claim'));
  });

  test('a new worker takes control promptly (skipWaiting)', () {
    expect(sw, contains('skipWaiting'));
  });

  test('the app shell + app code are network-first (kills the stale-bundle bug)', () {
    expect(sw, contains("request.mode === 'navigate'"));
    expect(sw, contains('flutter_bootstrap.js'));
    expect(sw, contains('main.dart.js'));
    expect(sw, contains('networkFirst'));
  });

  test('secondary assets are cached for offline via stale-while-revalidate', () {
    expect(sw, contains('staleWhileRevalidate'));
  });

  test('cross-origin + non-GET requests are never intercepted or cached', () {
    expect(sw, contains('url.origin !== self.location.origin'));
    expect(sw, contains("request.method !== 'GET'"));
  });

  test('Flutter generates no competing worker (pwa-strategy=none kept in CI)', () {
    for (final String wf in <String>['ci.yml', 'deploy-web.yml', 'build-matrix.yml']) {
      final String f = File('.github/workflows/$wf').readAsStringSync();
      expect(f, contains('--pwa-strategy=none'),
          reason: '$wf must keep Flutter\'s own SW disabled so ours is the only worker');
    }
  });
}
