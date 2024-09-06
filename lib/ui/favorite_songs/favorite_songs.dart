import 'package:app_music/boxes.dart';
import 'package:app_music/favor_song.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  late List<FavorSong> songs = [];
  List<AudioPlayerManager> audioPlayerManagers = [];
  @override
  void initState() {
    for (var s in boxFavorSong.values){
      songs.add(s);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.separated(
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
          itemCount: songs.length,
          shrinkWrap: true,
        ),
      ),
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(parent: this, song: songs[index]);
  }

  void navigate(FavorSong song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      Songs song2 = Songs(id: song.id, title: song.title, album: song.album, artist: song.artist, source: song.source, image: song.image, duration: song.duration, favor: song.favor);
      List<Songs> songs2 =[];
      for (var song in songs){
        songs2.add(Songs(id: song.id, title: song.title, album: song.album, artist: song.artist, source: song.source, image: song.image, duration: song.duration, favor: song.favor));
      }
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
}

class _SongItemSection extends StatelessWidget {
  _SongItemSection({
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
          parent.showBottomSheet();
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
    throw UnimplementedError();
  }


}
