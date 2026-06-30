import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Which media item is loaded into the player and whether it's playing.
class AudioState {
  const AudioState({this.mediaId, this.playing = false});

  final String? mediaId;
  final bool playing;

  AudioState copyWith({String? mediaId, bool? playing}) => AudioState(
        mediaId: mediaId ?? this.mediaId,
        playing: playing ?? this.playing,
      );
}

/// A single shared just_audio player (book chapters, ringtones, …). AutoDispose
/// so audio stops when the last listening screen closes.
final audioControllerProvider =
    StateNotifierProvider.autoDispose<AudioController, AudioState>((ref) {
  return AudioController();
});

class AudioController extends StateNotifier<AudioState> {
  AudioController() : super(const AudioState()) {
    _player.playerStateStream.listen((PlayerState s) {
      if (mounted) state = state.copyWith(playing: s.playing);
    });
  }

  final AudioPlayer _player = AudioPlayer();

  /// Play media [id] from [url], or pause/resume if it's already current.
  Future<void> toggle(String id, String url) async {
    try {
      if (state.mediaId == id) {
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
        return;
      }
      state = AudioState(mediaId: id);
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {
      // Audio is best-effort; ignore network/codec failures.
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
