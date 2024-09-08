import 'package:app_music/boxes.dart';
import 'package:app_music/favor_song.dart';
import 'package:app_music/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../now_playing/audio_player_manager.dart';
import '../now_playing/playing.dart';
import '../songs.dart';

class FavorTab extends StatelessWidget {
  const FavorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const FavorTabPage();
  }
}

class FavorTabPage extends StatefulWidget {
  const FavorTabPage({super.key});

  @override
  State<FavorTabPage> createState() => _FavorTabPageState();
}

class _FavorTabPageState extends State<FavorTabPage> {
  List<AudioPlayerManager> audioPlayerManagers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getUI());
  }

  Widget getRow(int index) {
    List rev = boxFavorSong.values.toList();
    rev = rev.reversed.toList();
    return _SongItemSection(parent: this, song: rev[index]);
  }

  void navigate(FavorSong song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      Songs song2 = Songs(
          id: song.id,
          title: song.title,
          album: song.album,
          artist: song.artist,
          source: song.source,
          image: song.image,
          duration: song.duration,
          favor: song.favor);
      List<Songs> songs2 = [];
      for (var song in boxFavorSong.values) {
        songs2.add(Songs(
            id: song.id,
            title: song.title,
            album: song.album,
            artist: song.artist,
            source: song.source,
            image: song.image,
            duration: song.duration,
            favor: song.favor));
      }
      songs2 = songs2.reversed.toList();
      print(songs2.toString());
      return NowPlaying(
        songs: songs2,
        playingSong: song2,
        audioPlayerManagers: audioPlayerManagers,
      );
    }));
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 400,
              color: Colors.grey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Modal Bottom Sheet'),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close Bottom Sheet'))
                  ],
                ),
              ),
            ),
          );
        });
  }

  getUI() {
    return ValueListenableBuilder(valueListenable: boxFavorSong.listenable(), builder: (context,boxFavorSong,widget){
      return boxFavorSong.isEmpty ? const Center(
          child: Text('Danh mục Favorite trống !')) : ListView.separated(
          itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
      return const Divider(
      color: Colors.grey,
      thickness: 1,
      indent: 10,
      endIndent: 10,
      );
      },
      itemCount: boxFavorSong.length,
      shrinkWrap: true,
      );
    });

    if (boxFavorSong.isEmpty) {
      return const Center(
        child: Text('Danh mục Favorite trống !'),
      );
    } else {
      return ListView.separated(
        itemBuilder: (context, position) {
          return getRow(position);
        },
        separatorBuilder: (context, index) {
          return const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 10,
            endIndent: 10,
          );
        },
        itemCount: 1,
        shrinkWrap: true,
      );
    }
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
  });

  final _FavorTabPageState parent;
  final FavorSong song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itune.jpg',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/itune.jpg', width: 48, height: 48);
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {

          // parent.showBottomSheet();
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
    throw UnimplementedError();
  }
}
