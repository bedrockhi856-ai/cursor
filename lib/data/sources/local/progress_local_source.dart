import 'package:hive/hive.dart';
import '../../models/user_progress.dart';
import 'hive_service.dart';

/// Local data source for UserProgress operations
class ProgressLocalDataSource {
  Box<UserProgress> get _box => HiveService.progressBox;

  /// Get progress for a user
  UserProgress? getProgress(String oderId) {
    return _box.get(oderId);
  }

  /// Get or create progress for a user
  UserProgress getOrCreateProgress(String userId) {
    return _box.get(userId) ?? UserProgress.initial(userId);
  }

  /// Save or update progress
  Future<void> saveProgress(UserProgress progress) async {
    await _box.put(progress.userId, progress);
  }

  /// Delete progress for a user
  Future<void> deleteProgress(String userId) async {
    await _box.delete(userId);
  }

  /// Check if progress exists
  bool hasProgress(String userId) {
    return _box.containsKey(userId);
  }
}
