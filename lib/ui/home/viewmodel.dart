import 'dart:async';
import 'dart:ffi';

import 'package:app_music/data/model/song.dart';
import 'package:app_music/data/repository/repository.dart';

class MusicAppViewModel{
  StreamController<List<Song>> songStream = StreamController();
  StreamController<Double> percent = StreamController();

  void loadSongs(){
    final repository = DefaultRepository();
    repository.loadData().then((value) => songStream.add(value!));
  }
}