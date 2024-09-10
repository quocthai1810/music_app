import 'dart:math';

import 'package:app_music/boxes.dart';
import 'package:app_music/data/model/song.dart';
import 'package:app_music/favor_song.dart';
import 'package:app_music/main.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../songs.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying(
      {super.key,
      required this.playingSong,
      required this.songs,
      required this.audioPlayerManagers});

  final Songs playingSong;
  final List<Songs> songs;
  final List<AudioPlayerManager> audioPlayerManagers;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
        songs: songs,
        playingSong: playingSong,
        audioPlayerManagers: audioPlayerManagers);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key,
      required this.playingSong,
      required this.songs,
      required this.audioPlayerManagers});

  final Songs playingSong;
  final List<Songs> songs;
  final List<AudioPlayerManager> audioPlayerManagers;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Songs _song;
  bool isPlay = false;
  bool _isRepeat = false;
  bool _isShuffle = false;
  bool test = true;
  int selected = 2;
  late bool favor;
  late int index;

  int getIndex(Box box, Songs song) {
    var index = 0;
    for (var s in box.values) {
      if (song.id != s.id) {
        index += 1;
      } else {
        break;
      }
    }
    return index;
  }

  int getIndexByList(List list, Songs song) {
    var index = 0;
    for (var s in list) {
      if (song.id != s.id) {
        index += 1;
      } else {
        break;
      }
    }
    return index;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _song = widget.playingSong;
    _audioPlayerManager = AudioPlayerManager(songUrl: _song.source);
    _audioPlayerManager.init();
    // widget.audioPlayerManagers.add(_audioPlayerManager);

    _selectedItemIndex = getIndexByList(widget.songs, _song);

    print(_selectedItemIndex);
    _audioPlayerManager.player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed &&
          !_isRepeat) {
        _nextSong();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayerManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    favor = boxSongs.getAt(getIndex(boxSongs, _song)).favor;
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Now Playing'),
          trailing:
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Text(_song.album,
                      style: const TextStyle(
                          fontSize: 17,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text('_ ___ _'),
                const SizedBox(
                  height: 32,
                ),
                circularProgress(),
                Padding(
                  padding: const EdgeInsets.only(top: 54, bottom: 16),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        popupMenu(),
                        Column(
                          children: [
                            Container(
                              width: 200,
                              height: 30,
                              child: getTextMarquee(_song.title),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              _song.artist,
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            )
                          ],
                        ),
                        ValueListenableBuilder(
                            valueListenable: boxSongs.listenable(),
                            builder: (context, boxSongs, widget) {
                              return IconButton(
                                onPressed: () {
                                  isFavorSong();
                                  if (favor) {
                                    const snackBar = SnackBar(
                                      content:
                                          Text('Đã thêm vào danh mục Favorite'),
                                      backgroundColor: Colors.purple,
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    const snackBar = SnackBar(
                                      content:
                                          Text('Đã xóa khỏi danh mục Favorite'),
                                      backgroundColor: Colors.purple,
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                },
                                icon: boxSongs
                                        .getAt(getIndex(boxSongs, _song))
                                        .favor
                                    ? Icon(Icons.favorite)
                                    : Icon(Icons.favorite_border),
                                color: Theme.of(context).colorScheme.primary,
                                iconSize: 40,
                              );
                            })
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 32, left: 24, right: 24, bottom: 16),
                  child: _progressBar(),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 0, left: 24, right: 24, bottom: 0),
                  child: _mediaButtons(),
                )
              ],
            ),
          ),
        ));
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: _setShuffle,
              icon: Icons.shuffle,
              color: _getShuffleColor(),
              size: 24),
          MediaButtonControl(
              function: _previousSong,
              icon: Icons.skip_previous,
              color: null,
              size: 36),
          _playButton(),
          MediaButtonControl(
              function: _nextSong,
              icon: Icons.skip_next,
              color: null,
              size: 36),
          MediaButtonControl(
              function: _setRepeat,
              icon: Icons.repeat,
              color: _getRepeatColor(),
              size: 24),
        ],
      ),
    );
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

  void _setRepeat() {
    test = !test;
    setState(() {
      _isRepeat = !_isRepeat;
    });
    if (_isRepeat == true) {
      _audioPlayerManager.player.setLoopMode(LoopMode.one);
    } else {
      _audioPlayerManager.player.setLoopMode(LoopMode.off);
    }
  }

  Color? _getRepeatColor() {
    return _isRepeat ? Colors.deepPurple : Colors.grey;
  }

  void _nextSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else {
      if (_selectedItemIndex < widget.songs.length - 1) {
        ++_selectedItemIndex;
      }
    }
    if (_selectedItemIndex > widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
  }

  void _previousSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else {
      if (_selectedItemIndex > 0) {
        --_selectedItemIndex;
      }
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayerManager.player.seek,
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return Container(
              margin: const EdgeInsets.all(8),
              width: 48,
              height: 48,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true &&
              processingState == ProcessingState.ready) {
            if (isPlay == false) {
              //     // if (widget.audioPlayerManagers.length > 1) {
              //     //   var prevSong = widget.audioPlayerManagers.removeAt(0);
              //     //   prevSong.dispose();
              //     // }
              //
              _audioPlayerManager.player.play();
              isPlay = true;
            }
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.play();
                },
                icon: Icons.play_arrow,
                color: null,
                size: 48);
          } else if (processingState != ProcessingState.completed) {
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.pause();
                },
                icon: Icons.pause,
                color: null,
                size: 48);
          } else {
            if (processingState == ProcessingState.completed) {}
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.seek(Duration.zero);
                },
                icon: Icons.replay,
                color: null,
                size: 48);
          }
        });
  }

  circularProgress() {
    return StreamBuilder(
        stream: _audioPlayerManager.durationState2,
        builder: ((context, snapshot) {
          final screenWidth = MediaQuery.of(context).size.width;
          const delta = 64;
          final radius = (screenWidth - delta) / 2;
          final percentState = snapshot.data;
          var positionPercent = percentState?.progress.inSeconds.toDouble();
          var total = _audioPlayerManager.player.duration?.inSeconds.toDouble();
          total ??= 0.000000000000000001;
          positionPercent ??= 0.0;
          final position = positionPercent / total;
          return CircularPercentIndicator(
              radius: radius + 10,
              animation: true,
              animateFromLastPercent: true,
              progressColor: Colors.purple,
              percent: position,
              center: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/itune.jpg',
                  image: _song.image,
                  width: screenWidth - delta,
                  height: screenWidth - delta,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/itune.jpg',
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                    );
                  },
                ),
              ));
        }));
  }

  Widget popupMenu() {
    return PopupMenuButton(
      initialValue: selected,
      onSelected: (item) => setState(() {
        selected = item;
      }),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            _audioPlayerManager.player.setSpeed(0.5);
          },
          value: 0,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('x0.5'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            _audioPlayerManager.player.setSpeed(0.75);
          },
          value: 1,
          child: const Text('x0.75'),
        ),
        PopupMenuItem(
          onTap: () {
            _audioPlayerManager.player.setSpeed(1);
          },
          value: 2,
          child: const Text('x1.0'),
        ),
        PopupMenuItem(
          onTap: () {
            _audioPlayerManager.player.setSpeed(1.25);
          },
          value: 3,
          child: const Text('x1.25'),
        ),
        PopupMenuItem(
          onTap: () {
            _audioPlayerManager.player.setSpeed(1.5);
          },
          value: 4,
          child: const Text('x1.5'),
        ),
      ],
      icon: Icon(
        Icons.speed,
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
      offset: const Offset(50, -170),
    );
  }

  void isFavorSong() async {
    favor = !favor;
    if (favor) {
      await boxFavorSong.add(FavorSong(
          id: _song.id,
          title: _song.title,
          album: _song.album,
          artist: _song.artist,
          source: _song.source,
          image: _song.image,
          duration: _song.duration,
          favor: favor));

      await boxSongs.putAt(
          getIndex(boxSongs, _song),
          Songs(
              id: _song.id,
              title: _song.title,
              album: _song.album,
              artist: _song.artist,
              source: _song.source,
              image: _song.image,
              duration: _song.duration,
              favor: favor));
    } else {
      await boxSongs.putAt(
          getIndex(boxSongs, _song),
          Songs(
              id: _song.id,
              title: _song.title,
              album: _song.album,
              artist: _song.artist,
              source: _song.source,
              image: _song.image,
              duration: _song.duration,
              favor: favor));
      boxFavorSong.deleteAt(getIndex(boxFavorSong, _song));
      // boxFavorSong.deleteAll(boxFavorSong.keys);
    }
  }

  getTextMarquee(String title) {
    if(hasTextOverflow(title, const TextStyle(
        fontSize: 23, color: Colors.deepPurple), 1)){
      return Marquee(text: _song.title+'      ', style: const TextStyle(
          fontSize: 23, color: Colors.deepPurple),);
    }
    else{
      return Center(
        child: Text(_song.title, style: const TextStyle(
            fontSize: 23, color: Colors.deepPurple),),
      );
    }
  }

  bool hasTextOverflow(
      String text,
      TextStyle style,
      double textScaleFactor,
      {double minWidth = 0,
        double maxWidth = double.infinity,
        int maxLines = 1
      }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      textScaleFactor: textScaleFactor,
    )..layout(minWidth: minWidth, maxWidth: 200);
    return textPainter.didExceedMaxLines;
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final Color? color;
  final double? size;

  @override
  State<StatefulWidget> createState() {
    return _MediaButtonControlState();
  }
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
