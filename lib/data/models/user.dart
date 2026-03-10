import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int age;

  @HiveField(3)
  final int dailyPhoneUsageHours;

  @HiveField(4)
  final String? characterId;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final bool onboardingCompleted;

  @HiveField(7)
  final int? startingCommitmentMinutes;

  @HiveField(8)
  final int? ultimateGoalMinutes;

  @HiveField(9)
  final int? customDailyMinutes;

  @HiveField(10)
  final double? goalSpeedMonths;

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.dailyPhoneUsageHours,
    this.characterId,
    required this.createdAt,
    this.onboardingCompleted = false,
    this.startingCommitmentMinutes,
    this.ultimateGoalMinutes,
    this.customDailyMinutes,
    this.goalSpeedMonths,
  });

  /// Create a new user with default values
  factory User.create({
    required String id,
    String name = '',
    int age = 18,
    int dailyPhoneUsageHours = 3,
    String? characterId,
  }) {
    return User(
      id: id,
      name: name,
      age: age,
      dailyPhoneUsageHours: dailyPhoneUsageHours,
      characterId: characterId,
      createdAt: DateTime.now(),
      onboardingCompleted: false,
    );
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    int? age,
    int? dailyPhoneUsageHours,
    String? characterId,
    DateTime? createdAt,
    bool? onboardingCompleted,
    int? startingCommitmentMinutes,
    int? ultimateGoalMinutes,
    int? customDailyMinutes,
    double? goalSpeedMonths,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      dailyPhoneUsageHours: dailyPhoneUsageHours ?? this.dailyPhoneUsageHours,
      characterId: characterId ?? this.characterId,
      createdAt: createdAt ?? this.createdAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      startingCommitmentMinutes: startingCommitmentMinutes ?? this.startingCommitmentMinutes,
      ultimateGoalMinutes: ultimateGoalMinutes ?? this.ultimateGoalMinutes,
      customDailyMinutes: customDailyMinutes ?? this.customDailyMinutes,
      goalSpeedMonths: goalSpeedMonths ?? this.goalSpeedMonths,
    );
  }

  /// Calculate years lost to unproductive phone usage
  /// Based on current age and daily usage
  double get unproductiveYearsLost {
    final yearsOfUsage = (age - 12).clamp(0, 100); // Assume phone usage starts at 12
    final hoursPerYear = dailyPhoneUsageHours * 365;
    final totalHours = hoursPerYear * yearsOfUsage;
    return totalHours / (24 * 365); // Convert to years
  }

  /// Calculate potential years that can be regained
  double get regainableYears {
    final remainingYears = (80 - age).clamp(0, 100); // Assume life expectancy 80
    final hoursPerYear = (dailyPhoneUsageHours - 1).clamp(0, 24) * 365; // Reduce by 1 hour
    final totalHours = hoursPerYear * remainingYears;
    return totalHours / (24 * 365);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        dailyPhoneUsageHours,
        characterId,
        createdAt,
        onboardingCompleted,
        startingCommitmentMinutes,
        ultimateGoalMinutes,
        customDailyMinutes,
        goalSpeedMonths,
      ];
}
