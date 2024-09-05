import '../model/song.dart';
import '../source/source.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    bool isRemoteSongs = false;
    await _remoteDataSource.loadData().then((remoteSongs) {
      if (remoteSongs != null) {
        isRemoteSongs = true;
        songs.addAll(remoteSongs);
      }
    });
    if (isRemoteSongs == false) {
      await _localDataSource.loadData().then((localSongs) {
        if (localSongs != null) {
          songs.addAll(localSongs);
        }
      });
    }
    return songs;
  }
}
