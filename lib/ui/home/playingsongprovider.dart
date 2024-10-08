import 'package:flutter/material.dart';
import 'package:app_music/data/model/song.dart';

import '../songs.dart';

class PlayingSongProvider extends ChangeNotifier {
  Songs? _playingSong;

  Songs? get playingSong => _playingSong;

  void updatePlayingSong(Songs newSong) {
    _playingSong = newSong;
    notifyListeners(); // Thông báo để cập nhật UI
  }
}