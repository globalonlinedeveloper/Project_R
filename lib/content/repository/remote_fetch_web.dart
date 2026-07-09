import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web remote-text fetch over the browser's `fetch` (js_interop — no new
/// deps; mirrors the audio/video relay seams). Returns the body text, or
/// null on ANY failure (network, non-2xx, timeout) so callers stay
/// fail-closed and ladder to the bundled asset.
Future<String?> fetchRemoteText(Uri url,
    {Duration timeout = const Duration(seconds: 4)}) async {
  try {
    final web.Response resp = await web.window
        .fetch(url.toString().toJS)
        .toDart
        .timeout(timeout);
    if (!resp.ok) return null;
    final JSString body = await resp.text().toDart.timeout(timeout);
    return body.toDart;
  } catch (_) {
    return null;
  }
}
