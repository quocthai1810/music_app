import 'package:hive/hive.dart';

part 'songs.g.dart';

@HiveType(typeId: 2)
class Songs {
  Songs(
      {required this.id,
        required this.title,
        required this.album,
        required this.artist,
        required this.source,
        required this.image,
        required this.duration,
        required this.favor});
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String album;

  @HiveField(3)
  String artist;

  @HiveField(4)
  String source;

  @HiveField(5)
  String image;

  @HiveField(6)
  int duration;

  @HiveField(7)
  bool favor;

}