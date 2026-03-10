import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

/// First onboarding screen - Goal Selection
class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  int? selectedIndex;

  final List<GoalOption> goals = const [
    GoalOption(
      emoji: '🚀',
      title: 'Maximize My Academic Performance',
    ),
    GoalOption(
      emoji: '🧠',
      title: 'Build a Bulletproof Study Habit',
    ),
    GoalOption(
      emoji: '🎓',
      title: 'Prepare for a Major Life Milestone',
    ),
    GoalOption(
      emoji: '✨',
      title: 'Personal Growth & Learning Mastery',
    ),
  ];

  void _onContinue() {
    if (selectedIndex != null) {
      // Navigate to psychology hook screen
      context.go(AppRoutes.onboardingPsychology);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Progress Indicator
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: 0.2,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFACC15)),
            ),
          ),

          // Content
          Expanded(
            child: SafeArea(
              child: Column(
                children: [
                  // Title Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What is your goal?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),

                  // Goal List
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: goals.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        final isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFACC15) : const Color(0xFFE5E7EB),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFACC15).withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Emoji Circle Avatar
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAFAFA),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      goal.emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Title
                                Expanded(
                                  child: Text(
                                    goal.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),

                                // Checkmark
                                if (isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(left: 12),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFFACC15),
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: selectedIndex != null ? _onContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFACC15),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: const Color(0xFF0F172A),
                          disabledForegroundColor: Colors.grey.shade500,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for goal options
class GoalOption {
  final String emoji;
  final String title;

  const GoalOption({
    required this.emoji,
    required this.title,
  });
}
