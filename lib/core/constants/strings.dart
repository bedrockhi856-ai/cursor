/// App-wide string constants
/// Centralized location for all text used in the app
/// This enables easy localization and prevents typos
library;

class AppStrings {
  AppStrings._();

  // ============== APP INFO ==============
  
  static const String appName = 'StudyBuddy';
  static const String appTagline = 'Your Focus Companion';

  // ============== ONBOARDING ==============
  
  static const String onboardingAgeTitle = 'How old are you?';
  static const String onboardingAgeHint = 'Enter your age';
  static const String onboardingPhoneUsageTitle = 'How much time do you spend on your phone?';
  static const String onboardingResultTitle = 'Your Phone Usage Impact';
  static const String onboardingCharacterTitle = 'Choose Your Buddy';
  
  // Phone usage options
  static const List<String> phoneUsageOptions = [
    '1–2 Hours',
    '2–3 Hours',
    '3–4 Hours',
    '4–5 Hours',
  ];

  // ============== HOME SCREEN ==============
  
  static const String homeGreeting = 'Ready to focus, {name}?';
  static const String homeBuddyTitle = 'Your Buddy';
  static const String homeStreakLabel = 'streak';
  static const String homeProductiveLabel = 'productive';
  
  // Motivational messages based on streak
  static String getMotivationalMessage(String name, int streak) {
    if (streak == 0) {
      return "Hey $name! Ready to start your focus journey today?";
    } else if (streak == 1) {
      return "Great start $name! You focused yesterday. Let's keep it going!";
    } else if (streak < 7) {
      return "Awesome $name! $streak days in a row. You're building momentum!";
    } else if (streak < 30) {
      return "Incredible $name! $streak day streak! You're becoming unstoppable!";
    } else if (streak < 100) {
      return "Legend status $name! $streak days of pure focus. Amazing!";
    } else {
      return "You're a focus master $name! $streak days - absolutely inspiring!";
    }
  }

  // ============== FOCUS MODE ==============
  
  static const String focusSetupTitle = 'Set Your Focus Time';
  static const String focusStart = 'Start Focus';
  static const String focusPause = 'Pause';
  static const String focusResume = 'Resume';
  static const String focusQuit = 'Quit Session';
  static const String focusComplete = 'Session Complete!';
  static const String focusSurrender = 'Slide to Surrender';
  static const String focusSurrendered = 'Surrendered!';
  static const String focusBetterLuck = 'Better luck next time';
  
  // Breathing phases
  static const String breatheInhale = 'Inhale';
  static const String breatheHold = 'Hold';
  static const String breatheExhale = 'Exhale';

  // ============== STATS SCREEN ==============
  
  static const String statsTitle = 'Your Stats';
  static const String statsTotalFocusTime = 'Total Focus Time';
  static const String statsSessionsCompleted = 'Sessions Completed';
  static const String statsCurrentStreak = 'Current Streak';
  static const String statsLongestStreak = 'Longest Streak';
  
  static String formatStreak(int days) {
    return '$days ${days == 1 ? 'day' : 'days'}';
  }

  // ============== MAP SCREEN ==============
  
  static const String mapTitle = 'Your Journey';
  
  // Level names (already in game_constants, but duplicated for UI)
  static const List<String> levelNames = [
    'Beginner',
    'Novice',
    'Seeker',
    'Adventurer',
    'Explorer',
    'Champion',
    'Hero',
    'Master',
    'Legend',
    'Summit',
  ];

  // ============== PROFILE SCREEN ==============
  
  static const String profileTitle = 'Profile';
  static const String profileSettings = 'Settings';
  static const String profileLogout = 'Log Out';
  static const String profileDeleteAccount = 'Delete Account';

  // ============== BUTTONS ==============
  
  static const String buttonContinue = 'Continue';
  static const String buttonNext = 'Next';
  static const String buttonBack = 'Back';
  static const String buttonStart = 'Start';
  static const String buttonDone = 'Done';
  static const String buttonCancel = 'Cancel';
  static const String buttonSave = 'Save';
  static const String buttonRetry = 'Try Again';

  // ============== ERRORS ==============
  
  static const String errorGeneric = 'Something went wrong';
  static const String errorNetwork = 'Please check your connection';
  static const String errorLoadingData = 'Failed to load data';
  static const String errorSavingData = 'Failed to save data';

  // ============== GAMIFICATION ==============
  
  static const String xpEarned = '+{xp} XP';
  static const String levelUp = 'Level Up!';
  static const String newLevel = 'Level {level}';
  static const String streakMilestone = '{days} Day Streak!';
  static const String gemsEarned = '+{gems} Gems';
  static const String dailyGoalComplete = 'Daily Goal Complete!';

  // ============== TIME FORMATTING ==============
  
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
  
  static String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ============== FREEDOM SWITCH ==============
  
  static const String freedomSwitchTitle = 'Freedom Switch';
  static const String freedomSwitchSubtitle = 'Turn ON to unlock your potential';
  static const String freedomSwitchUnlocked = 'Your potential is now unlocked!';
  static const String freedomSwitchHoldToBegin = 'Hold to Begin';
  static const String stayFocused = 'Stay Focused';
}
