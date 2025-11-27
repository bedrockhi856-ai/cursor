import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../sources/local/user_local_source.dart';

/// Repository for User operations
/// Abstracts data access and provides a clean API
class UserRepository {
  final UserLocalDataSource _localSource;
  final Uuid _uuid;

  UserRepository({
    UserLocalDataSource? localSource,
    Uuid? uuid,
  })  : _localSource = localSource ?? UserLocalDataSource(),
        _uuid = uuid ?? const Uuid();

  /// Get the current user, or null if not exists
  User? getCurrentUser() {
    return _localSource.getCurrentUser();
  }

  /// Check if a user exists
  bool hasUser() {
    return _localSource.hasUser();
  }

  /// Check if onboarding is complete
  bool isOnboardingComplete() {
    return _localSource.isOnboardingComplete();
  }

  /// Create a new user (during onboarding)
  Future<User> createUser({
    int age = 18,
    int dailyPhoneUsageHours = 3,
  }) async {
    final user = User.create(
      id: _uuid.v4(),
      age: age,
      dailyPhoneUsageHours: dailyPhoneUsageHours,
    );
    debugPrint('💾 Creating user: age=$age, phoneUsage=$dailyPhoneUsageHours');
    await _localSource.saveUser(user);
    debugPrint('✅ User created and saved to Hive');
    return user;
  }

  /// Update user's age
  Future<User?> updateAge(int age) async {
    final user = getCurrentUser();
    if (user == null) return null;

    final updated = user.copyWith(age: age);
    await _localSource.saveUser(updated);
    return updated;
  }

  /// Update user's name
  Future<User?> updateName(String name) async {
    final user = getCurrentUser();
    if (user == null) return null;

    final updated = user.copyWith(name: name);
    await _localSource.saveUser(updated);
    return updated;
  }

  /// Update user's daily phone usage
  Future<User?> updatePhoneUsage(int hours) async {
    final user = getCurrentUser();
    if (user == null) return null;

    final updated = user.copyWith(dailyPhoneUsageHours: hours);
    await _localSource.saveUser(updated);
    return updated;
  }

  /// Update user's character selection
  Future<User?> updateCharacter(String characterId) async {
    final user = getCurrentUser();
    if (user == null) {
      debugPrint('❌ Cannot update character: no user found!');
      return null;
    }

    debugPrint('💾 Updating character to: $characterId');
    final updated = user.copyWith(characterId: characterId);
    await _localSource.saveUser(updated);
    debugPrint('✅ Character updated and saved');
    return updated;
  }

  /// Mark onboarding as complete
  Future<User?> completeOnboarding() async {
    final user = getCurrentUser();
    if (user == null) {
      debugPrint('❌ Cannot complete onboarding: no user found!');
      return null;
    }

    debugPrint('💾 Marking onboarding as complete...');
    final updated = user.copyWith(onboardingCompleted: true);
    await _localSource.saveUser(updated);
    
    // Verify it was saved
    final verified = getCurrentUser();
    debugPrint('✅ Onboarding completed! Verified: ${verified?.onboardingCompleted}');
    debugPrint('📊 Final user state: id=${verified?.id}, age=${verified?.age}, character=${verified?.characterId}');
    
    return updated;
  }

  /// Save a complete user object
  Future<void> saveUser(User user) async {
    await _localSource.saveUser(user);
  }

  /// Delete the current user (reset app)
  Future<void> deleteUser() async {
    await _localSource.deleteUser();
  }
}
