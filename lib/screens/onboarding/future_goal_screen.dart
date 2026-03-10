import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/user_provider.dart';

/// Onboarding Screen 4 - Future Goal
class FutureGoalScreen extends ConsumerStatefulWidget {
  const FutureGoalScreen({super.key});

  @override
  ConsumerState<FutureGoalScreen> createState() => _FutureGoalScreenState();
}

class _FutureGoalScreenState extends ConsumerState<FutureGoalScreen> {
  int? selectedTargetIndex;

  final List<StudyOption> ultimateTargets = const [
    StudyOption(
      emoji: '🌱',
      title: 'Foundation (30–60 mins/day)',
      subtitle: 'Perfect for staying on top of daily homework and building a streak.',
    ),
    StudyOption(
      emoji: '⚖️',
      title: 'Balanced (1.5–2.5 hours/day)',
      subtitle: 'Great for consistent progress across multiple subjects and midterms.',
    ),
    StudyOption(
      emoji: '🚀',
      title: 'High-Achiever (3–4 hours/day)',
      subtitle: 'Ideal for competitive exams, certifications, or intensive degree paths.',
    ),
    StudyOption(
      emoji: '🔥',
      title: 'Deep Immersion (5+ hours/day)',
      subtitle: 'Designed for high-stakes study marathons like finals or a thesis.',
    ),
    StudyOption(
      emoji: '📈',
      title: 'The Growth Path (Custom Target)',
      subtitle: 'I have a high goal, but I want to start small (20 mins) and build up over 6 months.',
    ),
  ];

  void _onTargetSelected(int index) {
    setState(() {
      selectedTargetIndex = index;
    });
  }

  Future<void> _onContinue() async {
    if (selectedTargetIndex == null) return;
    // Map selection to ultimate goal minutes
    // Foundation=60, Balanced=120, High-Achiever=210, Deep Immersion=300, Growth Path=90
    const goalMap = [60, 120, 210, 300, 90];
    final minutes = goalMap[selectedTargetIndex!];
    await ref.read(userProvider.notifier).updateUltimateGoal(minutes);
    if (!mounted) return;
    context.go(AppRoutes.onboardingGrowthPace);
  }

  void _onBack() {
    context.go(AppRoutes.onboardingCommitment);
  }

  @override
  Widget build(BuildContext context) {
    const primaryYellow = Color(0xFFFACC15);
    const slate900 = Color(0xFF0F172A);
    const borderColor = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Progress Bar
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(primaryYellow),
            ),
          ),

          // Content
          Expanded(
            child: SafeArea(
              child: Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _onBack,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: slate900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Set a future goal',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: slate900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options List
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: ultimateTargets.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildOptionCard(
                          option: ultimateTargets[index],
                          isSelected: selectedTargetIndex == index,
                          onTap: () => _onTargetSelected(index),
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
                        onPressed: selectedTargetIndex != null ? _onContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryYellow,
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: slate900,
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

  Widget _buildOptionCard({
    required StudyOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const primaryYellow = Color(0xFFFACC15);
    const borderColor = Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryYellow : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryYellow.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Emoji Circle Avatar
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  option.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: const Icon(
                  Icons.check_circle,
                  color: primaryYellow,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Data model for study options
class StudyOption {
  final String emoji;
  final String title;
  final String subtitle;

  const StudyOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}
