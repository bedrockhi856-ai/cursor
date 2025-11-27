import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/providers.dart';

class PhoneUsageScreen extends ConsumerStatefulWidget {
  final int age;
  const PhoneUsageScreen({Key? key, required this.age}) : super(key: key);

  @override
  ConsumerState<PhoneUsageScreen> createState() => _PhoneUsageScreenState();
}

class _PhoneUsageScreenState extends ConsumerState<PhoneUsageScreen> with TickerProviderStateMixin {
  final ValueNotifier<int> _selectedNotifier = ValueNotifier<int>(1);
  final List<String> options = [
    '1–2 Hours',
    '2–3 Hours',
    '3–4 Hours',
    '4–5 Hours',
  ];
  
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _selectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 80),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'How much time do you spend on your phone?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 150),
                      // Options section
                      ValueListenableBuilder<int>(
                        valueListenable: _selectedNotifier,
                        builder: (context, selected, _) {
                          return Column(
                            children: List.generate(options.length, (i) => _buildOption(i, selected)),
                          );
                        },
                      ),
                    ],
                  ),
                  // Next button at the bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, left: 24.0, right: 24.0),
                    child: AnimatedBuilder(
                      animation: _buttonAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _buttonAnimation.value,
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD12A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 6,
                                shadowColor: Colors.black.withValues(alpha: 0.2),
                              ),
                              onPressed: () async {
                                await _buttonController.forward();
                                await _buttonController.reverse();
                                
                                // Convert usage index to hours (1-2 -> 2, 2-3 -> 3, etc.)
                                final phoneUsageHours = _selectedNotifier.value + 2;
                                
                                // Save phone usage to storage
                                await ref.read(userProvider.notifier).updatePhoneUsage(phoneUsageHours);
                                
                                if (mounted) {
                                  await Future.delayed(const Duration(milliseconds: 100));
                                  if (mounted) {
                                    context.push(
                                      AppRoutes.onboardingResult,
                                      extra: {
                                        'age': widget.age,
                                        'phoneUsage': phoneUsageHours,
                                      },
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int i, int selected) {
    final bool isSelected = selected == i;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
      child: GestureDetector(
        onTap: () {
          _selectedNotifier.value = i;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF8E1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFD12A) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFFFFD12A).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              scale: isSelected ? 1.05 : 1.0,
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
