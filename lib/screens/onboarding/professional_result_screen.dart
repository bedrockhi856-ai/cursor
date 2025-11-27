import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class ProfessionalResultScreen extends StatefulWidget {
  final int age;
  final int phoneUsageHours;
  const ProfessionalResultScreen({
    Key? key, 
    required this.age, 
    required this.phoneUsageHours,
  }) : super(key: key);

  @override
  State<ProfessionalResultScreen> createState() => _ProfessionalResultScreenState();
}

class _ProfessionalResultScreenState extends State<ProfessionalResultScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _headingController;
  late AnimationController _cardController;
  late AnimationController _subtextController;
  late AnimationController _floatingController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _headingAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _subtextAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Button animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Heading fade in animation
    _headingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Card pop-in animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Subtext fade in animation
    _subtextController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Floating animation for illustration
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: 8.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _headingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headingController,
      curve: Curves.easeOut,
    ));
    
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));
    
    _subtextAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _subtextController,
      curve: Curves.easeOut,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _headingController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _subtextController.forward();
    });
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headingController.dispose();
    _cardController.dispose();
    _subtextController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int years = 75 - widget.age;
    double totalUnproductiveYears = (widget.phoneUsageHours * 365 * years) / 24 / 365;
    String resultStr = totalUnproductiveYears.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Main heading - fade in from top
          Positioned(
            top: 96,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _headingAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _headingAnimation.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _headingAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'This is how much time\nyou might lose',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: Color(0xFF1F2937), // Dark navy
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main illustration - floating animation
          Positioned(
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 240 + (8 * _floatingAnimation.value)),
                  child: child,
                );
              },
              child: Center(
                child: SizedBox(
                  width: 320,
                  height: 300,
                  child: Image.asset(
                    'assets/illustrations/sad2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
      
          // White rounded card with years - pop-in animation
          Positioned(
            top: 584,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _cardAnimation.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * _cardAnimation.value),
                    child: child,
                  ),
                );
              },
              child: Center(
                child: Container(
                  width: 260,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$resultStr years',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                        color: Color(0xFFFF7A00),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      
          // Subtext - fade in with delay
          Positioned(
            top: 696,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _subtextAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _subtextAnimation.value.clamp(0.0, 1.0),
                  child: child,
                );
              },
              child: const Center(
                child: Text(
                  'Spent Unproductively',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: Color(0xFF1E1E1E),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
      


          // Yellow button matching previous screens
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
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
                        await _animationController.forward();
                        await _animationController.reverse();
                        await Future.delayed(const Duration(milliseconds: 100));
                        if (mounted) {
                          if (mounted) {
                            context.push(AppRoutes.onboardingFirst);
                          }
                        }
                      },
                      child: const Text(
                        'I want to change',
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
    );
  }
}
