import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/user_provider.dart';

/// Onboarding Screen 3 - Start Time
class StartTimeScreen extends ConsumerStatefulWidget {
  const StartTimeScreen({super.key});

  @override
  ConsumerState<StartTimeScreen> createState() => _StartTimeScreenState();
}

class _StartTimeScreenState extends ConsumerState<StartTimeScreen>
    with SingleTickerProviderStateMixin {
  int? selectedIndex;
  bool _isSubmitting = false;
  bool _showSuccess = false;

  final List<CommitmentOption> commitmentOptions = const [
    CommitmentOption(
      emoji: '🌱',
      title: '15 Minutes / Day',
      subtitle: 'Perfect for building the initial habit without burnout.',
    ),
    CommitmentOption(
      emoji: '🚀',
      title: '30 Minutes / Day',
      subtitle: 'The "Sweet Spot" for steady academic growth.',
    ),
    CommitmentOption(
      emoji: '⚡',
      title: '60 Minutes / Day',
      subtitle: 'For students ready to see rapid results and high intensity.',
    ),
    CommitmentOption(
      emoji: '📈',
      title: 'The Custom Path',
      subtitle: 'Set your own starting time and let your Buddy guide you to your 6-month target.',
    ),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _onOptionSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> _onCreatePlan() async {
    if (selectedIndex == null || _isSubmitting) return;

    // If Custom Path selected, navigate to custom time screen
    if (selectedIndex == 3) {
      context.go(AppRoutes.onboardingCustomTime);
      return;
    }

    setState(() { _isSubmitting = true; });

    // Map selection to minutes and save
    const minuteMap = [15, 30, 60];
    final minutes = minuteMap[selectedIndex!];
    await ref.read(userProvider.notifier).updateStartingCommitment(minutes);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() { _showSuccess = true; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    context.go(AppRoutes.onboardingTarget);
  }

  void _onBack() {
    context.go(AppRoutes.onboardingPsychology);
  }

  @override
  Widget build(BuildContext context) {
    const primaryYellow = Color(0xFFFACC15);
    const slate900 = Color(0xFF0F172A);
    const slate500 = Color(0xFF64748B);
    const borderColor = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Progress Bar - Full (1.0)
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(primaryYellow),
            ),
          ),

          // Content
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Header with back button
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
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

                      const SizedBox(height: 32),

                      // Main Headline
                      const Text(
                        "Let's start small",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: slate900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      const Text(
                        'Pick a daily study goal that feels easy to maintain. You can always increase it later.',
                        style: TextStyle(
                          fontSize: 18,
                          color: slate500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Commitment Cards
                      ...List.generate(commitmentOptions.length, (index) {
                        final option = commitmentOptions[index];
                        final isSelected = selectedIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCommitmentCard(
                            option: option,
                            isSelected: isSelected,
                            onTap: () => _onOptionSelected(index),
                          ),
                        );
                      }),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: selectedIndex != null && !_isSubmitting
                      ? _onCreatePlan
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showSuccess
                        ? const Color(0xFF10B981)
                        : primaryYellow,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: _showSuccess ? Colors.white : slate900,
                    disabledForegroundColor: Colors.grey.shade500,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _showSuccess
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('check'),
                            size: 28,
                            color: Colors.white,
                          )
                        : _isSubmitting
                            ? const SizedBox(
                                key: ValueKey('loading'),
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      slate900),
                                ),
                              )
                            : const Text(
                                'Create My Plan',
                                key: ValueKey('text'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitmentCard({
    required CommitmentOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const primaryYellow = Color(0xFFFACC15);
    const borderColor = Color(0xFFE5E7EB);
    const slate900 = Color(0xFF0F172A);
    const slate500 = Color(0xFF64748B);

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
                    color: primaryYellow.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Emoji Circle
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  option.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: slate500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(left: 12),
                child: const Icon(
                  Icons.check_circle,
                  color: primaryYellow,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Data model for commitment options
class CommitmentOption {
  final String emoji;
  final String title;
  final String subtitle;

  const CommitmentOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}
