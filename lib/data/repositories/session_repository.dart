import 'package:uuid/uuid.dart';
import '../models/focus_session.dart';
import '../sources/local/session_local_source.dart';

/// Repository for FocusSession operations
class SessionRepository {
  final SessionLocalDataSource _localSource;
  final Uuid _uuid;

  SessionRepository({
    SessionLocalDataSource? localSource,
    Uuid? uuid,
  })  : _localSource = localSource ?? SessionLocalDataSource(),
        _uuid = uuid ?? const Uuid();

  /// Get all sessions for a user
  List<FocusSession> getSessionsForUser(String userId) {
    return _localSource.getSessionsForUser(userId);
  }

  /// Get a specific session
  FocusSession? getSession(String id) {
    return _localSource.getSession(id);
  }

  /// Start a new focus session
  Future<FocusSession> startSession({
    required String userId,
    required int targetMinutes,
  }) async {
    final session = FocusSession.start(
      id: _uuid.v4(),
      userId: userId,
      targetMinutes: targetMinutes,
    );
    await _localSource.saveSession(session);
    return session;
  }

  /// Complete a session successfully
  Future<FocusSession> completeSession(String sessionId) async {
    final session = _localSource.getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    final completed = session.complete();
    await _localSource.saveSession(completed);
    return completed;
  }

  /// Mark a session as failed
  Future<FocusSession> failSession(String sessionId) async {
    final session = _localSource.getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    final failed = session.fail();
    await _localSource.saveSession(failed);
    return failed;
  }

  /// Cancel a session
  Future<FocusSession> cancelSession(String sessionId) async {
    final session = _localSource.getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    final cancelled = session.cancel();
    await _localSource.saveSession(cancelled);
    return cancelled;
  }

  /// Get today's sessions for a user
  List<FocusSession> getTodaysSessions(String userId) {
    return _localSource.getTodaysSessions(userId);
  }

  /// Get sessions in a date range
  List<FocusSession> getSessionsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return _localSource.getSessionsInRange(userId, start, end);
  }

  /// Get total focus minutes for a user
  int getTotalFocusMinutes(String userId) {
    return _localSource.getTotalFocusMinutes(userId);
  }

  /// Get completed session count
  int getCompletedSessionCount(String userId) {
    return _localSource.getCompletedSessionCount(userId);
  }

  /// Delete a session
  Future<void> deleteSession(String id) async {
    await _localSource.deleteSession(id);
  }

  /// Clear all sessions for a user
  Future<void> clearUserSessions(String userId) async {
    await _localSource.clearUserSessions(userId);
  }
}
