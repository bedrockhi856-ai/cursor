/// Game constants for the gamification system
/// All XP, level, streak, and reward values are defined here
library;

class GameConstants {
  GameConstants._();

  // ============== XP RATES ==============
  
  /// Base XP earned per minute of focus
  static const int xpPerMinute = 2;
  
  /// Bonus XP for completing a session (not giving up)
  static const int sessionCompletionBonus = 20;
  
  /// Bonus XP for first session of the day
  static const int firstSessionDailyBonus = 15;
  
  /// Minimum session duration (minutes) to earn XP
  static const int minimumSessionMinutes = 1;

  // ============== LEVELS ==============
  
  /// XP thresholds for each level (index = level - 1)
  /// Level 1: 0 XP, Level 2: 100 XP, etc.
  static const List<int> levelThresholds = [
    0,      // Level 1
    100,    // Level 2
    250,    // Level 3
    500,    // Level 4
    800,    // Level 5
    1200,   // Level 6
    1800,   // Level 7
    2500,   // Level 8
    3500,   // Level 9
    5000,   // Level 10 (max)
  ];
  
  /// Titles for each level
  static const List<String> levelTitles = [
    'Seed',         // Level 1
    'Sprout',       // Level 2
    'Sapling',      // Level 3
    'Growing',      // Level 4
    'Blooming',     // Level 5
    'Thriving',     // Level 6
    'Flourishing',  // Level 7
    'Radiant',      // Level 8
    'Legendary',    // Level 9
    'Transcendent', // Level 10
  ];
  
  /// Emoji for each level
  static const List<String> levelEmojis = [
    '🌱',  // Level 1
    '🌿',  // Level 2
    '🪴',  // Level 3
    '💪',  // Level 4
    '🌸',  // Level 5
    '✨',  // Level 6
    '🌟',  // Level 7
    '💫',  // Level 8
    '👑',  // Level 9
    '🏆',  // Level 10
  ];
  
  /// Character stage for each level (1-5)
  /// Stage 1: Sick, Stage 2: Recovering, Stage 3: Healing, 
  /// Stage 4: Thriving, Stage 5: Healed
  static const List<int> characterStageForLevel = [
    1,  // Level 1 - Sick
    1,  // Level 2 - Sick
    2,  // Level 3 - Recovering
    2,  // Level 4 - Recovering
    3,  // Level 5 - Healing
    3,  // Level 6 - Healing
    4,  // Level 7 - Thriving
    4,  // Level 8 - Thriving
    4,  // Level 9 - Thriving
    5,  // Level 10 - Healed!
  ];
  
  /// Maximum level achievable
  static const int maxLevel = 10;

  // ============== STREAKS ==============
  
  /// Minimum focus minutes per day to maintain streak
  static const int minimumDailyMinutesForStreak = 5;
  
  /// Streak milestone days that give bonus rewards
  static const List<int> streakMilestones = [3, 7, 14, 30, 50, 100, 365];
  
  /// Base streak multiplier (no streak)
  static const double baseStreakMultiplier = 1.0;
  
  /// Additional multiplier per streak day
  static const double streakMultiplierPerDay = 0.1;
  
  /// Maximum streak multiplier cap
  static const double maxStreakMultiplier = 2.0;
  
  /// Days needed to reach max multiplier
  static const int daysForMaxMultiplier = 10;

  // ============== GEMS ==============
  
  /// Gems earned per level up
  static const int gemsPerLevelUp = 50;
  
  /// Gems earned for streak milestones
  static const Map<int, int> gemsPerStreakMilestone = {
    3: 25,
    7: 50,
    14: 100,
    30: 200,
    50: 300,
    100: 500,
    365: 1000,
  };
  
  /// Gems for completing daily goal
  static const int gemsForDailyGoal = 10;
  
  /// Default daily focus goal in minutes
  static const int defaultDailyGoalMinutes = 30;

  // ============== HELPER METHODS ==============
  
  /// Get level from total XP
  static int getLevelFromXP(int totalXp) {
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (totalXp >= levelThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }
  
  /// Get XP needed for a specific level
  static int getXPForLevel(int level) {
    if (level < 1) return 0;
    if (level > maxLevel) return levelThresholds[maxLevel - 1];
    return levelThresholds[level - 1];
  }
  
  /// Get XP needed for next level
  static int getXPForNextLevel(int currentLevel) {
    if (currentLevel >= maxLevel) return levelThresholds[maxLevel - 1];
    return levelThresholds[currentLevel];
  }
  
  /// Get title for a level
  static String getTitleForLevel(int level) {
    if (level < 1) return levelTitles[0];
    if (level > maxLevel) return levelTitles[maxLevel - 1];
    return levelTitles[level - 1];
  }
  
  /// Get emoji for a level
  static String getEmojiForLevel(int level) {
    if (level < 1) return levelEmojis[0];
    if (level > maxLevel) return levelEmojis[maxLevel - 1];
    return levelEmojis[level - 1];
  }
  
  /// Get character stage for a level (1-5)
  static int getCharacterStageForLevel(int level) {
    if (level < 1) return 1;
    if (level > maxLevel) return 5;
    return characterStageForLevel[level - 1];
  }
  
  /// Calculate streak multiplier
  static double getStreakMultiplier(int streakDays) {
    if (streakDays <= 0) return baseStreakMultiplier;
    final multiplier = baseStreakMultiplier + (streakDays * streakMultiplierPerDay);
    return multiplier.clamp(baseStreakMultiplier, maxStreakMultiplier);
  }
  
  /// Check if a streak day is a milestone
  static bool isStreakMilestone(int streakDays) {
    return streakMilestones.contains(streakDays);
  }
  
  /// Get gems for a streak milestone (0 if not a milestone)
  static int getGemsForStreakMilestone(int streakDays) {
    return gemsPerStreakMilestone[streakDays] ?? 0;
  }
  
  /// Get the next milestone after current streak
  static int? getNextMilestone(int currentStreak) {
    for (final milestone in streakMilestones) {
      if (milestone > currentStreak) {
        return milestone;
      }
    }
    return null;
  }
  
  /// Get days until next milestone
  static int? getDaysUntilNextMilestone(int currentStreak) {
    final next = getNextMilestone(currentStreak);
    if (next == null) return null;
    return next - currentStreak;
  }
}
