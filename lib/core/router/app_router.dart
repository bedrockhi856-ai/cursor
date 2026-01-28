import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/onboarding/mentor_chat_screen.dart';
import '../../screens/onboarding/character_selection_screen.dart';
import '../../screens/home/home_screen_redesigned.dart';
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
  static const String onboardingStory = '/onboarding/story';
  static const String onboardingMentor = '/onboarding/mentor';
  static const String onboardingCharacter = '/onboarding/character';

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
  // Use read instead of watch to prevent router recreation
  final isOnboardingComplete = ref.read(isOnboardingCompleteProvider);
  
  // Debug: Log router initialization
  debugPrint('🔄 Router created: isOnboardingComplete=$isOnboardingComplete');

  return GoRouter(
    initialLocation: isOnboardingComplete ? AppRoutes.home : AppRoutes.onboardingStory,
    debugLogDiagnostics: kDebugMode,
    routes: [
      // Onboarding routes
      GoRoute(
        path: AppRoutes.onboardingStory,
        name: 'onboarding-story',
        builder: (context, state) => const StoryScreen(isOnboarding: true),
      ),
      GoRoute(
        path: AppRoutes.onboardingMentor,
        name: 'onboarding-mentor',
        builder: (context, state) => const MentorChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingCharacter,
        name: 'onboarding-character',
        builder: (context, state) => const CharacterSelectionScreen(),
      ),

      // Main app with shell (bottom nav bar)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreenRedesigned(),
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

    // Redirect logic - only redirect TO onboarding screens, not away from main app
    redirect: (context, state) {
      final location = state.matchedLocation;
      final onboardingComplete = ref.read(isOnboardingCompleteProvider);
      
      debugPrint('🔄 Redirect check: location=$location, onboardingComplete=$onboardingComplete');
      
      // If onboarding complete and trying to access onboarding, go to home
      if (onboardingComplete && location.startsWith('/onboarding')) {
        debugPrint('🔄 Redirecting to home (onboarding complete)');
        return AppRoutes.home;
      }
      
      // If onboarding NOT complete and at root, go to onboarding
      if (!onboardingComplete && location == '/') {
        debugPrint('🔄 Redirecting to onboarding (root access)');
        return AppRoutes.onboardingMentor;
      }
      
      // No other redirects - allow all navigation
      return null;
    },
  );
});
