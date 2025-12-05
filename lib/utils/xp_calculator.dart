import 'package:study_buddy/core/constants/game_constants.dart';
import 'package:study_buddy/data/models/player_stats.dart';

/// Utility class for XP calculations
class XPCalculator {
  XPCalculator._();

  /// Calculate base XP earned from focus time
  /// Returns [xpPerMinute] * [minutes]
  static int calculateBaseXP(int minutes) {
    if (minutes < GameConstants.minimumSessionMinutes) return 0;
    return minutes * GameConstants.xpPerMinute;
  }

  /// Calculate XP with streak multiplier applied
  static int calculateXPWithMultiplier(int baseXp, double multiplier) {
    return (baseXp * multiplier).round();
  }

  /// Calculate total XP for a completed session
  /// Includes base XP, streak multiplier, completion bonus, and first session bonus
  static SessionXPResult calculateSessionXP({
    required int focusMinutes,
    required int currentStreak,
    required bool isFirstSessionToday,
    required bool completedSession,
  }) {
    // No XP if session is too short
    if (focusMinutes < GameConstants.minimumSessionMinutes) {
      return const SessionXPResult(
        baseXp: 0,
        multipliedXp: 0,
        completionBonus: 0,
        firstSessionBonus: 0,
        totalXp: 0,
        multiplier: 1.0,
      );
    }

    // Calculate base XP
    final baseXp = calculateBaseXP(focusMinutes);

    // Get streak multiplier
    final multiplier = GameConstants.getStreakMultiplier(currentStreak);

    // Apply multiplier to base XP
    final multipliedXp = calculateXPWithMultiplier(baseXp, multiplier);

    // Completion bonus (if user didn't give up)
    final completionBonus =
        completedSession ? GameConstants.sessionCompletionBonus : 0;

    // First session of the day bonus
    final firstSessionBonus =
        isFirstSessionToday ? GameConstants.firstSessionDailyBonus : 0;

    // Total XP earned
    final totalXp = multipliedXp + completionBonus + firstSessionBonus;

    return SessionXPResult(
      baseXp: baseXp,
      multipliedXp: multipliedXp,
      completionBonus: completionBonus,
      firstSessionBonus: firstSessionBonus,
      totalXp: totalXp,
      multiplier: multiplier,
    );
  }

  /// Get the level for a given total XP
  static int getLevelFromXP(int totalXp) {
    return GameConstants.getLevelFromXP(totalXp);
  }

  /// Calculate progress within current level (0.0 to 1.0)
  static double calculateLevelProgress(int totalXp, int currentLevel) {
    if (currentLevel >= GameConstants.maxLevel) return 1.0;

    final currentLevelXp = GameConstants.getXPForLevel(currentLevel);
    final nextLevelXp = GameConstants.getXPForNextLevel(currentLevel);
    final xpInLevel = totalXp - currentLevelXp;
    final xpNeeded = nextLevelXp - currentLevelXp;

    if (xpNeeded <= 0) return 1.0;
    return (xpInLevel / xpNeeded).clamp(0.0, 1.0);
  }

  /// Calculate XP remaining to next level
  static int calculateXPToNextLevel(int totalXp, int currentLevel) {
    if (currentLevel >= GameConstants.maxLevel) return 0;
    final nextLevelXp = GameConstants.getXPForNextLevel(currentLevel);
    return (nextLevelXp - totalXp).clamp(0, nextLevelXp);
  }

  /// Check if adding XP would cause a level up
  static LevelUpResult checkForLevelUp({
    required int currentTotalXp,
    required int currentLevel,
    required int xpToAdd,
  }) {
    final newTotalXp = currentTotalXp + xpToAdd;
    final newLevel = getLevelFromXP(newTotalXp);

    if (newLevel > currentLevel) {
      final levelsGained = newLevel - currentLevel;
      final gemsEarned = levelsGained * GameConstants.gemsPerLevelUp;

      return LevelUpResult(
        didLevelUp: true,
        previousLevel: currentLevel,
        newLevel: newLevel,
        levelsGained: levelsGained,
        gemsEarned: gemsEarned,
        newTitle: GameConstants.getTitleForLevel(newLevel),
        newEmoji: GameConstants.getEmojiForLevel(newLevel),
        newCharacterStage: GameConstants.getCharacterStageForLevel(newLevel),
        previousCharacterStage:
            GameConstants.getCharacterStageForLevel(currentLevel),
      );
    }

    return LevelUpResult(
      didLevelUp: false,
      previousLevel: currentLevel,
      newLevel: currentLevel,
      levelsGained: 0,
      gemsEarned: 0,
      newTitle: GameConstants.getTitleForLevel(currentLevel),
      newEmoji: GameConstants.getEmojiForLevel(currentLevel),
      newCharacterStage: GameConstants.getCharacterStageForLevel(currentLevel),
      previousCharacterStage:
          GameConstants.getCharacterStageForLevel(currentLevel),
    );
  }

  /// Update player stats after earning XP
  static PlayerStats applyXPToStats(PlayerStats stats, int xpToAdd) {
    final newTotalXp = stats.totalXp + xpToAdd;
    final newLevel = getLevelFromXP(newTotalXp);

    return stats.copyWith(
      totalXp: newTotalXp,
      currentLevel: newLevel,
    );
  }
}

/// Result of XP calculation for a session
class SessionXPResult {
  /// Base XP before multiplier
  final int baseXp;

  /// XP after streak multiplier applied
  final int multipliedXp;

  /// Bonus for completing session
  final int completionBonus;

  /// Bonus for first session of the day
  final int firstSessionBonus;

  /// Total XP earned
  final int totalXp;

  /// Streak multiplier used
  final double multiplier;

  const SessionXPResult({
    required this.baseXp,
    required this.multipliedXp,
    required this.completionBonus,
    required this.firstSessionBonus,
    required this.totalXp,
    required this.multiplier,
  });

  @override
  String toString() => 'SessionXPResult('
      'base: $baseXp, '
      'multiplied: $multipliedXp (${multiplier}x), '
      'completion: $completionBonus, '
      'firstSession: $firstSessionBonus, '
      'total: $totalXp)';
}

/// Result of level up check
class LevelUpResult {
  final bool didLevelUp;
  final int previousLevel;
  final int newLevel;
  final int levelsGained;
  final int gemsEarned;
  final String newTitle;
  final String newEmoji;
  final int newCharacterStage;
  final int previousCharacterStage;

  const LevelUpResult({
    required this.didLevelUp,
    required this.previousLevel,
    required this.newLevel,
    required this.levelsGained,
    required this.gemsEarned,
    required this.newTitle,
    required this.newEmoji,
    required this.newCharacterStage,
    required this.previousCharacterStage,
  });

  /// Whether the character stage changed (triggers dialogue)
  bool get characterStageChanged =>
      newCharacterStage > previousCharacterStage;

  @override
  String toString() => didLevelUp
      ? 'LevelUp: $previousLevel → $newLevel ($newTitle $newEmoji), +$gemsEarned gems'
      : 'NoLevelUp: Level $newLevel';
}
