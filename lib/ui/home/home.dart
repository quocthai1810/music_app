
import 'package:app_music/ui/favorite_songs/favorite_songs.dart';
import 'package:app_music/ui/home/viewmodel.dart';
import 'package:app_music/ui/now_playing/audio_player_manager.dart';
import 'package:app_music/ui/settings/settings.dart';
import 'package:app_music/ui/songs.dart';
import 'package:app_music/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: MusicHomePage(),
      debugShowCheckedModeBanner: false,
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
    const AccountTab(),
    const SettingsTab()
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Music App'),
        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
              backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: 'Favorite'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Account'),
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
  List<Songs> songs = [];
  late MusicAppViewModel _viewModel;
  List<AudioPlayerManager> audioPlayerManagers = [];

  //hàm gán các dữ liệu trước khi tạo Widget
  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
    super.initState();
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
    super.dispose();
  }

  //hàm nếu ko có bài hát thì hiển thị load, ko thì đổ dữ liệu lên app
  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
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
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(parent: this, song: songs[index]);
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

  //hàm điều hướng từng bài để qua trang nghe nhạc
  void navigate(Songs song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
        audioPlayerManagers: audioPlayerManagers,
      );
    }));
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
