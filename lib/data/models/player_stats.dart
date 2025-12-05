import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:study_buddy/core/constants/game_constants.dart';

part 'player_stats.g.dart';

/// Player gamification statistics stored in Hive
@HiveType(typeId: 10)
class PlayerStats extends Equatable {
  /// Total XP earned across all time
  @HiveField(0)
  final int totalXp;

  /// Current player level (derived from totalXp but cached for convenience)
  @HiveField(1)
  final int currentLevel;

  /// Current daily streak count
  @HiveField(2)
  final int currentStreak;

  /// Longest streak ever achieved
  @HiveField(3)
  final int longestStreak;

  /// Total gems collected
  @HiveField(4)
  final int totalGems;

  /// Focus minutes completed today
  @HiveField(5)
  final int todayFocusMinutes;

  /// Last date the user was active (for streak calculation)
  @HiveField(6)
  final DateTime? lastActiveDate;

  /// Total sessions completed
  @HiveField(7)
  final int totalSessionsCompleted;

  /// Total focus minutes all time
  @HiveField(8)
  final int totalFocusMinutes;

  /// Daily focus goal in minutes
  @HiveField(9)
  final int dailyGoalMinutes;

  /// Whether daily goal was completed today
  @HiveField(10)
  final bool dailyGoalCompletedToday;

  /// Date when daily goal was last completed
  @HiveField(11)
  final DateTime? lastDailyGoalCompletedDate;

  const PlayerStats({
    this.totalXp = 0,
    this.currentLevel = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalGems = 0,
    this.todayFocusMinutes = 0,
    this.lastActiveDate,
    this.totalSessionsCompleted = 0,
    this.totalFocusMinutes = 0,
    this.dailyGoalMinutes = GameConstants.defaultDailyGoalMinutes,
    this.dailyGoalCompletedToday = false,
    this.lastDailyGoalCompletedDate,
  });

  /// Create a new player with default stats
  factory PlayerStats.newPlayer() => const PlayerStats();

  /// Progress towards next level (0.0 to 1.0)
  double get levelProgress {
    if (currentLevel >= GameConstants.maxLevel) return 1.0;
    
    final currentLevelXp = GameConstants.getXPForLevel(currentLevel);
    final nextLevelXp = GameConstants.getXPForNextLevel(currentLevel);
    final xpInCurrentLevel = totalXp - currentLevelXp;
    final xpNeededForNextLevel = nextLevelXp - currentLevelXp;
    
    if (xpNeededForNextLevel <= 0) return 1.0;
    return (xpInCurrentLevel / xpNeededForNextLevel).clamp(0.0, 1.0);
  }

  /// XP needed to reach next level
  int get xpToNextLevel {
    if (currentLevel >= GameConstants.maxLevel) return 0;
    return GameConstants.getXPForNextLevel(currentLevel) - totalXp;
  }

  /// Current level title
  String get levelTitle => GameConstants.getTitleForLevel(currentLevel);

  /// Current level emoji
  String get levelEmoji => GameConstants.getEmojiForLevel(currentLevel);

  /// Character stage based on level (1-5)
  int get characterStage => GameConstants.getCharacterStageForLevel(currentLevel);

  /// Current streak multiplier for XP
  double get streakMultiplier => GameConstants.getStreakMultiplier(currentStreak);

  /// Progress towards daily goal (0.0 to 1.0)
  double get dailyGoalProgress {
    if (dailyGoalMinutes <= 0) return 1.0;
    return (todayFocusMinutes / dailyGoalMinutes).clamp(0.0, 1.0);
  }

  /// Whether daily goal is complete
  bool get isDailyGoalComplete => todayFocusMinutes >= dailyGoalMinutes;

  /// Minutes remaining to complete daily goal
  int get minutesToDailyGoal {
    final remaining = dailyGoalMinutes - todayFocusMinutes;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if streak should be maintained (had activity today)
  bool get hasActivityToday {
    if (lastActiveDate == null) return false;
    final now = DateTime.now();
    return lastActiveDate!.year == now.year &&
        lastActiveDate!.month == now.month &&
        lastActiveDate!.day == now.day;
  }

  /// Check if user was active yesterday
  bool get wasActiveYesterday {
    if (lastActiveDate == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return lastActiveDate!.year == yesterday.year &&
        lastActiveDate!.month == yesterday.month &&
        lastActiveDate!.day == yesterday.day;
  }

  /// Next streak milestone
  int? get nextMilestone => GameConstants.getNextMilestone(currentStreak);

  /// Days until next milestone
  int? get daysToNextMilestone => GameConstants.getDaysUntilNextMilestone(currentStreak);

  /// Copy with new values
  PlayerStats copyWith({
    int? totalXp,
    int? currentLevel,
    int? currentStreak,
    int? longestStreak,
    int? totalGems,
    int? todayFocusMinutes,
    DateTime? lastActiveDate,
    int? totalSessionsCompleted,
    int? totalFocusMinutes,
    int? dailyGoalMinutes,
    bool? dailyGoalCompletedToday,
    DateTime? lastDailyGoalCompletedDate,
  }) {
    return PlayerStats(
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalGems: totalGems ?? this.totalGems,
      todayFocusMinutes: todayFocusMinutes ?? this.todayFocusMinutes,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalSessionsCompleted: totalSessionsCompleted ?? this.totalSessionsCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      dailyGoalCompletedToday: dailyGoalCompletedToday ?? this.dailyGoalCompletedToday,
      lastDailyGoalCompletedDate: lastDailyGoalCompletedDate ?? this.lastDailyGoalCompletedDate,
    );
  }

  @override
  List<Object?> get props => [
        totalXp,
        currentLevel,
        currentStreak,
        longestStreak,
        totalGems,
        todayFocusMinutes,
        lastActiveDate,
        totalSessionsCompleted,
        totalFocusMinutes,
        dailyGoalMinutes,
        dailyGoalCompletedToday,
        lastDailyGoalCompletedDate,
      ];

  @override
  String toString() => 'PlayerStats('
      'level: $currentLevel ($levelTitle), '
      'xp: $totalXp, '
      'streak: $currentStreak, '
      'gems: $totalGems)';
}
