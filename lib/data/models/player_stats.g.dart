// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerStatsAdapter extends TypeAdapter<PlayerStats> {
  @override
  final int typeId = 10;

  @override
  PlayerStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerStats(
      totalXp: fields[0] as int,
      currentLevel: fields[1] as int,
      currentStreak: fields[2] as int,
      longestStreak: fields[3] as int,
      totalGems: fields[4] as int,
      todayFocusMinutes: fields[5] as int,
      lastActiveDate: fields[6] as DateTime?,
      totalSessionsCompleted: fields[7] as int,
      totalFocusMinutes: fields[8] as int,
      dailyGoalMinutes: fields[9] as int,
      dailyGoalCompletedToday: fields[10] as bool,
      lastDailyGoalCompletedDate: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerStats obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.totalXp)
      ..writeByte(1)
      ..write(obj.currentLevel)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.longestStreak)
      ..writeByte(4)
      ..write(obj.totalGems)
      ..writeByte(5)
      ..write(obj.todayFocusMinutes)
      ..writeByte(6)
      ..write(obj.lastActiveDate)
      ..writeByte(7)
      ..write(obj.totalSessionsCompleted)
      ..writeByte(8)
      ..write(obj.totalFocusMinutes)
      ..writeByte(9)
      ..write(obj.dailyGoalMinutes)
      ..writeByte(10)
      ..write(obj.dailyGoalCompletedToday)
      ..writeByte(11)
      ..write(obj.lastDailyGoalCompletedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
