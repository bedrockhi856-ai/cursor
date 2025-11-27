import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _greetingController;
  late AnimationController _progressController;
  late AnimationController _speechController;
  late AnimationController _typingController;
  late AnimationController _focusButtonController;
  late AnimationController _pulseController;
  late AnimationController _longPressController;
  
  // Animations
  late Animation<double> _greetingAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _speechAnimation;
  late Animation<double> _typingAnimation;
  late Animation<double> _focusButtonAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _longPressAnimation;
  
  // State variables
  bool _isTyping = true;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    
    // Greeting text animation controller
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // XP progress bar animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Speech bubble animation controller
    _speechController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Typing indicator animation controller
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    
    // Focus button animation controller
    _focusButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Long press animation controller
    _longPressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Greeting text fade in from left
    _greetingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _greetingController,
        curve: Curves.easeOut,
      ),
    );
    
    // XP progress bar fill animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOut,
      ),
    );
    
    // Speech bubble slide up and fade in
    _speechAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _speechController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Typing indicator animation
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _typingController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Focus button scale animation
    _focusButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _focusButtonController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Pulse animation for focus button
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Long press fill animation
    _longPressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _longPressController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animations
    _greetingController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _speechController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _typingController.forward();
    });
    
    // Start pulse animation for focus button
    _pulseController.repeat(reverse: true);
    
    // Stop typing indicator after 0.7s and show message
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        _typingController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _progressController.dispose();
    _speechController.dispose();
    _typingController.dispose();
    _focusButtonController.dispose();
    _pulseController.dispose();
    _longPressController.dispose();
    super.dispose();
  }

  void _onFocusButtonTap() async {
    await _focusButtonController.forward();
    _focusButtonController.reverse();
    if (mounted) {
      context.push(AppRoutes.timerSetup);
    }
  }

  void _onFocusButtonLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPressing = true;
    });
    _longPressController.forward();
  }

  void _onFocusButtonLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isLongPressing = false;
    });
    _longPressController.reverse();
  }

  void _onFocusButtonLongPressComplete() {
    _onFocusButtonTap();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final progress = ref.watch(progressProvider);
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Friend';
    final currentLevel = progress?.currentLevel ?? 1;
    final streak = progress?.currentStreak ?? 0;
    final totalMinutes = progress?.totalFocusMinutes ?? 0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with hamburger menu, app name, and progress bar
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu,
                      size: 24,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'StudyBuddy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const Spacer(),
                    // Progress bar with animation
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Level $currentLevel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 1),
                            // XP Progress Bar with lightning icon
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 120,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: ((totalMinutes % 60) / 60) * _progressAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFF6B35),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.flash_on,
                                  size: 16,
                                  color: Color(0xFFFFD700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${totalMinutes % 60}/60 XP',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Main greeting text with fade in from left
              AnimatedBuilder(
                animation: _greetingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-30 * (1 - _greetingAnimation.value), 0),
                    child: Opacity(
                      opacity: _greetingAnimation.value.clamp(0.0, 1.0),
                      child: Text(
                        'Ready to grow again, $userName?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Inter',
                          height: 1.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // Profile picture and chat bubble with typing indicator
              AnimatedBuilder(
                animation: _speechAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _speechAnimation.value)),
                    child: Opacity(
                      opacity: _speechAnimation.value.clamp(0.0, 1.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile picture
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE3F2FD),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Chat bubble with typing indicator
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFF1E3A8A),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'David',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (_isTyping)
                                    _buildTypingIndicator()
                                  else
                                    Text(
                                      'My son said you look big papa, thanks to you mohiddin !!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                        height: 1.3,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // Stats cards with tap animations
              Row(
                children: [
                  // Streak card with flame animation
                  Expanded(
                    child: _buildStatsCard(
                      icon: Icons.local_fire_department,
                      iconColor: Color(0xFFFF6B35),
                      value: '$streak days',
                      label: 'streak',
                      onTap: _onStreakCardTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Productive time card with clock animation
                  Expanded(
                    child: _buildStatsCard(
                      icon: Icons.access_time,
                      iconColor: Color(0xFF2196F3),
                      value: '$totalMinutes min',
                      label: 'productive',
                      onTap: _onProductiveCardTap,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Focus button with pulsing glow and long press effect
              Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 24.0),
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _focusButtonAnimation,
                    _pulseAnimation,
                    _longPressAnimation,
                  ]),
                  builder: (context, child) {
                    final scale = _focusButtonAnimation.value;
                    final pulseOpacity = _pulseAnimation.value;
                    final fillProgress = _longPressAnimation.value;
                    
                    return GestureDetector(
                      onTap: _onFocusButtonTap,
                      onLongPressStart: _onFocusButtonLongPressStart,
                      onLongPressEnd: _onFocusButtonLongPressEnd,
                      onLongPress: _onFocusButtonLongPressComplete,
                      child: Transform.scale(
                        scale: scale,
                        child: Stack(
                          children: [
                            // Pulsing glow effect
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFD700).withOpacity(pulseOpacity * 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Main button with long press fill effect
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFFFD700).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Fill effect from left to right
                                  if (_isLongPressing)
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: FractionallySizedBox(
                                        widthFactor: fillProgress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFFB800),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Button text
                                  Center(
                                    child: Text(
                                      'Focus',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        for (int i = 0; i < 3; i++)
          AnimatedBuilder(
            animation: _typingAnimation,
            builder: (context, child) {
              final delay = i * 0.2;
              final opacity = (_typingAnimation.value - delay).clamp(0.0, 1.0);
              return Container(
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStreakCardTap() {
    // Flame icon grows and flickers
    // This will be handled by the animation system
  }

  void _onProductiveCardTap() {
    // Clock icon ticks forward twice
    // This will be handled by the animation system
  }
}
