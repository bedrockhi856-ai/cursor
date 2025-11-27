// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusSessionAdapter extends TypeAdapter<FocusSession> {
  @override
  final int typeId = 2;

  @override
  FocusSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSession(
      id: fields[0] as String,
      oderId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      targetDurationMinutes: fields[4] as int,
      actualDurationMinutes: fields[5] as int,
      status: fields[6] as SessionStatus,
      note: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.oderId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.targetDurationMinutes)
      ..writeByte(5)
      ..write(obj.actualDurationMinutes)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionStatusAdapter extends TypeAdapter<SessionStatus> {
  @override
  final int typeId = 1;

  @override
  SessionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SessionStatus.inProgress;
      case 1:
        return SessionStatus.completed;
      case 2:
        return SessionStatus.failed;
      case 3:
        return SessionStatus.cancelled;
      default:
        return SessionStatus.inProgress;
    }
  }

  @override
  void write(BinaryWriter writer, SessionStatus obj) {
    switch (obj) {
      case SessionStatus.inProgress:
        writer.writeByte(0);
        break;
      case SessionStatus.completed:
        writer.writeByte(1);
        break;
      case SessionStatus.failed:
        writer.writeByte(2);
        break;
      case SessionStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
