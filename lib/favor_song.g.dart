// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favor_song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavorSongAdapter extends TypeAdapter<FavorSong> {
  @override
  final int typeId = 1;

  @override
  FavorSong read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavorSong(
      id: fields[0] as String,
      title: fields[1] as String,
      album: fields[2] as String,
      artist: fields[3] as String,
      source: fields[4] as String,
      image: fields[5] as String,
      duration: fields[6] as int,
      favor: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FavorSong obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.album)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.source)
      ..writeByte(5)
      ..write(obj.image)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.favor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavorSongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
