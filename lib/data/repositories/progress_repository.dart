import '../models/user_progress.dart';
import '../models/focus_session.dart';
import '../sources/local/progress_local_source.dart';

/// Repository for UserProgress operations
class ProgressRepository {
  final ProgressLocalDataSource _localSource;

  ProgressRepository({
    ProgressLocalDataSource? localSource,
  }) : _localSource = localSource ?? ProgressLocalDataSource();

  /// Get progress for a user
  UserProgress? getProgress(String userId) {
    return _localSource.getProgress(userId);
  }

  /// Get or create progress for a user
  UserProgress getOrCreateProgress(String userId) {
    return _localSource.getOrCreateProgress(userId);
  }

  /// Update progress after a session completes
  Future<UserProgress> recordSession(
    String userId,
    FocusSession session,
  ) async {
    final progress = getOrCreateProgress(userId);

    UserProgress updated;
    if (session.status == SessionStatus.completed) {
      updated = progress.addCompletedSession(session.actualDurationMinutes);
    } else {
      updated = progress.addFailedSession(session.actualDurationMinutes);
    }

    await _localSource.saveProgress(updated);
    return updated;
  }

  /// Save progress directly
  Future<void> saveProgress(UserProgress progress) async {
    await _localSource.saveProgress(progress);
  }

  /// Delete progress for a user
  Future<void> deleteProgress(String userId) async {
    await _localSource.deleteProgress(userId);
  }

  /// Check if user has progress
  bool hasProgress(String userId) {
    return _localSource.hasProgress(userId);
  }
}
