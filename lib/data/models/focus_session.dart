import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'focus_session.g.dart';

@HiveType(typeId: 1)
enum SessionStatus {
  @HiveField(0)
  inProgress,

  @HiveField(1)
  completed,

  @HiveField(2)
  failed,

  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 2)
class FocusSession extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String oderId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime? endTime;

  @HiveField(4)
  final int targetDurationMinutes;

  @HiveField(5)
  final int actualDurationMinutes;

  @HiveField(6)
  final SessionStatus status;

  @HiveField(7)
  final String? note;

  const FocusSession({
    required this.id,
    required this.oderId,
    required this.startTime,
    this.endTime,
    required this.targetDurationMinutes,
    this.actualDurationMinutes = 0,
    this.status = SessionStatus.inProgress,
    this.note,
  });

  /// Create a new focus session
  factory FocusSession.start({
    required String id,
    required String userId,
    required int targetMinutes,
  }) {
    return FocusSession(
      id: id,
      oderId: userId,
      startTime: DateTime.now(),
      targetDurationMinutes: targetMinutes,
      status: SessionStatus.inProgress,
    );
  }

  /// Complete the session successfully
  FocusSession complete() {
    final now = DateTime.now();
    final actualMinutes = now.difference(startTime).inMinutes;
    return copyWith(
      endTime: now,
      actualDurationMinutes: actualMinutes,
      status: SessionStatus.completed,
    );
  }

  /// Mark session as failed (user gave up)
  FocusSession fail() {
    final now = DateTime.now();
    final actualMinutes = now.difference(startTime).inMinutes;
    return copyWith(
      endTime: now,
      actualDurationMinutes: actualMinutes,
      status: SessionStatus.failed,
    );
  }

  /// Cancel the session
  FocusSession cancel() {
    final now = DateTime.now();
    final actualMinutes = now.difference(startTime).inMinutes;
    return copyWith(
      endTime: now,
      actualDurationMinutes: actualMinutes,
      status: SessionStatus.cancelled,
    );
  }

  /// Check if session achieved target duration
  bool get targetAchieved => actualDurationMinutes >= targetDurationMinutes;

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    if (targetDurationMinutes == 0) return 0;
    return (actualDurationMinutes / targetDurationMinutes).clamp(0.0, 1.0);
  }

  /// Create a copy with updated fields
  FocusSession copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? targetDurationMinutes,
    int? actualDurationMinutes,
    SessionStatus? status,
    String? note,
  }) {
    return FocusSession(
      id: id ?? this.id,
      oderId: userId ?? this.oderId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      targetDurationMinutes: targetDurationMinutes ?? this.targetDurationMinutes,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        id,
        oderId,
        startTime,
        endTime,
        targetDurationMinutes,
        actualDurationMinutes,
        status,
        note,
      ];
}
