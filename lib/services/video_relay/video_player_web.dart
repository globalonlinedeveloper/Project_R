import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import 'video_player.dart';

/// Web factory: a real browser `<video controls>` element embedded via an
/// [HtmlElementView] platform view (built into every modern browser -- no
/// dependency beyond `package:web`, no key, no server). Only compiled on the web
/// target (guarded by the `dart.library.js_interop` conditional import in
/// video_player.dart). Mirrors how audio_player_web.dart plays the R2 MP3.
VideoRelay createVideoRelay() => WebVideoRelay();

class WebVideoRelay implements VideoRelay {
  /// One registered view factory per distinct URL (registration is idempotent
  /// and cheap; the engine caches by viewType).
  final Set<String> _registered = <String>{};

  @override
  bool get isAvailable => true;

  @override
  Widget viewFor(String url) {
    final String viewType = 'ratel-video-${url.hashCode}';
    if (_registered.add(viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final web.HTMLVideoElement el = web.HTMLVideoElement()
            ..src = url
            ..controls = true
            ..preload = 'metadata'
            ..setAttribute('playsinline', 'true');
          el.style
            ..width = '100%'
            ..height = '100%'
            ..objectFit = 'contain'
            ..backgroundColor = 'black'
            ..border = '0';
          return el;
        },
      );
    }
    return HtmlElementView(viewType: viewType);
  }
}
