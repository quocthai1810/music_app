import 'package:app_music/favor_song.dart';
import 'package:app_music/ui/home/home.dart';
import 'package:app_music/ui/songs.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';

void main()async {
WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FavorSongAdapter());
  boxFavorSong = await Hive.openBox<FavorSong>('favorSongBox');
  Hive.registerAdapter(SongsAdapter());
  boxSongs = await Hive.openBox<Songs>('songsBox');
  runApp(const MusicApp());
}
