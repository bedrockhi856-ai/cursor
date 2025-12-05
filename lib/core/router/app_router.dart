import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/onboarding/age_screen.dart';
import '../../screens/onboarding/phone_usage_screen.dart';
import '../../screens/onboarding/professional_result_screen.dart';
import '../../screens/onboarding/first_screen.dart';
import '../../screens/onboarding/second_screen.dart';
import '../../screens/onboarding/guide_intro_screen.dart';
import '../../screens/onboarding/character_selection_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/map/map_screen.dart';
import '../../screens/stats/stats_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/focus/timer_setup_screen.dart';
import '../../screens/focus/focus_timer_screen.dart';
import '../../data/providers/user_provider.dart';
import 'app_shell.dart';

/// Route names for type-safe navigation
class AppRoutes {
  // Onboarding
  static const String onboardingAge = '/onboarding/age';
  static const String onboardingPhoneUsage = '/onboarding/phone-usage';
  static const String onboardingResult = '/onboarding/result';
  static const String onboardingFirst = '/onboarding/first';
  static const String onboardingSecond = '/onboarding/second';
  static const String onboardingGuideIntro = '/onboarding/guide-intro';
  static const String onboardingCharacter = '/onboarding/character';

  // Main App (with shell/nav bar)
  static const String home = '/home';
  static const String map = '/map';
  static const String stats = '/stats';
  static const String profile = '/profile';

  // Focus flow
  static const String timerSetup = '/focus/setup';
  static const String focusTimer = '/focus/timer';
}

/// GoRouter configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  final isOnboardingComplete = ref.watch(isOnboardingCompleteProvider);
  
  // Debug: Log router initialization
  debugPrint('🔄 Router rebuilding: isOnboardingComplete=$isOnboardingComplete');

  return GoRouter(
    // TODO: Restore after testing: isOnboardingComplete ? AppRoutes.home : AppRoutes.onboardingAge
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Onboarding routes
      GoRoute(
        path: AppRoutes.onboardingAge,
        name: 'onboarding-age',
        builder: (context, state) => const AgeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPhoneUsage,
        name: 'onboarding-phone-usage',
        builder: (context, state) {
          final age = state.extra as int? ?? 18;
          return PhoneUsageScreen(age: age);
        },
      ),
      GoRoute(
        path: AppRoutes.onboardingResult,
        name: 'onboarding-result',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ProfessionalResultScreen(
            age: data['age'] ?? 18,
            phoneUsageHours: data['phoneUsage'] ?? 3,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.onboardingFirst,
        name: 'onboarding-first',
        builder: (context, state) => const FirstScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingSecond,
        name: 'onboarding-second',
        builder: (context, state) => const SecondScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingGuideIntro,
        name: 'onboarding-guide-intro',
        builder: (context, state) => const GuideIntroScreen(),
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
              child: HomeScreen(),
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
    ],

    // Redirect logic
    redirect: (context, state) {
      final location = state.matchedLocation;
      
      // If onboarding complete and trying to access onboarding, go to home
      if (isOnboardingComplete && location.startsWith('/onboarding')) {
        return AppRoutes.home;
      }
      
      // If onboarding not complete and trying to access main app, go to onboarding
      if (!isOnboardingComplete && 
          !location.startsWith('/onboarding') &&
          location != '/') {
        return AppRoutes.onboardingAge;
      }
      
      return null;
    },
  );
});
