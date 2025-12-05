import 'package:study_buddy/core/constants/game_constants.dart';
import 'package:study_buddy/data/models/player_stats.dart';

/// Utility class for streak calculations
class StreakCalculator {
  StreakCalculator._();

  /// Check if streak should be incremented (first focus activity of a new day)
  /// Returns true if the user had activity yesterday but not today yet
  static bool shouldIncrementStreak({
    required DateTime? lastActiveDate,
    required int todayFocusMinutes,
  }) {
    if (lastActiveDate == null) return true; // First ever activity

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );

    // Already active today - no increment needed
    if (lastActive == today) return false;

    final yesterday = today.subtract(const Duration(days: 1));

    // Active yesterday - increment streak
    if (lastActive == yesterday) return true;

    // More than 1 day gap - streak was broken, start fresh
    return true;
  }

  /// Check if streak should be reset (missed a day)
  static bool shouldResetStreak({
    required DateTime? lastActiveDate,
  }) {
    if (lastActiveDate == null) return false; // No streak to reset

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );

    // Active today or yesterday - streak is safe
    final yesterday = today.subtract(const Duration(days: 1));
    if (lastActive == today || lastActive == yesterday) return false;

    // More than 1 day gap - streak is broken
    return true;
  }

  /// Calculate new streak value after a focus session
  static StreakUpdateResult calculateStreakUpdate({
    required DateTime? lastActiveDate,
    required int currentStreak,
    required int longestStreak,
    required int todayFocusMinutes,
    required int sessionFocusMinutes,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if we need to reset the streak first
    if (shouldResetStreak(lastActiveDate: lastActiveDate)) {
      // Streak was broken - start fresh at day 1
      return StreakUpdateResult(
        newStreak: 1,
        newLongestStreak: longestStreak,
        streakIncremented: false,
        streakBroken: true,
        isMilestone: false,
        milestoneReached: null,
        gemsEarned: 0,
      );
    }

    // Check if this is a new day (streak should increment)
    final isNewDay = lastActiveDate == null ||
        DateTime(
              lastActiveDate.year,
              lastActiveDate.month,
              lastActiveDate.day,
            ) !=
            today;

    if (isNewDay) {
      // First activity of a new day - increment streak
      final newStreak = currentStreak + 1;
      final newLongestStreak =
          newStreak > longestStreak ? newStreak : longestStreak;
      final isMilestone = GameConstants.isStreakMilestone(newStreak);
      final gemsEarned =
          isMilestone ? GameConstants.getGemsForStreakMilestone(newStreak) : 0;

      return StreakUpdateResult(
        newStreak: newStreak,
        newLongestStreak: newLongestStreak,
        streakIncremented: true,
        streakBroken: false,
        isMilestone: isMilestone,
        milestoneReached: isMilestone ? newStreak : null,
        gemsEarned: gemsEarned,
      );
    }

    // Same day - streak stays the same
    return StreakUpdateResult(
      newStreak: currentStreak,
      newLongestStreak: longestStreak,
      streakIncremented: false,
      streakBroken: false,
      isMilestone: false,
      milestoneReached: null,
      gemsEarned: 0,
    );
  }

  /// Check if a given streak day is a milestone
  static bool isMilestone(int streakDays) {
    return GameConstants.isStreakMilestone(streakDays);
  }

  /// Get gems earned for reaching a milestone
  static int getMilestoneGems(int streakDays) {
    return GameConstants.getGemsForStreakMilestone(streakDays);
  }

  /// Get the next milestone after current streak
  static int? getNextMilestone(int currentStreak) {
    return GameConstants.getNextMilestone(currentStreak);
  }

  /// Get days remaining until next milestone
  static int? getDaysToNextMilestone(int currentStreak) {
    return GameConstants.getDaysUntilNextMilestone(currentStreak);
  }

  /// Check if user met the minimum daily focus requirement for streak
  static bool metDailyStreakRequirement(int todayFocusMinutes) {
    return todayFocusMinutes >= GameConstants.minimumDailyMinutesForStreak;
  }

  /// Apply streak update to player stats
  static PlayerStats applyStreakToStats(
    PlayerStats stats,
    StreakUpdateResult result,
  ) {
    return stats.copyWith(
      currentStreak: result.newStreak,
      longestStreak: result.newLongestStreak,
      totalGems: stats.totalGems + result.gemsEarned,
      lastActiveDate: DateTime.now(),
    );
  }

  /// Calculate how long until streak expires (hours remaining in the day)
  static Duration getTimeUntilStreakExpires() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return endOfDay.difference(now);
  }

  /// Check if streak is at risk (close to expiring without activity today)
  static bool isStreakAtRisk({
    required DateTime? lastActiveDate,
    required int currentStreak,
  }) {
    if (currentStreak == 0) return false;
    if (lastActiveDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );

    // Already active today - no risk
    if (lastActive == today) return false;

    // Was active yesterday and it's getting late - at risk
    final yesterday = today.subtract(const Duration(days: 1));
    if (lastActive == yesterday && now.hour >= 20) {
      return true;
    }

    return false;
  }
}

/// Result of streak calculation
class StreakUpdateResult {
  /// New streak value after update
  final int newStreak;

  /// New longest streak value
  final int newLongestStreak;

  /// Whether streak was incremented (new day)
  final bool streakIncremented;

  /// Whether streak was broken (missed a day)
  final bool streakBroken;

  /// Whether a milestone was reached
  final bool isMilestone;

  /// The milestone reached (if any)
  final int? milestoneReached;

  /// Gems earned from milestone
  final int gemsEarned;

  const StreakUpdateResult({
    required this.newStreak,
    required this.newLongestStreak,
    required this.streakIncremented,
    required this.streakBroken,
    required this.isMilestone,
    required this.milestoneReached,
    required this.gemsEarned,
  });

  @override
  String toString() {
    if (streakBroken) {
      return 'StreakBroken: Reset to day 1';
    }
    if (streakIncremented) {
      return 'StreakIncremented: Day $newStreak'
          '${isMilestone ? ' 🎉 MILESTONE! +$gemsEarned gems' : ''}';
    }
    return 'StreakMaintained: Day $newStreak';
  }
}
