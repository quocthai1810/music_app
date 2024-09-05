import 'package:app_music/data/model/song.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  AudioPlayerManager({
    required this.songUrl,
  });

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  Stream<DurationState>? durationState2;
  String songUrl;

  void init() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
        (position, playbackEvent) => DurationState(
            progress: position,
            buffered: playbackEvent.bufferedPosition,
            total: playbackEvent.duration));
    durationState2 = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
            (position, playbackEvent) => DurationState(
            progress: position,
            buffered: playbackEvent.bufferedPosition,
            total: playbackEvent.duration));
    player.setUrl(songUrl);
  }

  void updateSongUrl(String url) {
    songUrl = url;
    init();
  }

  void stop() {
    player.stop();
  }

  void dispose() {
    player.dispose();
  }
}

class DurationState {
  DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}
