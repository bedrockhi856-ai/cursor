import 'package:flutter_test/flutter_test.dart';
import 'package:study_buddy/utils/streak_calculator.dart';
import 'package:study_buddy/core/constants/game_constants.dart';

void main() {
  group('StreakCalculator', () {
    group('shouldIncrementStreak', () {
      test('returns true for first ever activity (null lastActiveDate)', () {
        expect(
          StreakCalculator.shouldIncrementStreak(
            lastActiveDate: null,
            todayFocusMinutes: 0,
          ),
          isTrue,
        );
      });

      test('returns false if already active today', () {
        final now = DateTime.now();
        expect(
          StreakCalculator.shouldIncrementStreak(
            lastActiveDate: now,
            todayFocusMinutes: 10,
          ),
          isFalse,
        );
      });

      test('returns true if last active yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(
          StreakCalculator.shouldIncrementStreak(
            lastActiveDate: yesterday,
            todayFocusMinutes: 0,
          ),
          isTrue,
        );
      });

      test('returns true if more than 1 day gap (starting fresh)', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        expect(
          StreakCalculator.shouldIncrementStreak(
            lastActiveDate: twoDaysAgo,
            todayFocusMinutes: 0,
          ),
          isTrue,
        );
      });
    });

    group('shouldResetStreak', () {
      test('returns false for null lastActiveDate', () {
        expect(
          StreakCalculator.shouldResetStreak(lastActiveDate: null),
          isFalse,
        );
      });

      test('returns false if active today', () {
        final now = DateTime.now();
        expect(
          StreakCalculator.shouldResetStreak(lastActiveDate: now),
          isFalse,
        );
      });

      test('returns false if active yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(
          StreakCalculator.shouldResetStreak(lastActiveDate: yesterday),
          isFalse,
        );
      });

      test('returns true if more than 1 day gap', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        expect(
          StreakCalculator.shouldResetStreak(lastActiveDate: twoDaysAgo),
          isTrue,
        );
      });

      test('returns true if a week ago', () {
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        expect(
          StreakCalculator.shouldResetStreak(lastActiveDate: weekAgo),
          isTrue,
        );
      });
    });

    group('calculateStreakUpdate', () {
      test('resets streak when more than 1 day gap', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        
        final result = StreakCalculator.calculateStreakUpdate(
          lastActiveDate: threeDaysAgo,
          currentStreak: 10,
          longestStreak: 15,
          todayFocusMinutes: 0,
          sessionFocusMinutes: 25,
        );

        expect(result.streakBroken, isTrue);
        expect(result.newStreak, equals(1)); // Reset to day 1
        expect(result.newLongestStreak, equals(15)); // Longest preserved
        expect(result.streakIncremented, isFalse);
      });

      test('increments streak on new day after yesterday activity', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        final result = StreakCalculator.calculateStreakUpdate(
          lastActiveDate: yesterday,
          currentStreak: 5,
          longestStreak: 10,
          todayFocusMinutes: 0,
          sessionFocusMinutes: 25,
        );

        expect(result.streakIncremented, isTrue);
        expect(result.streakBroken, isFalse);
        expect(result.newStreak, equals(6));
      });

      test('maintains streak on same day activity', () {
        final today = DateTime.now();
        
        final result = StreakCalculator.calculateStreakUpdate(
          lastActiveDate: today,
          currentStreak: 5,
          longestStreak: 10,
          todayFocusMinutes: 10, // Already active today
          sessionFocusMinutes: 25,
        );

        expect(result.streakIncremented, isFalse);
        expect(result.streakBroken, isFalse);
        expect(result.newStreak, equals(5)); // Same streak
      });

      test('updates longest streak when exceeded', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        final result = StreakCalculator.calculateStreakUpdate(
          lastActiveDate: yesterday,
          currentStreak: 10,
          longestStreak: 10,
          todayFocusMinutes: 0,
          sessionFocusMinutes: 25,
        );

        expect(result.newStreak, equals(11));
        expect(result.newLongestStreak, equals(11)); // New record!
      });

      test('detects milestone and awards gems', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        // Going from 6 to 7 should hit a milestone
        final result = StreakCalculator.calculateStreakUpdate(
          lastActiveDate: yesterday,
          currentStreak: 6,
          longestStreak: 10,
          todayFocusMinutes: 0,
          sessionFocusMinutes: 25,
        );

        expect(result.newStreak, equals(7));
        expect(result.isMilestone, isTrue);
        expect(result.milestoneReached, equals(7));
        expect(result.gemsEarned, greaterThan(0));
      });

      test('no gems on non-milestone day', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        // Going from 4 to 5 is not a milestone
        final result = StreakCalculator.calculateStreakUpdate(
          lastActiveDate: yesterday,
          currentStreak: 4,
          longestStreak: 10,
          todayFocusMinutes: 0,
          sessionFocusMinutes: 25,
        );

        expect(result.newStreak, equals(5));
        expect(result.isMilestone, isFalse);
        expect(result.gemsEarned, equals(0));
      });
    });

    group('isMilestone', () {
      test('recognizes 3-day milestone', () {
        expect(StreakCalculator.isMilestone(3), isTrue);
      });

      test('recognizes 7-day milestone', () {
        expect(StreakCalculator.isMilestone(7), isTrue);
      });

      test('recognizes 14-day milestone', () {
        expect(StreakCalculator.isMilestone(14), isTrue);
      });

      test('recognizes 30-day milestone', () {
        expect(StreakCalculator.isMilestone(30), isTrue);
      });

      test('does not recognize non-milestone days', () {
        expect(StreakCalculator.isMilestone(1), isFalse);
        expect(StreakCalculator.isMilestone(2), isFalse);
        expect(StreakCalculator.isMilestone(5), isFalse);
        expect(StreakCalculator.isMilestone(10), isFalse);
        expect(StreakCalculator.isMilestone(15), isFalse);
      });
    });

    group('getNextMilestone', () {
      test('returns 3 for streak of 0', () {
        expect(StreakCalculator.getNextMilestone(0), equals(3));
      });

      test('returns 3 for streak of 1', () {
        expect(StreakCalculator.getNextMilestone(1), equals(3));
      });

      test('returns 7 for streak of 3', () {
        expect(StreakCalculator.getNextMilestone(3), equals(7));
      });

      test('returns 7 for streak of 5', () {
        expect(StreakCalculator.getNextMilestone(5), equals(7));
      });

      test('returns 14 for streak of 7', () {
        expect(StreakCalculator.getNextMilestone(7), equals(14));
      });
    });

    group('getDaysToNextMilestone', () {
      test('returns 3 for streak of 0', () {
        expect(StreakCalculator.getDaysToNextMilestone(0), equals(3));
      });

      test('returns 2 for streak of 1', () {
        expect(StreakCalculator.getDaysToNextMilestone(1), equals(2));
      });

      test('returns 4 for streak of 3', () {
        expect(StreakCalculator.getDaysToNextMilestone(3), equals(4));
      });
    });

    group('metDailyStreakRequirement', () {
      test('returns false for 0 minutes', () {
        expect(StreakCalculator.metDailyStreakRequirement(0), isFalse);
      });

      test('returns false for minutes below minimum', () {
        expect(
          StreakCalculator.metDailyStreakRequirement(
            GameConstants.minimumDailyMinutesForStreak - 1,
          ),
          isFalse,
        );
      });

      test('returns true for exactly minimum minutes', () {
        expect(
          StreakCalculator.metDailyStreakRequirement(
            GameConstants.minimumDailyMinutesForStreak,
          ),
          isTrue,
        );
      });

      test('returns true for minutes above minimum', () {
        expect(StreakCalculator.metDailyStreakRequirement(60), isTrue);
      });
    });

    group('isStreakAtRisk', () {
      test('returns false for 0 streak', () {
        expect(
          StreakCalculator.isStreakAtRisk(
            lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
            currentStreak: 0,
          ),
          isFalse,
        );
      });

      test('returns false for null lastActiveDate', () {
        expect(
          StreakCalculator.isStreakAtRisk(
            lastActiveDate: null,
            currentStreak: 5,
          ),
          isFalse,
        );
      });

      test('returns false if already active today', () {
        expect(
          StreakCalculator.isStreakAtRisk(
            lastActiveDate: DateTime.now(),
            currentStreak: 5,
          ),
          isFalse,
        );
      });
    });

    group('getTimeUntilStreakExpires', () {
      test('returns positive duration', () {
        final duration = StreakCalculator.getTimeUntilStreakExpires();
        expect(duration.isNegative, isFalse);
      });

      test('returns duration less than 24 hours', () {
        final duration = StreakCalculator.getTimeUntilStreakExpires();
        expect(duration.inHours, lessThan(24));
      });
    });
  });
}
