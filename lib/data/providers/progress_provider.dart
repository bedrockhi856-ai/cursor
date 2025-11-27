import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import '../repositories/progress_repository.dart';
import 'repository_providers.dart';
import 'user_provider.dart';

/// Notifier for managing user progress
class ProgressNotifier extends StateNotifier<UserProgress?> {
  final ProgressRepository _repository;
  final String? _userId;

  ProgressNotifier(this._repository, this._userId)
      : super(_userId != null ? _repository.getOrCreateProgress(_userId) : null);

  /// Reload progress from storage
  void refresh() {
    if (_userId == null) return;
    state = _repository.getOrCreateProgress(_userId!);
  }

  /// Update progress (called internally after session ends)
  void update(UserProgress progress) {
    state = progress;
  }

  /// Reset progress (for testing)
  Future<void> reset() async {
    if (_userId == null) return;
    await _repository.deleteProgress(_userId!);
    state = UserProgress.initial(_userId!);
    await _repository.saveProgress(state!);
  }
}

/// Provider for user progress state
final progressProvider =
    StateNotifierProvider<ProgressNotifier, UserProgress?>((ref) {
  final repository = ref.watch(progressRepositoryProvider);
  final user = ref.watch(userProvider);
  return ProgressNotifier(repository, user?.id);
});

/// Provider for current level
final currentLevelProvider = Provider<int>((ref) {
  final progress = ref.watch(progressProvider);
  return progress?.currentLevel ?? 1;
});

/// Provider for current streak
final currentStreakProvider = Provider<int>((ref) {
  final progress = ref.watch(progressProvider);
  return progress?.currentStreak ?? 0;
});

/// Provider for total focus time formatted
final totalFocusTimeProvider = Provider<String>((ref) {
  final progress = ref.watch(progressProvider);
  return progress?.formattedTotalTime ?? '0m';
});

/// Provider for completed sessions count
final completedSessionsCountProvider = Provider<int>((ref) {
  final progress = ref.watch(progressProvider);
  return progress?.completedSessions ?? 0;
});

/// Provider for completed levels
final completedLevelsProvider = Provider<List<int>>((ref) {
  final progress = ref.watch(progressProvider);
  return progress?.completedLevels ?? [];
});
