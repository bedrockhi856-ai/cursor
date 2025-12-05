import 'package:flutter/material.dart';
import 'package:study_buddy/core/constants/game_constants.dart';
import 'package:study_buddy/utils/xp_calculator.dart';
import 'package:study_buddy/utils/streak_calculator.dart';
import 'package:study_buddy/data/providers/game_provider.dart';

/// Celebration overlay for level ups, milestones, and achievements
class CelebrationOverlay extends StatefulWidget {
  /// Type of celebration
  final CelebrationType type;
  
  /// Level up result (for level up celebrations)
  final LevelUpResult? levelUpResult;
  
  /// Streak result (for streak milestone celebrations)
  final StreakUpdateResult? streakResult;
  
  /// XP earned (for session complete)
  final SessionXPResult? xpResult;
  
  /// Callback when celebration is dismissed
  final VoidCallback? onDismiss;
  
  /// Auto dismiss after duration
  final Duration autoDismissAfter;

  const CelebrationOverlay({
    super.key,
    required this.type,
    this.levelUpResult,
    this.streakResult,
    this.xpResult,
    this.onDismiss,
    this.autoDismissAfter = const Duration(seconds: 4),
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_entranceController);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));

    _entranceController.forward();
    _particleController.repeat();

    // Auto dismiss
    Future.delayed(widget.autoDismissAfter, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _entranceController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _entranceController,
          builder: (context, child) {
            return Container(
              color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
              child: Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildContent(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.type) {
      case CelebrationType.levelUp:
        return _buildLevelUpContent(context);
      case CelebrationType.streakMilestone:
        return _buildStreakMilestoneContent(context);
      case CelebrationType.sessionComplete:
        return _buildSessionCompleteContent(context);
      case CelebrationType.dailyGoal:
        return _buildDailyGoalContent(context);
      case CelebrationType.characterStageUp:
        return _buildCharacterStageUpContent(context);
    }
  }

  Widget _buildLevelUpContent(BuildContext context) {
    final result = widget.levelUpResult;
    if (result == null) return const SizedBox();

    return _CelebrationCard(
      title: 'LEVEL UP!',
      emoji: result.newEmoji,
      subtitle: 'You reached Level ${result.newLevel}',
      description: result.newTitle,
      reward: '+${result.gemsEarned} 💎',
      color: _getLevelColor(result.newLevel),
      particleController: _particleController,
    );
  }

  Widget _buildStreakMilestoneContent(BuildContext context) {
    final result = widget.streakResult;
    if (result == null) return const SizedBox();

    return _CelebrationCard(
      title: '${result.milestoneReached} DAY STREAK!',
      emoji: '🔥',
      subtitle: 'Amazing dedication!',
      description: 'Keep the fire burning!',
      reward: '+${result.gemsEarned} 💎',
      color: Colors.orange,
      particleController: _particleController,
    );
  }

  Widget _buildSessionCompleteContent(BuildContext context) {
    final result = widget.xpResult;
    if (result == null) return const SizedBox();

    return _CelebrationCard(
      title: 'SESSION COMPLETE!',
      emoji: '✨',
      subtitle: 'Great focus session!',
      description: result.multiplier > 1 
          ? '${result.multiplier}x streak bonus!' 
          : 'Keep it up!',
      reward: '+${result.totalXp} XP',
      color: Colors.green,
      particleController: _particleController,
    );
  }

  Widget _buildDailyGoalContent(BuildContext context) {
    return _CelebrationCard(
      title: 'DAILY GOAL!',
      emoji: '🎯',
      subtitle: 'You completed your daily goal!',
      description: 'Come back tomorrow!',
      reward: '+${GameConstants.gemsForDailyGoal} 💎',
      color: Colors.blue,
      particleController: _particleController,
    );
  }

  Widget _buildCharacterStageUpContent(BuildContext context) {
    final result = widget.levelUpResult;
    if (result == null) return const SizedBox();

    final stageDescriptions = [
      'Your buddy is still struggling...',
      'Signs of recovery are showing!',
      'Your buddy is healing!',
      'Your buddy is thriving!',
      'Your buddy is fully healed! 🎉',
    ];

    final description = stageDescriptions[(result.newCharacterStage - 1).clamp(0, 4)];

    return _CelebrationCard(
      title: 'CHARACTER EVOLVED!',
      emoji: result.newEmoji,
      subtitle: 'Stage ${result.newCharacterStage}',
      description: description,
      reward: '',
      color: Colors.purple,
      particleController: _particleController,
    );
  }

  Color _getLevelColor(int level) {
    const colors = [
      Color(0xFF4CAF50),
      Color(0xFF4CAF50),
      Color(0xFF8BC34A),
      Color(0xFFCDDC39),
      Color(0xFFFFC107),
      Color(0xFFFF9800),
      Color(0xFFFF5722),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
      Color(0xFF673AB7),
    ];
    return colors[(level - 1).clamp(0, colors.length - 1)];
  }
}

class _CelebrationCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String subtitle;
  final String description;
  final String reward;
  final Color color;
  final AnimationController particleController;

  const _CelebrationCard({
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.description,
    required this.reward,
    required this.color,
    required this.particleController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Particles
        ...List.generate(12, (index) {
          return AnimatedBuilder(
            animation: particleController,
            builder: (context, child) {
              final angle = (index / 12) * 2 * 3.14159;
              final radius = 100 + (particleController.value * 80);
              final x = radius * (index % 2 == 0 ? 1 : -1) * 
                  (0.5 + 0.5 * particleController.value) * 
                  (index % 3 == 0 ? 1 : 0.7);
              final y = radius * (index % 2 == 1 ? 1 : -1) * 
                  (0.3 + 0.7 * particleController.value);
              
              return Transform.translate(
                offset: Offset(
                  x * (1 - particleController.value * 0.5),
                  y * (1 - particleController.value * 0.5),
                ),
                child: Opacity(
                  opacity: 1 - particleController.value,
                  child: Text(
                    ['✨', '⭐', '🌟', '💫'][index % 4],
                    style: TextStyle(fontSize: 20 + (index % 3) * 8.0),
                  ),
                ),
              );
            },
          );
        }),
        
        // Card
        Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color, width: 3),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (reward.isNotEmpty) ...[
                const SizedBox(height: 16),
                
                // Reward
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reward,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Tap to continue
              Text(
                'Tap to continue',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Types of celebrations
enum CelebrationType {
  levelUp,
  streakMilestone,
  sessionComplete,
  dailyGoal,
  characterStageUp,
}

/// Show celebration overlay
void showCelebration(
  BuildContext context, {
  required CelebrationType type,
  LevelUpResult? levelUpResult,
  StreakUpdateResult? streakResult,
  SessionXPResult? xpResult,
  VoidCallback? onDismiss,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Celebration',
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) {
      return CelebrationOverlay(
        type: type,
        levelUpResult: levelUpResult,
        streakResult: streakResult,
        xpResult: xpResult,
        onDismiss: () {
          Navigator.of(context).pop();
          onDismiss?.call();
        },
      );
    },
  );
}

/// Show celebration from session completion result
void showSessionCelebrations(
  BuildContext context,
  SessionCompletionResult result, {
  VoidCallback? onComplete,
}) {
  final celebrations = <CelebrationType>[];
  
  // Queue celebrations in order of importance
  if (result.levelUpResult.characterStageChanged) {
    celebrations.add(CelebrationType.characterStageUp);
  }
  if (result.levelUpResult.didLevelUp) {
    celebrations.add(CelebrationType.levelUp);
  }
  if (result.streakResult.isMilestone) {
    celebrations.add(CelebrationType.streakMilestone);
  }
  if (result.dailyGoalCompleted) {
    celebrations.add(CelebrationType.dailyGoal);
  }
  
  // Always show session complete if nothing else
  if (celebrations.isEmpty) {
    celebrations.add(CelebrationType.sessionComplete);
  }

  void showNext(int index) {
    if (index >= celebrations.length) {
      onComplete?.call();
      return;
    }

    final type = celebrations[index];
    showCelebration(
      context,
      type: type,
      levelUpResult: result.levelUpResult,
      streakResult: result.streakResult,
      xpResult: result.xpResult,
      onDismiss: () => showNext(index + 1),
    );
  }

  showNext(0);
}
