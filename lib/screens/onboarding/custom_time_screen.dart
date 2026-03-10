import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/user_provider.dart';

/// Custom Time Selection Screen - iOS-style time wheel picker
class CustomTimeScreen extends ConsumerStatefulWidget {
  const CustomTimeScreen({super.key});

  @override
  ConsumerState<CustomTimeScreen> createState() => _CustomTimeScreenState();
}

class _CustomTimeScreenState extends ConsumerState<CustomTimeScreen> {
  int selectedMinutes = 20; // Default starting time
  bool _isSubmitting = false;
  bool _showSuccess = false;

  // Available time options (1 to 120 minutes)
  final List<int> timeOptions = List.generate(120, (i) => i + 1);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onCreatePlan() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    await ref.read(userProvider.notifier).updateStartingCommitment(selectedMinutes);

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      _showSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    context.go(AppRoutes.onboardingTarget);
  }

  void _onBack() {
    context.go(AppRoutes.onboardingCommitment);
  }

  @override
  Widget build(BuildContext context) {
    const primaryYellow = Color(0xFFFACC15);
    const slate900 = Color(0xFF0F172A);
    const slate500 = Color(0xFF64748B);
    const borderColor = Color(0xFFE5E7EB);

    // Find the index of current selectedMinutes in timeOptions
    int initialIndex = timeOptions.indexOf(selectedMinutes);
    if (initialIndex < 0) initialIndex = 19; // Default to 20 mins

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

                  const SizedBox(height: 40),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: const [
                        Text(
                          'Set Your Daily Goal',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: slate900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Choose a starting time that feels comfortable. You can always adjust it later.',
                          style: TextStyle(
                            fontSize: 18,
                            color: slate500,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Time Wheel Container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // iOS-style Time Wheel
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              // Selection highlight
                              Center(
                                child: Container(
                                  height: 60,
                                  margin: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryYellow.withOpacity(0.2),
                                        primaryYellow.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: primaryYellow,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              // The Picker
                              CupertinoPicker(
                                scrollController: FixedExtentScrollController(
                                  initialItem: initialIndex,
                                ),
                                itemExtent: 60,
                                diameterRatio: 1.1,
                                squeeze: 1.0,
                                magnification: 1.15,
                                useMagnifier: true,
                                selectionOverlay: const SizedBox.shrink(),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedMinutes = timeOptions[index];
                                  });
                                },
                                children: timeOptions.map((minutes) {
                                  final isSelected = minutes == selectedMinutes;
                                  return Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 150),
                                          style: TextStyle(
                                            fontSize: isSelected ? 24 : 18,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            color: isSelected ? slate900 : slate500.withOpacity(0.6),
                                          ),
                                          child: Text('$minutes'),
                                        ),
                                        const SizedBox(width: 6),
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 150),
                                          style: TextStyle(
                                            fontSize: isSelected ? 16 : 14,
                                            fontWeight: FontWeight.w400,
                                            color: isSelected ? slate500 : slate500.withOpacity(0.4),
                                          ),
                                          child: const Text('min'),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Selected time display badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryYellow.withOpacity(0.15),
                                primaryYellow.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '✨',
                                style: TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$selectedMinutes minutes / day',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: slate900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: !_isSubmitting ? _onCreatePlan : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showSuccess
                              ? const Color(0xFF10B981)
                              : primaryYellow,
                          foregroundColor: _showSuccess ? Colors.white : slate900,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
