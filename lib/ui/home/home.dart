import 'package:app_music/Provider/provider.dart';
import 'package:app_music/main.dart';
import 'package:app_music/ui/favorite_songs/favorite_songs.dart';
import 'package:app_music/ui/home/playingsongprovider.dart';
import 'package:app_music/ui/home/viewmodel.dart';
import 'package:app_music/ui/now_playing/audio_player_manager.dart';
import 'package:app_music/ui/settings/settings.dart';
import 'package:app_music/ui/songs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../../boxes.dart';
import '../../data/model/song.dart';
import '../../favor_song.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
          UiProvider()
            ..init(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              PlayingSongProvider(), // Thêm provider quản lý playingSong
        ),
      ],
      child: Consumer<UiProvider>(
        builder: (context, UiProvider notifier, child) {
          return MaterialApp(
            title: 'Music App',
            themeMode: notifier.isDark ? ThemeMode.dark : ThemeMode.light,
            darkTheme:
            notifier.isDark ? notifier.darkTheme : notifier.lightTheme,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
              useMaterial3: true,
            ),
            home: const MusicHomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const FavorTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Music App'),
        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .onInverseSurface,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: 'Favorite'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ]),
          tabBuilder: (BuildContext context, int index) {
            return _tabs[index];
          },
        ));
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  late AudioPlayerManager _audioPlayerManager;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  List<Songs> songs = [];
  late MusicAppViewModel _viewModel;
  List<AudioPlayerManager> audioPlayerManagers = [];
  late bool favor;
  List<Songs> _foundSongs = [];
  bool isTap = false;
  late Songs nowSong;
  bool isPlay = false;

  //hàm gán các dữ liệu trước khi tạo Widget
  @override
  void initState() {
    _scrollController.addListener(() {
      // Hiện nút khi cuộn xuống
      if (_scrollController.offset >= 200) {
        setState(() {
          _showScrollToTopButton = true;
        });
      } else {
        setState(() {
          _showScrollToTopButton = false;
        });
      }
    });
    _foundSongs = songs;
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
    super.initState();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _runFilter(String enteredKeyword) {
    List<Songs> results = [];
    if (enteredKeyword.isEmpty) {
      results = songs;
    } else {
      results = songs
          .where((song) =>
          song.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundSongs = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  //Widget đóng thì đóng stream
  @override
  void dispose() {
    _viewModel.songStream.close();
    AudioPlayerManager().dispose();
    super.dispose();
  }

  //hàm nếu ko có bài hát thì hiển thị load, ko thì đổ dữ liệu lên app
  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return Consumer<PlayingSongProvider>(
        builder: (BuildContext context, playingSongProvider, child) {
          Songs? playingSong = playingSongProvider.playingSong;
          return Stack(alignment: Alignment.bottomCenter, children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: TextField(
                    onChanged: (value) => _runFilter(value),
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: const InputDecoration(
                        labelText: 'Search', suffixIcon: Icon(Icons.search)),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                      valueListenable: boxSongs.listenable(),
                      builder: (context, boxSongs, widget) {
                        return SlidableAutoCloseBehavior(
                          closeWhenOpened: true,
                          child: getListView(),
                        );
                      }),
                ),
              ],
            ),
            if (_showScrollToTopButton)
              Positioned(
                  top: MediaQuery
                      .of(context)
                      .size
                      .height * 0.17,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _scrollToTop,
                    child: Icon(Icons.arrow_upward),
                  )),
            playingSong != null
                ? Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 50),
                height: 75,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0, 5),
                        colors: [
                          Colors.purple,
                          Colors.deepPurple,
                        ]),
                    borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/itune.jpg',
                      image: playingSong.image,
                      width: 48,
                      height: 48,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/itune.jpg',
                            width: 48, height: 48);
                      },
                    ),
                  ),
                  title: Text(playingSong.title),
                  subtitle: Text(playingSong.artist),
                  trailing: IconButton(onPressed: (){
                    setState(() {
                      isPlay = _audioPlayerManager.player.playing;
                    });
                    if (_audioPlayerManager.player.playing==true){
                      _audioPlayerManager.player.pause();
                    }
                    else{
                      _audioPlayerManager.player.play();
                    }
                  },
                      icon: isPlay ? const Icon(
                          Icons.play_arrow):const Icon(Icons.pause)),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.more_horiz),
                  //   onPressed: () {
                  //     parent.showBottomSheet();
                  //   },
                  // ),
                  onTap: () {
                    navigate(playingSong);
                  },
                ))
                : isTap == false
                ? const SizedBox.shrink()
                : Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 50),
                height: 75,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0, 5),
                        colors: [
                          Colors.purple,
                          Colors.deepPurple,
                        ]),
                    borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/itune.jpg',
                      image: nowSong.image,
                      width: 48,
                      height: 48,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/itune.jpg',
                            width: 48, height: 48);
                      },
                    ),
                  ),
                  title: Text(nowSong.title),
                  subtitle: Text(nowSong.artist),
                  trailing: IconButton(onPressed: (){
                    setState(() {
                      isPlay = _audioPlayerManager.player.playing;
                    });
                    if (_audioPlayerManager.player.playing==true){
                      _audioPlayerManager.player.pause();
                    }
                    else{
                      _audioPlayerManager.player.play();
                    }
                  },
                      icon: isPlay ? const Icon(
                          Icons.play_arrow):const Icon(Icons.pause)),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.more_horiz),
                  //   onPressed: () {
                  //     parent.showBottomSheet();
                  //   },
                  // ),
                  onTap: () {
                    navigate(nowSong);
                  },
                ))
          ]);
        },
      );
    }
  }

  //hàm hiển thị đang load nếu danh sách bài hát trống
  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  //hàm hiển thị danh sách bài hát
  ListView getListView() {
    return ListView.separated(
      controller: _scrollController,
      itemBuilder: (context, position) {
        return Slidable(
            endActionPane: ActionPane(motion: const StretchMotion(), children: [
              SlidableAction(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.purple,
                icon: Icons.info,
                onPressed: (context) {
                  showBottomSheet(position);
                },
                autoClose: false,
              ),
              SlidableAction(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                icon: boxSongs
                    .getAt(position)
                    .favor
                    ? Icons.favorite
                    : Icons.favorite_border,
                onPressed: (context) {
                  favor = boxSongs
                      .getAt(position)
                      .favor;
                  getFavor(position);
                },
                autoClose: false,
              ),
            ]),
            child: getRow(position));
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 10,
          endIndent: 10,
        );
      },
      itemCount: _foundSongs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(parent: this, song: _foundSongs[index]);
  }

  //hàm theo dõi nếu dữ liệu co thay đổi thì cập nhật lại
  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  //hàm hiện option cho từng bài
  void showBottomSheet(int position) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 200,
              color: Colors.grey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Song name: ${_foundSongs[position].title}'),
                    Text('Album: ${_foundSongs[position].album}'),
                    Text('Singer: ${_foundSongs[position].artist}'),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close information'))
                  ],
                ),
              ),
            ),
          );
        });
  }

  //hàm điều hướng từng bài để qua trang nghe nhạc
  void navigate(Songs song) async {
    await Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
        audioPlayerManagers: audioPlayerManagers,
      );
    }));

    _audioPlayerManager = AudioPlayerManager();
    isTap = true;
    setState(() {
      nowSong = song;
    });
  }

  void getFavor(int position) async {
    favor = !favor;
    print(favor);
    if (favor) {
      await boxFavorSong.add(FavorSong(
          id: songs[position].id,
          title: songs[position].title,
          album: songs[position].album,
          artist: songs[position].artist,
          source: songs[position].source,
          image: songs[position].image,
          duration: songs[position].duration,
          favor: favor));

      await boxSongs.putAt(
          position,
          Songs(
              id: songs[position].id,
              title: songs[position].title,
              album: songs[position].album,
              artist: songs[position].artist,
              source: songs[position].source,
              image: songs[position].image,
              duration: songs[position].duration,
              favor: favor));
    } else {
      await boxSongs.putAt(
          position,
          Songs(
              id: songs[position].id,
              title: songs[position].title,
              album: songs[position].album,
              artist: songs[position].artist,
              source: songs[position].source,
              image: songs[position].image,
              duration: songs[position].duration,
              favor: favor));
      boxFavorSong.deleteAt(getIndex(boxFavorSong, songs[position]));
      // boxFavorSong.deleteAll(boxFavorSong.keys);
    }
  }

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
}

//lớp hiển thị phần tử nhạc
class _SongItemSection extends StatelessWidget {
  _SongItemSection({
    required this.parent,
    required this.song,
  });

  final _HomeTabPageState parent;
  final Songs song;

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
      // trailing: IconButton(
      //   icon: const Icon(Icons.more_horiz),
      //   onPressed: () {
      //     parent.showBottomSheet();
      //   },
      // ),
      onTap: () {
        parent.navigate(song);
      },
    );
    throw UnimplementedError();
  }
}
