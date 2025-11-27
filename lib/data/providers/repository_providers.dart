import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/progress_repository.dart';

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Provider for SessionRepository
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

/// Provider for ProgressRepository
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});
