import 'dart:async';
import 'dart:ffi';

import 'package:app_music/data/model/song.dart';
import 'package:app_music/data/repository/repository.dart';

import '../songs.dart';

class MusicAppViewModel{
  StreamController<List<Songs>> songStream = StreamController();
  StreamController<Double> percent = StreamController();

  void loadSongs(){
    final repository = DefaultRepository();
    repository.loadData().then((value) => songStream.add(value!));
  }
}