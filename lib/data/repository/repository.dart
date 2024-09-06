import '../../ui/songs.dart';
import '../model/song.dart';
import '../source/source.dart';

abstract interface class Repository {
  Future<List<Songs>?> loadData();
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  // final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Songs>?> loadData() async {
    List<Songs> songs = [];
    bool isRemoteSongs = false;
    // await _remoteDataSource.loadData().then((remoteSongs) {
    //   if (remoteSongs != null) {
    //     isRemoteSongs = true;
    //     songs.addAll(remoteSongs);
    //   }
    // });
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
