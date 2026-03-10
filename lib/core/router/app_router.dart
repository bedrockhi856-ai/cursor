import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/onboarding/goal_selection_screen.dart';
import '../../screens/onboarding/future_goal_screen.dart';
import '../../screens/onboarding/success_rate_screen.dart';
import '../../screens/onboarding/start_time_screen.dart';
import '../../screens/onboarding/custom_time_screen.dart';
import '../../screens/onboarding/goal_speed_screen.dart';
import '../../screens/onboarding/consistency_screen.dart';
import '../../screens/home/home_screen_nodes.dart';
import '../../screens/map/map_screen.dart';
import '../../screens/stats/stats_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/focus/timer_setup_screen.dart';
import '../../screens/focus/focus_timer_screen.dart';
import '../../screens/story/story_screen.dart';
import '../../data/providers/user_provider.dart';
import 'app_shell.dart';

/// Route names for type-safe navigation
class AppRoutes {
  // Onboarding
  static const String onboardingGoal = '/onboarding/goal';
  static const String onboardingTarget = '/onboarding/target';
  static const String onboardingPsychology = '/onboarding/psychology';
  static const String onboardingCommitment = '/onboarding/commitment';
  static const String onboardingCustomTime = '/onboarding/custom-time';
  static const String onboardingGrowthPace = '/onboarding/growth-pace';
  static const String onboardingConsistency = '/onboarding/consistency';

  // Main App (with shell/nav bar)
  static const String home = '/home';
  static const String map = '/map';
  static const String stats = '/stats';
  static const String profile = '/profile';

  // Focus flow
  static const String timerSetup = '/focus/setup';
  static const String focusTimer = '/focus/timer';
  
  // Story
  static const String story = '/story';
}

/// GoRouter configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  // Get initial state
  final isOnboardingComplete = ref.read(isOnboardingCompleteProvider);
  
  // Debug: Log router initialization
  debugPrint('🔄 Router created: isOnboardingComplete=$isOnboardingComplete');

  return GoRouter(
    initialLocation: isOnboardingComplete ? AppRoutes.home : AppRoutes.onboardingGoal,
    debugLogDiagnostics: kDebugMode,
    routes: [
      // Onboarding routes
      GoRoute(
        path: AppRoutes.onboardingGoal,
        name: 'onboarding-goal',
        builder: (context, state) => const GoalSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingTarget,
        name: 'onboarding-target',
        builder: (context, state) => const FutureGoalScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPsychology,
        name: 'onboarding-psychology',
        builder: (context, state) => const SuccessRateScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingCommitment,
        name: 'onboarding-commitment',
        builder: (context, state) => const StartTimeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingCustomTime,
        name: 'onboarding-custom-time',
        builder: (context, state) => const CustomTimeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingGrowthPace,
        name: 'onboarding-growth-pace',
        builder: (context, state) => const GoalSpeedScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingConsistency,
        name: 'onboarding-consistency',
        builder: (context, state) => const ConsistencyScreen(),
      ),

      // Main app with shell (bottom nav bar)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreenNodes(),
            ),
          ),
          GoRoute(
            path: AppRoutes.map,
            name: 'map',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.stats,
            name: 'stats',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StatsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Focus flow (outside shell - full screen)
      GoRoute(
        path: AppRoutes.timerSetup,
        name: 'timer-setup',
        builder: (context, state) => const TimerSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.focusTimer,
        name: 'focus-timer',
        builder: (context, state) {
          // Get duration from query parameter or extra, default to 25
          final durationStr = state.uri.queryParameters['duration'];
          final minutes = durationStr != null ? int.tryParse(durationStr) ?? 25 : (state.extra as int? ?? 25);
          return FocusTimerScreen(durationMinutes: minutes);
        },
      ),
      
      // Story screen (full screen)
      GoRoute(
        path: AppRoutes.story,
        name: 'story',
        builder: (context, state) => const StoryScreen(),
      ),
    ],

    // Redirect logic - prevent accessing onboarding after completion
    redirect: (context, state) {
      final location = state.matchedLocation;
      // Read once - don't watch to avoid rebuild loops
      final onboardingComplete = ref.read(isOnboardingCompleteProvider);
      
      debugPrint('🔄 Redirect check: location=$location, onboardingComplete=$onboardingComplete');
      
      // onboarding is considered "done" when goalSpeedMonths has been saved
      // (the step right before ConsistencyScreen).  onboardingCompleted is
      // intentionally never set to true.
      
      // If onboarding complete and trying to access onboarding, go to home
      if (onboardingComplete && location.startsWith('/onboarding')) {
        debugPrint('🔄 Redirecting to home (onboarding complete)');
        return AppRoutes.home;
      }
      
      // If onboarding NOT complete and at root, go to onboarding goal
      if (!onboardingComplete && location == '/') {
        debugPrint('🔄 Redirecting to onboarding goal (root access)');
        return AppRoutes.onboardingGoal;
      }
      
      // No other redirects - allow all navigation
      return null;
    },
  );
});