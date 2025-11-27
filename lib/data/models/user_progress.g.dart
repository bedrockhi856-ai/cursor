// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 3;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      userId: fields[0] as String,
      currentLevel: fields[1] as int,
      totalFocusMinutes: fields[2] as int,
      totalSessions: fields[3] as int,
      completedSessions: fields[4] as int,
      currentStreak: fields[5] as int,
      longestStreak: fields[6] as int,
      lastSessionDate: fields[7] as DateTime?,
      completedLevels: (fields[8] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.currentLevel)
      ..writeByte(2)
      ..write(obj.totalFocusMinutes)
      ..writeByte(3)
      ..write(obj.totalSessions)
      ..writeByte(4)
      ..write(obj.completedSessions)
      ..writeByte(5)
      ..write(obj.currentStreak)
      ..writeByte(6)
      ..write(obj.longestStreak)
      ..writeByte(7)
      ..write(obj.lastSessionDate)
      ..writeByte(8)
      ..write(obj.completedLevels);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
