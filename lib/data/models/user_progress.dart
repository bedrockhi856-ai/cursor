import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 3)
class UserProgress extends Equatable {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final int currentLevel;

  @HiveField(2)
  final int totalFocusMinutes;

  @HiveField(3)
  final int totalSessions;

  @HiveField(4)
  final int completedSessions;

  @HiveField(5)
  final int currentStreak;

  @HiveField(6)
  final int longestStreak;

  @HiveField(7)
  final DateTime? lastSessionDate;

  @HiveField(8)
  final List<int> completedLevels;

  const UserProgress({
    required this.userId,
    this.currentLevel = 1,
    this.totalFocusMinutes = 0,
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSessionDate,
    this.completedLevels = const [],
  });

  /// Create initial progress for a new user
  factory UserProgress.initial(String userId) {
    return UserProgress(userId: userId);
  }

  /// Update progress after completing a session
  UserProgress addCompletedSession(int durationMinutes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate new streak
    int newStreak = currentStreak;
    if (lastSessionDate != null) {
      final lastDate = DateTime(
        lastSessionDate!.year,
        lastSessionDate!.month,
        lastSessionDate!.day,
      );
      final daysDifference = today.difference(lastDate).inDays;
      
      if (daysDifference == 0) {
        // Same day, streak stays the same
        newStreak = currentStreak;
      } else if (daysDifference == 1) {
        // Consecutive day, increase streak
        newStreak = currentStreak + 1;
      } else {
        // Streak broken, reset to 1
        newStreak = 1;
      }
    } else {
      // First session ever
      newStreak = 1;
    }

    // Update longest streak
    final newLongestStreak = newStreak > longestStreak ? newStreak : longestStreak;

    // Check for level up (every 60 minutes of focus = 1 level)
    final newTotalMinutes = totalFocusMinutes + durationMinutes;
    final newLevel = (newTotalMinutes ~/ 60) + 1;

    // Track completed levels
    List<int> newCompletedLevels = [...completedLevels];
    if (newLevel > currentLevel && !newCompletedLevels.contains(currentLevel)) {
      newCompletedLevels.add(currentLevel);
    }

    return copyWith(
      currentLevel: newLevel.clamp(1, 10),
      totalFocusMinutes: newTotalMinutes,
      totalSessions: totalSessions + 1,
      completedSessions: completedSessions + 1,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastSessionDate: now,
      completedLevels: newCompletedLevels,
    );
  }

  /// Record a failed session (doesn't break streak if they try again same day)
  UserProgress addFailedSession(int durationMinutes) {
    return copyWith(
      totalFocusMinutes: totalFocusMinutes + durationMinutes,
      totalSessions: totalSessions + 1,
    );
  }

  /// Format total focus time as string (e.g., "12h 34m")
  String get formattedTotalTime {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Get streak display string
  String get streakDisplay => '$currentStreak days';

  /// Check if user has maintained streak today
  bool get hasSessionToday {
    if (lastSessionDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastSessionDate!.year,
      lastSessionDate!.month,
      lastSessionDate!.day,
    );
    return today == lastDate;
  }

  /// Create a copy with updated fields
  UserProgress copyWith({
    String? userId,
    int? currentLevel,
    int? totalFocusMinutes,
    int? totalSessions,
    int? completedSessions,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSessionDate,
    List<int>? completedLevels,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      currentLevel: currentLevel ?? this.currentLevel,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      totalSessions: totalSessions ?? this.totalSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      completedLevels: completedLevels ?? this.completedLevels,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        currentLevel,
        totalFocusMinutes,
        totalSessions,
        completedSessions,
        currentStreak,
        longestStreak,
        lastSessionDate,
        completedLevels,
      ];
}
