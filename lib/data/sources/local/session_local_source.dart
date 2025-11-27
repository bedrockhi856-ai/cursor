import 'package:hive/hive.dart';
import '../../models/focus_session.dart';
import 'hive_service.dart';

/// Local data source for FocusSession operations
class SessionLocalDataSource {
  Box<FocusSession> get _box => HiveService.sessionsBox;

  /// Get all sessions for a user
  List<FocusSession> getSessionsForUser(String oderId) {
    return _box.values.where((session) => session.oderId == oderId).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
  }

  /// Get a session by ID
  FocusSession? getSession(String id) {
    return _box.get(id);
  }

  /// Save a new session or update existing
  Future<void> saveSession(FocusSession session) async {
    await _box.put(session.id, session);
  }

  /// Delete a session
  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }

  /// Get sessions for today
  List<FocusSession> getTodaysSessions(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getSessionsForUser(userId).where((session) {
      return session.startTime.isAfter(startOfDay) &&
          session.startTime.isBefore(endOfDay);
    }).toList();
  }

  /// Get sessions for a date range
  List<FocusSession> getSessionsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return getSessionsForUser(userId).where((session) {
      return session.startTime.isAfter(start) && session.startTime.isBefore(end);
    }).toList();
  }

  /// Get total focus minutes for a user
  int getTotalFocusMinutes(String userId) {
    return getSessionsForUser(userId)
        .where((s) => s.status == SessionStatus.completed)
        .fold(0, (sum, session) => sum + session.actualDurationMinutes);
  }

  /// Get count of completed sessions
  int getCompletedSessionCount(String userId) {
    return getSessionsForUser(userId)
        .where((s) => s.status == SessionStatus.completed)
        .length;
  }

  /// Clear all sessions for a user
  Future<void> clearUserSessions(String userId) async {
    final sessions = getSessionsForUser(userId);
    for (final session in sessions) {
      await _box.delete(session.id);
    }
  }
}
