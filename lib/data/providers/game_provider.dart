import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_buddy/core/constants/game_constants.dart';
import 'package:study_buddy/data/models/player_stats.dart';
import 'package:study_buddy/data/sources/local/hive_service.dart';
import 'package:study_buddy/utils/xp_calculator.dart';
import 'package:study_buddy/utils/streak_calculator.dart';

/// Key for storing player stats in Hive
const String playerStatsKey = 'current_player';

/// Result of completing a focus session
class SessionCompletionResult {
  final SessionXPResult xpResult;
  final LevelUpResult levelUpResult;
  final StreakUpdateResult streakResult;
  final bool dailyGoalCompleted;
  final int gemsEarnedFromDailyGoal;
  final PlayerStats updatedStats;

  const SessionCompletionResult({
    required this.xpResult,
    required this.levelUpResult,
    required this.streakResult,
    required this.dailyGoalCompleted,
    required this.gemsEarnedFromDailyGoal,
    required this.updatedStats,
  });

  /// Total gems earned from this session
  int get totalGemsEarned =>
      levelUpResult.gemsEarned +
      streakResult.gemsEarned +
      gemsEarnedFromDailyGoal;

  /// Whether any celebration should be shown
  bool get shouldShowCelebration =>
      levelUpResult.didLevelUp ||
      streakResult.isMilestone ||
      dailyGoalCompleted;
}

/// StateNotifier for managing game state
class GameStateNotifier extends StateNotifier<PlayerStats> {
  final Box<PlayerStats> _box;

  GameStateNotifier(this._box) : super(_loadOrCreateStats(_box));

  static PlayerStats _loadOrCreateStats(Box<PlayerStats> box) {
    final existing = box.get(playerStatsKey);
    if (existing != null) {
      // Check if streak needs to be reset (missed a day)
      if (StreakCalculator.shouldResetStreak(
        lastActiveDate: existing.lastActiveDate,
      )) {
        final resetStats = existing.copyWith(
          currentStreak: 0,
          todayFocusMinutes: 0,
          dailyGoalCompletedToday: false,
        );
        box.put(playerStatsKey, resetStats);
        return resetStats;
      }

      // Check if it's a new day - reset daily counters
      final now = DateTime.now();
      final lastActive = existing.lastActiveDate;
      if (lastActive != null) {
        final isNewDay = lastActive.year != now.year ||
            lastActive.month != now.month ||
            lastActive.day != now.day;
        if (isNewDay) {
          final dailyResetStats = existing.copyWith(
            todayFocusMinutes: 0,
            dailyGoalCompletedToday: false,
          );
          box.put(playerStatsKey, dailyResetStats);
          return dailyResetStats;
        }
      }

      return existing;
    }
    final newStats = PlayerStats.newPlayer();
    box.put(playerStatsKey, newStats);
    return newStats;
  }

  /// Save current state to Hive
  Future<void> _save() async {
    await _box.put(playerStatsKey, state);
  }

