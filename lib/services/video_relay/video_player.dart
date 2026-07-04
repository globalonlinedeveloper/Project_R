import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Compile-time platform split: web => browser HTMLVideoElement; else Unavailable.
import 'video_player_stub.dart'
    if (dart.library.js_interop) 'video_player_web.dart';

/// Watch video-playback seam (INF-9) -- the video analogue of [PodcastAudio].
/// A Watch passage (content `passage`, kind=video) carries a REAL pre-generated,
/// language-neutral MP4 (its `video_ref` -> a `media_asset` uri on Cloudflare
/// R2). On the web this seam embeds that URL directly in a browser
/// `<video controls>` element (an [HtmlElementView] platform view -- no plugin,
/// no key, no server). It is INDEPENDENT of the audio/speech seams.
///
/// Honesty: [isAvailable] is false on every non-web build and in all tests (the
/// stub factory), so the player degrades to a poster + the transcript there --
/// it never offers a video surface it cannot render. The single shared MP4 is
/// wordless, so the target-language content (narration + questions) is all data.
// R-D5 (watch) - R-B3: pre-generated video delivery on web.
abstract interface class VideoRelay {
  /// False => the UI must NOT offer the video player (it shows a poster + the
  /// transcript instead).
  bool get isAvailable;

  /// A widget that renders the MP4 at [url] (a browser `<video>` platform view
  /// on web). Only meaningful when [isAvailable]; the stub never calls it.
  Widget viewFor(String url);
}

/// Default (non-web / tests): never available => the player shows a poster +
/// transcript. Parity with `UnavailablePodcastAudio`.
class UnavailableVideoRelay implements VideoRelay {
  const UnavailableVideoRelay();
  @override
  bool get isAvailable => false;
  @override
  Widget viewFor(String url) => const SizedBox.shrink();
}

/// Resolved at compile time by [createVideoRelay] (web vs stub). Tests may
/// override with a fake available impl to exercise the live-player branch.
final videoRelayProvider =
    Provider<VideoRelay>((ref) => createVideoRelay());
