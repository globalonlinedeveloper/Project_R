import 'audio_player.dart';

/// Non-web / VM / test factory: podcast audio playback is unavailable, so the
/// player degrades honestly to the transcript (+ optional browser read-aloud).
PodcastAudio createPodcastAudio() => const UnavailablePodcastAudio();
