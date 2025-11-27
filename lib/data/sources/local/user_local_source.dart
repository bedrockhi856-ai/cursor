import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../models/user.dart';
import 'hive_service.dart';

/// Local data source for User operations
class UserLocalDataSource {
  Box<User> get _box => HiveService.userBox;

  static const String _currentUserKey = 'current_user';

  /// Get the current user
  User? getCurrentUser() {
    final user = _box.get(_currentUserKey);
    debugPrint('🔍 getCurrentUser() called: found user = ${user != null}');
    if (user != null) {
      debugPrint('🔍 User details: age=${user.age}, character=${user.characterId}, onboarding=${user.onboardingCompleted}');
    }
    return user;
  }

  /// Save or update the current user
  Future<void> saveUser(User user) async {
    debugPrint('💿 Saving user to Hive: onboardingCompleted=${user.onboardingCompleted}');
    await _box.put(_currentUserKey, user);
    debugPrint('✅ User saved to Hive box');
  }

  /// Delete the current user
  Future<void> deleteUser() async {
    await _box.delete(_currentUserKey);
  }

  /// Check if a user exists
  bool hasUser() {
    return _box.containsKey(_currentUserKey);
  }

  /// Check if onboarding is complete
  bool isOnboardingComplete() {
    final user = getCurrentUser();
    return user?.onboardingCompleted ?? false;
  }
}
