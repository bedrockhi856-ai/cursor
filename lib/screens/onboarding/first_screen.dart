import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/providers.dart';
import '../../widgets/buttons/hold_to_begin_button.dart';

class FirstScreen extends ConsumerStatefulWidget {
  const FirstScreen({super.key});

  @override
  ConsumerState<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends ConsumerState<FirstScreen> with TickerProviderStateMixin {
  bool isSwitchOn = false;
  late AnimationController _headingController;
  late AnimationController _switchController;
  late AnimationController _backgroundController;
  late AnimationController _holdController;
  late AnimationController _rippleController;
  
  late Animation<double> _headingAnimation;
  late Animation<double> _switchAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _holdAnimation;
  late Animation<double> _rippleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _headingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _switchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _holdController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _headingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headingController,
      curve: Curves.easeOut,
    ));
    
    _switchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _holdAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _holdController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.linear,
    ));
    
    _headingController.forward();
    _holdController.repeat(reverse: true);
    _rippleController.repeat();
  }
  
  @override
  void dispose() {
    _headingController.dispose();
    _switchController.dispose();
    _backgroundController.dispose();
    _holdController.dispose();
    _rippleController.dispose();
    super.dispose();
  }
  
  void onHoldComplete() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      if (mounted) {
        context.push(AppRoutes.onboardingSecond);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final int regainYears = user?.regainableYears.round() ?? 3;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _headingAnimation,
          _switchAnimation,
          _backgroundAnimation,
          _holdAnimation,
          _rippleAnimation,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/background/darkphone.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity((0.4 + (0.1 * _backgroundAnimation.value)).clamp(0.0, 1.0)),
                  BlendMode.darken,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Heading at top - fixed position
                    Positioned(
                      top: 60,
                      left: 24,
                      right: 24,
                      child: AnimatedOpacity(
                        opacity: _headingAnimation.value,
                        duration: const Duration(milliseconds: 600),
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _headingAnimation.value)),
                          child: Text(
                            'Want to regain $regainYears years\nof your life?',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Freedom Switch box in middle - fixed position
                    Positioned(
                      top: (screenHeight - safeAreaTop - safeAreaBottom) * 0.4 + 45,
                      left: 24,
                      right: 24,
                      child: IgnorePointer(
                        ignoring: false,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  isSwitchOn ? Icons.lock_open : Icons.lock,
                                  key: ValueKey(isSwitchOn),
                                  size: 28,
                                  color: isSwitchOn ? Colors.green[600] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Freedom Switch',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    Text(
                                      'Turn ON to unlock your potential',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey[600]!.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(left: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Ripple 1 - around hold button
                    Positioned(
                      bottom: 55 + 60 - 80,
                      left: (MediaQuery.of(context).size.width - 120) / 2 + 60 - 80,
                      child: _buildRipple(0.0, 160),
                    ),
                    
                    // Ripple 2 - around hold button
                    Positioned(
                      bottom: 55 + 60 - 100,
                      left: (MediaQuery.of(context).size.width - 120) / 2 + 60 - 100,
                      child: _buildRipple(0.33, 200),
                    ),
                    
                    // Ripple 3 - around hold button
                    Positioned(
                      bottom: 55 + 60 - 120,
                      left: (MediaQuery.of(context).size.width - 120) / 2 + 60 - 120,
                      child: _buildRipple(0.66, 240),
                    ),
                    
                    // Hold button at bottom - fixed position
                    Positioned(
                      bottom: 55,
                      left: (MediaQuery.of(context).size.width - 120) / 2,
                      child: HoldToBeginButton(
                        onHoldComplete: onHoldComplete,
                        text: 'hold',
                        buttonColor: const Color(0xFFFF6B35),
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRipple(double delay, double size) {
    // Calculate the ripple animation value based on delay
    double rippleValue = (_rippleAnimation.value + delay) % 1.0;
    double scale = 0.7 + (rippleValue * 0.3);
    double opacity = 0.4 * (1.0 - rippleValue);
    
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFF6B35).withOpacity(opacity),
            width: 2.5,
          ),
        ),
      ),
    );
  }
}
