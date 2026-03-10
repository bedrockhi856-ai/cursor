import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import 'repository_providers.dart';

/// State notifier for managing the current user
class UserNotifier extends StateNotifier<User?> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(_repository.getCurrentUser());

  /// Reload user from storage
  void refresh() {
    state = _repository.getCurrentUser();
  }

  /// Create a new user during onboarding
  Future<User> createUser({int age = 18, int phoneUsage = 3}) async {
    final user = await _repository.createUser(
      age: age,
      dailyPhoneUsageHours: phoneUsage,
    );
    state = user;
    return user;
  }

  /// Update user's age
  Future<void> updateAge(int age) async {
    final updated = await _repository.updateAge(age);
    if (updated != null) state = updated;
  }

  /// Update user's name
  Future<void> updateName(String name) async {
    final updated = await _repository.updateName(name);
    if (updated != null) state = updated;
  }

  /// Update phone usage hours
  Future<void> updatePhoneUsage(int hours) async {
    final updated = await _repository.updatePhoneUsage(hours);
    if (updated != null) state = updated;
  }

  /// Update character selection
  Future<void> updateCharacter(String characterId) async {
    final updated = await _repository.updateCharacter(characterId);
    if (updated != null) state = updated;
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    final updated = await _repository.completeOnboarding();
    if (updated != null) state = updated;
  }

  /// Update starting commitment minutes (from onboarding)
  Future<void> updateStartingCommitment(int minutes) async {
    final updated = await _repository.updateStartingCommitment(minutes);
    if (updated != null) state = updated;
  }

  /// Update ultimate goal minutes (from onboarding)
  Future<void> updateUltimateGoal(int minutes) async {
    final updated = await _repository.updateUltimateGoal(minutes);
    if (updated != null) state = updated;
  }

  /// Update custom daily minutes (from CustomTimeScreen)
  Future<void> updateCustomTime(int minutes) async {
    final updated = await _repository.updateCustomTime(minutes);
    if (updated != null) state = updated;
  }

  /// Update goal speed in months (from GoalSpeedScreen)
  Future<void> updateGoalSpeed(double months) async {
    final updated = await _repository.updateGoalSpeed(months);
    if (updated != null) state = updated;
  }

  /// Delete user (reset app)
  Future<void> deleteUser() async {
    await _repository.deleteUser();
    state = null;
  }
}

/// Provider for the current user state
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});

/// In-memory flag: true only after the user finishes onboarding in the
/// current app session.  Resets to false on every hot-restart / cold-start,
/// so the onboarding flow always shows when the app is launched fresh.
final onboardingDoneProvider = StateProvider<bool>((ref) => false);

/// Provider to check if onboarding is complete.
/// Backed by the in-memory [onboardingDoneProvider] so it resets on
/// hot-restart — intentionally never persisted to Hive.
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  return ref.watch(onboardingDoneProvider);
});

/// Provider for user's display name
final userNameProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  return user?.name ?? 'Friend';
});
