import 'video_player.dart';

/// Non-web / VM / test factory: video playback is unavailable, so the player
/// degrades honestly to a poster + the transcript (+ comprehension checks).
VideoRelay createVideoRelay() => const UnavailableVideoRelay();
