import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user.dart';
import '../../models/focus_session.dart';
import '../../models/user_progress.dart';
import '../../models/player_stats.dart';

/// Hive box names
class HiveBoxes {
  static const String user = 'user_box';
  static const String sessions = 'sessions_box';
  static const String progress = 'progress_box';
  static const String settings = 'settings_box';
  static const String playerStats = 'player_stats';
}

/// Initialize Hive and register all adapters
class HiveService {
  static bool _initialized = false;

  /// Initialize Hive for Flutter
  static Future<void> init() async {
    if (_initialized) {
      debugPrint('🔄 Hive already initialized, skipping...');
      return;
    }

    debugPrint('🚀 Initializing Hive...');
    await Hive.initFlutter();
    debugPrint('✅ Hive.initFlutter() completed');

    // Register adapters
    debugPrint('📝 Registering Hive adapters...');
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(FocusSessionAdapter());
    Hive.registerAdapter(SessionStatusAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(PlayerStatsAdapter());
    debugPrint('✅ Adapters registered');

    // Open boxes
    debugPrint('📦 Opening Hive boxes...');
    final userBox = await Hive.openBox<User>(HiveBoxes.user);
    await Hive.openBox<FocusSession>(HiveBoxes.sessions);
    await Hive.openBox<UserProgress>(HiveBoxes.progress);
    await Hive.openBox(HiveBoxes.settings);
    await Hive.openBox<PlayerStats>(HiveBoxes.playerStats);
    debugPrint('✅ All boxes opened');
    
    // Check what's in the user box
    debugPrint('🔍 User box contains ${userBox.length} items');
    if (userBox.isNotEmpty) {
      debugPrint('🔍 Keys in user box: ${userBox.keys.toList()}');
      final user = userBox.get('current_user');
      debugPrint('🔍 Current user from box: $user');
      debugPrint('🔍 User onboarding status: ${user?.onboardingCompleted}');
    }

    _initialized = true;
    debugPrint('✅ Hive initialization complete!');
  }

  /// Get the user box
  static Box<User> get userBox => Hive.box<User>(HiveBoxes.user);

  /// Get the sessions box
  static Box<FocusSession> get sessionsBox => Hive.box<FocusSession>(HiveBoxes.sessions);

  /// Get the progress box
  static Box<UserProgress> get progressBox => Hive.box<UserProgress>(HiveBoxes.progress);

  /// Get the settings box
  static Box get settingsBox => Hive.box(HiveBoxes.settings);

  /// Get the player stats box
  static Box<PlayerStats> get playerStatsBox => Hive.box<PlayerStats>(HiveBoxes.playerStats);

  /// Clear all data (for testing or reset)
  static Future<void> clearAll() async {
    await userBox.clear();
    await sessionsBox.clear();
    await progressBox.clear();
    await settingsBox.clear();
    await playerStatsBox.clear();
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}
