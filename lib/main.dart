import 'package:app_music/favor_song.dart';
import 'package:app_music/ui/home/home.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';

void main()async {
  await Hive.initFlutter();
  Hive.registerAdapter(FavorSongAdapter());
  boxFavorSong = await Hive.openBox<FavorSong>('favorSongBox');
  runApp(const MusicApp());
}
