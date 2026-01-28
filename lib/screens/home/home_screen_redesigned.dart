import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_system.dart';
import '../../core/components/ds_components.dart';
import '../../data/providers/providers.dart';
import '../../data/providers/game_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// HOME SCREEN - REDESIGNED WITH INVISIBLE DESIGN METHODOLOGY
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Follows the Tim Gabe principles:
/// - 8-point grid for all spacing
/// - Typography physics (line heights, letter spacing)
/// - 3-color rule (60% base, 30% neutral, 10% accent)
/// - Spring animations for natural feel
/// - Clear visual hierarchy
/// ═══════════════════════════════════════════════════════════════════════════

class HomeScreenRedesigned extends ConsumerStatefulWidget {
  const HomeScreenRedesigned({super.key});

  @override
  ConsumerState<HomeScreenRedesigned> createState() => _HomeScreenRedesignedState();
}

class _HomeScreenRedesignedState extends ConsumerState<HomeScreenRedesigned>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  
  // Animations
  late Animation<double> _greetingFade;
  late Animation<Offset> _greetingSlide;
  late Animation<double> _bubbleFade;
  late Animation<Offset> _bubbleSlide;
  late Animation<double> _statsFade;
  late Animation<double> _buttonFade;
  late Animation<double> _pulseAnimation;
  
  bool _isTyping = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startEntranceSequence();
  }
  
  void _setupAnimations() {
    // Entrance sequence controller
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Pulse controller for CTA button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Staggered entrance animations
    _greetingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    _greetingSlide = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    
    _bubbleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _bubbleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    
    _statsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  void _startEntranceSequence() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
      
      // Stop typing indicator after delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _isTyping = false);
      });
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final progress = ref.watch(progressProvider);
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Friend';
    final streak = progress?.currentStreak ?? 0;
    final todayMinutes = ref.watch(todayFocusMinutesProvider);
    
    return Scaffold(
      backgroundColor: DSColors.background,
      body: SafeArea(
        child: Padding(
          padding: DS.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════════════════════════════
              // HEADER ROW
              // ═══════════════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.only(top: DS.space16, bottom: DS.space16),
                child: Row(
                  children: [
                    // Menu icon
                    GestureDetector(
                      onTap: () => HapticFeedback.selectionClick(),
                      child: Icon(
                        Icons.menu_rounded,
                        size: DSComponents.iconSize,
                        color: DSColors.textPrimary,
                      ),
                    ),
                    DS.h16,
                    // App name
                    Text(
                      'StudyBuddy',
                      style: DSTypography.headingMedium,
                    ),
                    const Spacer(),
                    // Gamification stats
                    _buildHeaderStats(streak),
                  ],
                ),
              ),
              
              // ═══════════════════════════════════════════════════════════════
              // XP PROGRESS BAR
              // ═══════════════════════════════════════════════════════════════
              Consumer(
                builder: (context, ref, _) {
                  try {
                    final gameState = ref.watch(gameStateProvider);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: DS.space24),
                      child: _buildXPBar(gameState.levelProgress),
                    );
                  } catch (e) {
                    return DS.v24;
                  }
                },
              ),
              
              // ═══════════════════════════════════════════════════════════════
              // MAIN GREETING (Primary hierarchy)
              // ═══════════════════════════════════════════════════════════════
              SlideTransition(
                position: _greetingSlide,
                child: FadeTransition(
                  opacity: _greetingFade,
                  child: Text(
                    'Ready to grow,\n$userName?',
                    style: DSTypography.displayMedium,
                  ),
                ),
              ),
              
              DS.v48,
              
              // ═══════════════════════════════════════════════════════════════
              // BUDDY CHAT BUBBLE
              // ═══════════════════════════════════════════════════════════════
              SlideTransition(
                position: _bubbleSlide,
                child: FadeTransition(
                  opacity: _bubbleFade,
                  child: DSChatBubble(
                    title: 'Your Buddy',
                    message: _getMotivationalMessage(userName, streak),
                    isTyping: _isTyping,
                  ),
                ),
              ),
              
              DS.v48,
              
              // ═══════════════════════════════════════════════════════════════
              // STATS CARDS
              // ═══════════════════════════════════════════════════════════════
              FadeTransition(
                opacity: _statsFade,
                child: Row(
                  children: [
                    Expanded(
                      child: DSStatCard(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: DSColors.streak,
                        value: '$streak',
                        label: streak == 1 ? 'day streak' : 'day streak',
                        onTap: () => context.go(AppRoutes.stats),
                      ),
                    ),
                    DS.h16,
                    Expanded(
                      child: DSStatCard(
                        icon: Icons.schedule_rounded,
                        iconColor: DSColors.xp,
                        value: '$todayMinutes',
                        label: 'min today',
                        onTap: () => context.go(AppRoutes.stats),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // ═══════════════════════════════════════════════════════════════
              // FOCUS CTA BUTTON (10% Accent rule)
              // ═══════════════════════════════════════════════════════════════
              FadeTransition(
                opacity: _buttonFade,
                child: Column(
                  children: [
                    // Main CTA with pulse
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: DSButton(
                        label: 'Start Focus',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.push(AppRoutes.timerSetup);
                        },
                      ),
                    ),
                    
                    // 2-Minute Mode link (Atomic Habits: 2-Minute Rule)
                    DSMicroCTA(
                      label: 'Just 2 minutes',
                      icon: Icons.flash_on_rounded,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        // TODO: Start instant 2-min session
                        context.push(AppRoutes.timerSetup);
                      },
                    ),
                  ],
                ),
              ),
              
              DS.v24,
            ],
          ),
        ),
      ),
    );
  }
  
  // ─────────────────────────────────────────────────────────────────────────
  // HELPER WIDGETS
  // ─────────────────────────────────────────────────────────────────────────
  
  Widget _buildHeaderStats(int streak) {
    return Consumer(
      builder: (context, ref, _) {
        try {
          final gameState = ref.watch(gameStateProvider);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Streak flame
              _buildMiniStat(
                icon: Icons.local_fire_department_rounded,
                value: '$streak',
                color: DSColors.streak,
              ),
              DS.h8,
              // Gems
              _buildMiniStat(
                icon: Icons.diamond_rounded,
                value: '${gameState.totalGems}',
                color: DSColors.gems,
              ),
              DS.h8,
              // Level badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DSColors.xp,
                      DSColors.xp.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${gameState.currentLevel}',
                    style: DSTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        } catch (e) {
          return const SizedBox.shrink();
        }
      },
    );
  }
  
  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        DS.h4,
        Text(
          value,
          style: DSTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildXPBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: DSColors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: progress),
              builder: (context, value, child) {
                return FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DSColors.xp,
                          DSColors.xp.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  String _getMotivationalMessage(String name, int streak) {
    if (streak == 0) {
      return "Hey $name! Ready to start your focus journey today? 🌱";
    } else if (streak == 1) {
      return "Great start $name! You showed up yesterday. Let's keep it going! 💪";
    } else if (streak < 7) {
      return "Awesome $name! $streak days strong. You're building momentum! 🔥";
    } else if (streak < 30) {
      return "Incredible $name! $streak day streak! You're becoming unstoppable! ⚡";
    } else {
      return "Legend status $name! $streak days of pure focus. Amazing! 👑";
    }
  }
}
