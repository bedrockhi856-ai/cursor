import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/providers.dart';

// Custom input formatter to restrict age input to 10-100 range
class AgeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty input
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-digit characters (safety check)
    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText != newValue.text) {
      return oldValue;
    }

    // Try to parse the new value
    final int? parsedValue = int.tryParse(cleanText);
    
    // If it's not a valid number, reject the input
    if (parsedValue == null) {
      return oldValue;
    }

    // Reject leading zeros for multi-digit numbers
    if (cleanText.length > 1 && cleanText.startsWith('0')) {
      return oldValue;
    }

    // For single digit input, allow any digit 1-9 (could lead to valid ages)
    if (cleanText.length == 1) {
      if (parsedValue >= 1 && parsedValue <= 9) {
        return TextEditingValue(
          text: cleanText,
          selection: TextSelection.collapsed(offset: cleanText.length),
        );
      }
      return oldValue;
    }
    
    // For 2 digits, enforce the 10-99 range
    if (cleanText.length == 2) {
      if (parsedValue >= 10 && parsedValue <= 99) {
        return TextEditingValue(
          text: cleanText,
          selection: TextSelection.collapsed(offset: cleanText.length),
        );
      }
      return oldValue;
    }
    
    // For 3 digits, only allow 100
    if (cleanText.length == 3) {
      if (parsedValue == 100) {
        return TextEditingValue(
          text: cleanText,
          selection: TextSelection.collapsed(offset: cleanText.length),
        );
      }
      return oldValue;
    }
    
    // Reject anything longer than 3 digits
    return oldValue;
  }
}

class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> with TickerProviderStateMixin {
  String age = '';
  final TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    
    // Auto-focus the age input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  bool _isValidAge() {
    if (age.isEmpty) return false;
    final ageInt = int.tryParse(age);
    if (ageInt == null) return false;
    // Since input is restricted by formatter, we only need to check if it's not empty and valid
    return ageInt >= 10 && ageInt <= 100;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 80),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                             'What is your age?',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontSize: 32,
                               fontWeight: FontWeight.w600,
                               fontFamily: 'Inter',
                               color: Colors.black,
                             ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        Center(
                          child: Container(
                            width: 120,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  AgeInputFormatter(),
                                ],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Inter',
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '00',
                                  errorText: null,
                                  helperText: null,
                                  errorStyle: TextStyle(height: 0, color: Colors.transparent),
                                  helperStyle: TextStyle(height: 0, color: Colors.transparent),
                                  hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    age = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
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
                                onPressed: _isValidAge() ? () async {
                                  _buttonController.forward().then((_) {
                                    _buttonController.reverse();
                                  });
                                  _focusNode.unfocus(); // Dismiss keyboard to prevent layout issues
                                  
                                  // Create user with age and save to storage
                                  final ageInt = int.parse(age);
                                  debugPrint('🎯 AgeScreen: Creating user with age=$ageInt');
                                  await ref.read(userProvider.notifier).createUser(age: ageInt);
                                  debugPrint('✅ AgeScreen: User created, navigating to phone usage screen');
                                  
                                  // Add delay to allow keyboard to close and layout to settle
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  if (mounted) {
                                    context.push(AppRoutes.onboardingPhoneUsage, extra: ageInt);
                                  }
                                } : null,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
