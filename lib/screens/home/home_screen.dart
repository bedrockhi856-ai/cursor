import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/providers.dart';
import '../../data/providers/game_provider.dart';
import '../../widgets/common/xp_bar.dart';
import '../../widgets/common/streak_counter.dart';
import '../../widgets/common/gem_counter.dart';
import '../../widgets/common/level_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// Pre-computed colors to avoid .withOpacity() allocations
const _kShadowColor10 = Color(0x1A000000); // 10% black
const _kShadowColor08 = Color(0x14000000); // 8% black
const _kShadowColor06 = Color(0x0F000000); // 6% black
const _kGoldGlow30 = Color(0x4DFFD700); // 30% gold
const _kBubbleColor = Color(0xFF1E3A8A);
const _kProfileBgColor = Color(0xFFE3F2FD);
const _kProfileIconColor = Color(0xFF1976D2);

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _greetingController;
  late AnimationController _progressController;
  late AnimationController _speechController;
  late AnimationController _typingController;
  late AnimationController _focusButtonController;
  late AnimationController _pulseController;
  late AnimationController _longPressController;
  
  bool _animationsStarted = false;
  
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
    
    // Start animations after first frame to avoid jank
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _animationsStarted) return;
      _animationsStarted = true;
      
      _greetingController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _progressController.forward();
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _speechController.forward();
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _typingController.forward();
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
    // Level comes from gameStateProvider via widgets
    final streak = progress?.currentStreak ?? 0;
    final totalMinutes = ref.watch(todayFocusMinutesProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with hamburger menu, app name, and gamification stats
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
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
                    // Gamification stats row
                    Consumer(
                      builder: (context, ref, child) {
                        try {
                          // Check if provider is accessible
                          ref.watch(gameStateProvider);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const MiniStreakBadge(),
                              const SizedBox(width: 8),
                              const MiniGemBadge(),
                              const SizedBox(width: 8),
                              const CompactLevelBadge(size: 28),
                            ],
                          );
                        } catch (e) {
                          debugPrint('Gamification widgets error: $e');
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              // XP Progress bar
              Consumer(
                builder: (context, ref, child) {
                  try {
                    ref.watch(gameStateProvider);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: const XPBar(
                        height: 12,
                        showXPText: true,
                        showLevel: false,
                      ),
                    );
                  } catch (e) {
                    debugPrint('XP bar error: $e');
                    return const SizedBox(height: 24);
                  }
                },
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
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _kProfileBgColor,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 32,
                              color: _kProfileIconColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Chat bubble with typing indicator
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _kBubbleColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: _kShadowColor10,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Buddy',
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
                                      _getMotivationalMessage(userName, streak),
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
                child: _buildFocusButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusButton() {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: _onFocusButtonTap,
        onLongPressStart: _onFocusButtonLongPressStart,
        onLongPressEnd: _onFocusButtonLongPressEnd,
        onLongPress: _onFocusButtonLongPressComplete,
        child: ScaleTransition(
          scale: _focusButtonAnimation,
          child: Stack(
            children: [
              // Pulsing glow effect
              FadeTransition(
                opacity: _pulseAnimation,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _kGoldGlow30,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Main button with long press fill effect
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: _kGoldGlow30,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              child: Stack(
                children: [
                  // Fill effect from left to right
                  if (_isLongPressing)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _longPressAnimation,
                        builder: (context, _) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _longPressAnimation.value,
                              heightFactor: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB800),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  // Button text
                  const Center(
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
            color: const Color(0xFFEEEEEE),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: _kShadowColor08,
              blurRadius: 8,
              offset: Offset(0, 2),
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
    // Navigate to stats screen to see detailed streak info
    context.go(AppRoutes.stats);
  }

  void _onProductiveCardTap() {
    // Navigate to stats screen to see detailed time info
    context.go(AppRoutes.stats);
  }

  /// Get a motivational message based on user's name and streak
  String _getMotivationalMessage(String name, int streak) {
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
}
