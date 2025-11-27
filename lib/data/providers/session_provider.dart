import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/focus_session.dart';
import '../models/user_progress.dart';
import '../repositories/session_repository.dart';
import '../repositories/progress_repository.dart';
import 'repository_providers.dart';
import 'user_provider.dart';

/// State for an active focus session
class ActiveSessionState {
  final FocusSession? session;
  final bool isActive;
  final int remainingSeconds;

  const ActiveSessionState({
    this.session,
    this.isActive = false,
    this.remainingSeconds = 0,
  });

  ActiveSessionState copyWith({
    FocusSession? session,
    bool? isActive,
    int? remainingSeconds,
  }) {
    return ActiveSessionState(
      session: session ?? this.session,
      isActive: isActive ?? this.isActive,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

/// Notifier for managing active focus sessions
class SessionNotifier extends StateNotifier<ActiveSessionState> {
  final SessionRepository _sessionRepository;
  final ProgressRepository _progressRepository;
  final String? _userId;

  SessionNotifier(
    this._sessionRepository,
    this._progressRepository,
    this._userId,
  ) : super(const ActiveSessionState());

  /// Start a new focus session
  Future<void> startSession(int targetMinutes) async {
    if (_userId == null) return;

    final session = await _sessionRepository.startSession(
      userId: _userId!,
      targetMinutes: targetMinutes,
    );

    state = ActiveSessionState(
      session: session,
      isActive: true,
      remainingSeconds: targetMinutes * 60,
    );
  }

  /// Update remaining time (call from timer)
  void tick() {
    if (!state.isActive || state.remainingSeconds <= 0) return;
    state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
  }

  /// Complete the session successfully
  Future<UserProgress?> completeSession() async {
    if (state.session == null || _userId == null) return null;

    final completed = await _sessionRepository.completeSession(state.session!.id);
    final progress = await _progressRepository.recordSession(_userId!, completed);

    state = const ActiveSessionState();
    return progress;
  }

  /// Fail the session (user gave up)
  Future<UserProgress?> failSession() async {
    if (state.session == null || _userId == null) return null;

    final failed = await _sessionRepository.failSession(state.session!.id);
    final progress = await _progressRepository.recordSession(_userId!, failed);

    state = const ActiveSessionState();
    return progress;
  }

  /// Cancel session without recording
  Future<void> cancelSession() async {
    if (state.session == null) return;

    await _sessionRepository.cancelSession(state.session!.id);
    state = const ActiveSessionState();
  }

  /// Get elapsed time in seconds
  int get elapsedSeconds {
    if (state.session == null) return 0;
    final totalSeconds = state.session!.targetDurationMinutes * 60;
    return totalSeconds - state.remainingSeconds;
  }
}

/// Provider for active session state
final activeSessionProvider =
    StateNotifierProvider<SessionNotifier, ActiveSessionState>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final progressRepo = ref.watch(progressRepositoryProvider);
  final user = ref.watch(userProvider);
  return SessionNotifier(sessionRepo, progressRepo, user?.id);
});

/// Provider for session history
final sessionHistoryProvider = Provider<List<FocusSession>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getSessionsForUser(user.id);
});

/// Provider for today's sessions
final todaysSessionsProvider = Provider<List<FocusSession>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getTodaysSessions(user.id);
});