  /// Complete a focus session and calculate all rewards
  Future<SessionCompletionResult> completeSession({
    required int focusMinutes,
    required bool completedSession,
  }) async {
    final isFirstSessionToday = !state.hasActivityToday;

    // Calculate XP earned
    final xpResult = XPCalculator.calculateSessionXP(
      focusMinutes: focusMinutes,
      currentStreak: state.currentStreak,
      isFirstSessionToday: isFirstSessionToday,
      completedSession: completedSession,
    );

    // Check for level up
    final levelUpResult = XPCalculator.checkForLevelUp(
      currentTotalXp: state.totalXp,
      currentLevel: state.currentLevel,
      xpToAdd: xpResult.totalXp,
    );

    // Calculate streak update
    final streakResult = StreakCalculator.calculateStreakUpdate(
      lastActiveDate: state.lastActiveDate,
      currentStreak: state.currentStreak,
      longestStreak: state.longestStreak,
      todayFocusMinutes: state.todayFocusMinutes,
      sessionFocusMinutes: focusMinutes,
    );

    // Calculate new daily focus minutes
    final newTodayMinutes = state.todayFocusMinutes + focusMinutes;

    // Check if daily goal was just completed
    final dailyGoalJustCompleted =
        !state.dailyGoalCompletedToday && newTodayMinutes >= state.dailyGoalMinutes;
    final gemsFromDailyGoal =
        dailyGoalJustCompleted ? GameConstants.gemsForDailyGoal : 0;

    // Calculate total gems earned
    final totalNewGems = levelUpResult.gemsEarned +
        streakResult.gemsEarned +
        gemsFromDailyGoal;

    // Update state
    state = state.copyWith(
      totalXp: state.totalXp + xpResult.totalXp,
      currentLevel: levelUpResult.newLevel,
      currentStreak: streakResult.newStreak,
      longestStreak: streakResult.newLongestStreak,
      totalGems: state.totalGems + totalNewGems,
      todayFocusMinutes: newTodayMinutes,
      lastActiveDate: DateTime.now(),
      totalSessionsCompleted: state.totalSessionsCompleted + 1,
      totalFocusMinutes: state.totalFocusMinutes + focusMinutes,
      dailyGoalCompletedToday:
          state.dailyGoalCompletedToday || dailyGoalJustCompleted,
      lastDailyGoalCompletedDate:
          dailyGoalJustCompleted ? DateTime.now() : state.lastDailyGoalCompletedDate,
    );

    await _save();

    return SessionCompletionResult(
      xpResult: xpResult,
      levelUpResult: levelUpResult,
      streakResult: streakResult,
      dailyGoalCompleted: dailyGoalJustCompleted,
      gemsEarnedFromDailyGoal: gemsFromDailyGoal,
      updatedStats: state,
    );
  }

  /// Add gems (e.g., from achievements or purchases)
  Future<void> addGems(int amount) async {
    state = state.copyWith(totalGems: state.totalGems + amount);
    await _save();
  }

  /// Spend gems (e.g., for power-ups or items)
  Future<bool> spendGems(int amount) async {
    if (state.totalGems < amount) return false;
    state = state.copyWith(totalGems: state.totalGems - amount);
    await _save();
    return true;
  }

  /// Update daily focus goal
  Future<void> setDailyGoal(int minutes) async {
    state = state.copyWith(dailyGoalMinutes: minutes);
    await _save();
  }

  /// Reset all progress (for testing or user request)
  Future<void> resetProgress() async {
    state = PlayerStats.newPlayer();
    await _save();
  }

  /// Force refresh from storage
  Future<void> refresh() async {
    state = _loadOrCreateStats(_box);
  }
}

/// Provider for the Hive box - uses HiveService
final playerStatsBoxProvider = Provider<Box<PlayerStats>>((ref) {
  return HiveService.playerStatsBox;
});

/// Provider for game state - automatically initializes from HiveService
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, PlayerStats>((ref) {
  final box = ref.watch(playerStatsBoxProvider);
  return GameStateNotifier(box);
});

/// Convenience providers for specific stats
final currentLevelProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).currentLevel;
});

final totalXpProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).totalXp;
});

final levelProgressProvider = Provider<double>((ref) {
  return ref.watch(gameStateProvider).levelProgress;
});

final currentStreakProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).currentStreak;
});

final totalGemsProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).totalGems;
});

final levelTitleProvider = Provider<String>((ref) {
  return ref.watch(gameStateProvider).levelTitle;
});

final levelEmojiProvider = Provider<String>((ref) {
  return ref.watch(gameStateProvider).levelEmoji;
});

final characterStageProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).characterStage;
});

final dailyGoalProgressProvider = Provider<double>((ref) {
  return ref.watch(gameStateProvider).dailyGoalProgress;
});

final isDailyGoalCompleteProvider = Provider<bool>((ref) {
  return ref.watch(gameStateProvider).isDailyGoalComplete;
});

final streakMultiplierProvider = Provider<double>((ref) {
  return ref.watch(gameStateProvider).streakMultiplier;
});

final todayFocusMinutesProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).todayFocusMinutes;
});
