import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_buddy/core/constants/game_constants.dart';
import 'package:study_buddy/data/providers/game_provider.dart';

/// Animated XP progress bar widget
/// Shows current XP progress towards next level with Duolingo-style animation
class XPBar extends ConsumerStatefulWidget {
  /// Height of the progress bar
  final double height;
  
  /// Whether to show the XP text
  final bool showXPText;
  
  /// Whether to show the level indicator
  final bool showLevel;
  
  /// Custom background color
  final Color? backgroundColor;
  
  /// Custom progress color
  final Color? progressColor;
  
  /// Border radius
  final double borderRadius;

  const XPBar({
    super.key,
    this.height = 16,
    this.showXPText = true,
    this.showLevel = true,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius = 10,
  });

  @override
  ConsumerState<XPBar> createState() => _XPBarState();
}

class _XPBarState extends ConsumerState<XPBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateToProgress(double newProgress) {
    if (newProgress != _previousProgress) {
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: newProgress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
      _previousProgress = newProgress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(gameStateProvider);
    final currentLevel = stats.currentLevel;
    final progress = stats.levelProgress;
    final totalXp = stats.totalXp;
    final xpToNext = stats.xpToNextLevel;
    final isMaxLevel = currentLevel >= GameConstants.maxLevel;

    // Animate when progress changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateToProgress(progress);
    });

    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final fgColor = widget.progressColor ?? _getProgressColor(currentLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLevel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    GameConstants.getEmojiForLevel(currentLevel),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Level $currentLevel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    stats.levelTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              if (!isMaxLevel)
                Text(
                  'Level ${currentLevel + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        
        // Progress bar
        Stack(
          children: [
            // Background
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            // Progress
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth * _progressAnimation.value;
                    return Container(
                      height: widget.height,
                      width: width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            fgColor,
                            fgColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: fgColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // Shine effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.5],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        if (widget.showXPText) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalXp XP',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
              Text(
                isMaxLevel ? 'MAX LEVEL!' : '+$xpToNext XP to level up',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getProgressColor(int level) {
    // Colors get more vibrant as level increases
    const colors = [
      Color(0xFF4CAF50), // Green - Level 1-2
      Color(0xFF8BC34A), // Light Green - Level 3
      Color(0xFFCDDC39), // Lime - Level 4
      Color(0xFFFFEB3B), // Yellow - Level 5
      Color(0xFFFFC107), // Amber - Level 6
      Color(0xFFFF9800), // Orange - Level 7
      Color(0xFFFF5722), // Deep Orange - Level 8
      Color(0xFFE91E63), // Pink - Level 9
      Color(0xFF9C27B0), // Purple - Level 10
    ];
    final index = (level - 1).clamp(0, colors.length - 1);
    return colors[index];
  }
}

/// Compact XP bar for use in headers
class CompactXPBar extends ConsumerWidget {
  final double height;
  final double width;

  const CompactXPBar({
    super.key,
    this.height = 8,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(levelProgressProvider);
    final level = ref.watch(currentLevelProvider);

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: _getLevelColor(level),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Lv.$level',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    const colors = [
      Color(0xFF4CAF50),
      Color(0xFF8BC34A),
      Color(0xFFCDDC39),
      Color(0xFFFFEB3B),
      Color(0xFFFFC107),
      Color(0xFFFF9800),
      Color(0xFFFF5722),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
    ];
    return colors[(level - 1).clamp(0, colors.length - 1)];
  }
}
