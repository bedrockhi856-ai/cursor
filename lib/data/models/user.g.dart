// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      age: fields[2] as int,
      dailyPhoneUsageHours: fields[3] as int,
      characterId: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      onboardingCompleted: fields[6] as bool,
      startingCommitmentMinutes: fields[7] as int?,
      ultimateGoalMinutes: fields[8] as int?,
      customDailyMinutes: fields[9] as int?,
      goalSpeedMonths: fields[10] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.dailyPhoneUsageHours)
      ..writeByte(4)
      ..write(obj.characterId)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.onboardingCompleted)
      ..writeByte(7)
      ..write(obj.startingCommitmentMinutes)
      ..writeByte(8)
      ..write(obj.ultimateGoalMinutes)
      ..writeByte(9)
      ..write(obj.customDailyMinutes)
      ..writeByte(10)
      ..write(obj.goalSpeedMonths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
