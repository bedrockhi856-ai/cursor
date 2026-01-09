import 'package:flutter_test/flutter_test.dart';
import 'package:study_buddy/utils/xp_calculator.dart';
import 'package:study_buddy/core/constants/game_constants.dart';

void main() {
  group('XPCalculator', () {
    group('calculateBaseXP', () {
      test('returns 0 for sessions below minimum duration', () {
        expect(XPCalculator.calculateBaseXP(0), equals(0));
      });

      test('returns correct XP for valid session duration', () {
        // xpPerMinute is 2
        expect(XPCalculator.calculateBaseXP(5), equals(10));
        expect(XPCalculator.calculateBaseXP(10), equals(20));
        expect(XPCalculator.calculateBaseXP(25), equals(50));
        expect(XPCalculator.calculateBaseXP(60), equals(120));
      });

      test('returns correct XP for 1 minute (minimum)', () {
        expect(XPCalculator.calculateBaseXP(1), equals(2));
      });
    });

    group('calculateXPWithMultiplier', () {
      test('applies multiplier correctly', () {
        expect(XPCalculator.calculateXPWithMultiplier(100, 1.0), equals(100));
        expect(XPCalculator.calculateXPWithMultiplier(100, 1.5), equals(150));
        expect(XPCalculator.calculateXPWithMultiplier(100, 2.0), equals(200));
      });

      test('rounds correctly for non-integer results', () {
        expect(XPCalculator.calculateXPWithMultiplier(50, 1.1), equals(55));
        expect(XPCalculator.calculateXPWithMultiplier(33, 1.5), equals(50)); // 49.5 rounds to 50
      });
    });

    group('calculateSessionXP', () {
      test('returns zero XP for too short session', () {
        final result = XPCalculator.calculateSessionXP(
          focusMinutes: 0,
          currentStreak: 0,
          isFirstSessionToday: true,
          completedSession: true,
        );

        expect(result.totalXp, equals(0));
        expect(result.baseXp, equals(0));
      });

      test('calculates correct XP for normal session', () {
        final result = XPCalculator.calculateSessionXP(
          focusMinutes: 25,
          currentStreak: 0,
          isFirstSessionToday: false,
          completedSession: true,
        );

        // Base: 25 * 2 = 50
        // Multiplier: 1.0 (no streak)
        // Completion bonus: 20
        // First session bonus: 0
        // Total: 50 + 20 = 70
        expect(result.baseXp, equals(50));
        expect(result.multiplier, equals(1.0));
        expect(result.completionBonus, equals(GameConstants.sessionCompletionBonus));
        expect(result.firstSessionBonus, equals(0));
        expect(result.totalXp, equals(70));
      });

      test('includes first session bonus', () {
        final result = XPCalculator.calculateSessionXP(
          focusMinutes: 25,
          currentStreak: 0,
          isFirstSessionToday: true,
          completedSession: true,
        );

        // Base: 50, Completion: 20, First session: 15
        expect(result.firstSessionBonus, equals(GameConstants.firstSessionDailyBonus));
        expect(result.totalXp, equals(85)); // 50 + 20 + 15
      });

      test('no completion bonus when session not completed', () {
        final result = XPCalculator.calculateSessionXP(
          focusMinutes: 25,
          currentStreak: 0,
          isFirstSessionToday: false,
          completedSession: false,
        );

        expect(result.completionBonus, equals(0));
        expect(result.totalXp, equals(50)); // Base only
      });

      test('applies streak multiplier correctly', () {
        final result = XPCalculator.calculateSessionXP(
          focusMinutes: 25,
          currentStreak: 5,
          isFirstSessionToday: false,
          completedSession: true,
        );

        // Streak of 5 should give 1.5x multiplier (1.0 + 5 * 0.1)
        // But capped at max, so check the actual multiplier
        expect(result.multiplier, greaterThan(1.0));
        expect(result.multipliedXp, greaterThan(result.baseXp));
      });
    });

    group('getLevelFromXP', () {
      test('returns level 1 for 0 XP', () {
        expect(XPCalculator.getLevelFromXP(0), equals(1));
      });

      test('returns level 1 for XP below level 2 threshold', () {
        expect(XPCalculator.getLevelFromXP(50), equals(1));
        expect(XPCalculator.getLevelFromXP(99), equals(1));
      });

      test('returns level 2 at exactly 100 XP', () {
        expect(XPCalculator.getLevelFromXP(100), equals(2));
      });

      test('returns correct levels for various XP amounts', () {
        expect(XPCalculator.getLevelFromXP(250), equals(3));
        expect(XPCalculator.getLevelFromXP(500), equals(4));
        expect(XPCalculator.getLevelFromXP(800), equals(5));
        expect(XPCalculator.getLevelFromXP(5000), equals(10));
      });

      test('returns max level for very high XP', () {
        expect(XPCalculator.getLevelFromXP(999999), equals(GameConstants.maxLevel));
      });
    });

    group('calculateLevelProgress', () {
      test('returns 0.0 at start of level', () {
        // Level 1 starts at 0 XP, Level 2 at 100 XP
        expect(XPCalculator.calculateLevelProgress(0, 1), equals(0.0));
      });

      test('returns 0.5 at midpoint of level', () {
        // Level 1: 0-99, midpoint is 50
        final progress = XPCalculator.calculateLevelProgress(50, 1);
        expect(progress, closeTo(0.5, 0.01));
      });

      test('returns 1.0 for max level', () {
        expect(XPCalculator.calculateLevelProgress(99999, GameConstants.maxLevel), equals(1.0));
      });

      test('clamps to 0.0-1.0 range', () {
        final progress = XPCalculator.calculateLevelProgress(1000, 2);
        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      });
    });

    group('checkForLevelUp', () {
      test('detects level up correctly', () {
        final result = XPCalculator.checkForLevelUp(
          currentTotalXp: 90,
          currentLevel: 1,
          xpToAdd: 20, // 90 + 20 = 110, should be level 2
        );

        expect(result.didLevelUp, isTrue);
        expect(result.previousLevel, equals(1));
        expect(result.newLevel, equals(2));
        expect(result.levelsGained, equals(1));
        expect(result.gemsEarned, equals(GameConstants.gemsPerLevelUp));
      });

      test('detects multiple level ups', () {
        final result = XPCalculator.checkForLevelUp(
          currentTotalXp: 0,
          currentLevel: 1,
          xpToAdd: 500, // Should reach level 4
        );

        expect(result.didLevelUp, isTrue);
        expect(result.levelsGained, equals(3));
        expect(result.newLevel, equals(4));
        expect(result.gemsEarned, equals(3 * GameConstants.gemsPerLevelUp));
      });

      test('returns no level up when XP not enough', () {
        final result = XPCalculator.checkForLevelUp(
          currentTotalXp: 50,
          currentLevel: 1,
          xpToAdd: 10, // 60 total, still level 1
        );

        expect(result.didLevelUp, isFalse);
        expect(result.newLevel, equals(1));
        expect(result.levelsGained, equals(0));
        expect(result.gemsEarned, equals(0));
      });

      test('includes correct title and emoji for new level', () {
        final result = XPCalculator.checkForLevelUp(
          currentTotalXp: 90,
          currentLevel: 1,
          xpToAdd: 20,
        );

        expect(result.newTitle, equals(GameConstants.getTitleForLevel(2)));
        expect(result.newEmoji, equals(GameConstants.getEmojiForLevel(2)));
      });
    });
  });
}
