// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerProfileAdapter extends TypeAdapter<PlayerProfile> {
  @override
  final int typeId = 0;

  @override
  PlayerProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerProfile(
      levelProgress: (fields[0] as Map?)?.cast<String, int>(),
      globalScore: fields[1] as int,
      totalCorrectAnswers: fields[2] as int,
      totalWrongAnswers: fields[3] as int,
      isSoundOn: fields[4] as bool,
      isIndonesian: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.levelProgress)
      ..writeByte(1)
      ..write(obj.globalScore)
      ..writeByte(2)
      ..write(obj.totalCorrectAnswers)
      ..writeByte(3)
      ..write(obj.totalWrongAnswers)
      ..writeByte(4)
      ..write(obj.isSoundOn)
      ..writeByte(5)
      ..write(obj.isIndonesian);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
