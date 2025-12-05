import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_buddy/core/constants/game_constants.dart';
import 'package:study_buddy/data/providers/game_provider.dart';

/// Level badge widget showing current level with emoji
class LevelBadge extends ConsumerWidget {
  /// Size of the badge
  final double size;
  
  /// Whether to show the level title
  final bool showTitle;
  
  /// Whether to animate level up
  final bool animateLevelUp;

  const LevelBadge({
    super.key,
    this.size = 60,
    this.showTitle = true,
    this.animateLevelUp = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gameStateProvider);
    final level = stats.currentLevel;
    final title = stats.levelTitle;
    final emoji = stats.levelEmoji;
    final characterStage = stats.characterStage;

    final theme = Theme.of(context);
    final color = _getLevelColor(level);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LevelBadgeCircle(
          size: size,
          level: level,
          emoji: emoji,
          color: color,
        ),
        if (showTitle) ...[
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'Stage $characterStage',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }

  Color _getLevelColor(int level) {
    const colors = [
      Color(0xFF4CAF50), // Level 1-2
      Color(0xFF4CAF50),
      Color(0xFF8BC34A), // Level 3
      Color(0xFFCDDC39), // Level 4
      Color(0xFFFFC107), // Level 5
      Color(0xFFFF9800), // Level 6
      Color(0xFFFF5722), // Level 7
      Color(0xFFE91E63), // Level 8
      Color(0xFF9C27B0), // Level 9
      Color(0xFF673AB7), // Level 10
    ];
    return colors[(level - 1).clamp(0, colors.length - 1)];
  }
}

class _LevelBadgeCircle extends StatefulWidget {
  final double size;
  final int level;
  final String emoji;
  final Color color;

  const _LevelBadgeCircle({
    required this.size,
    required this.level,
    required this.emoji,
    required this.color,
  });

  @override
  State<_LevelBadgeCircle> createState() => _LevelBadgeCircleState();
}

class _LevelBadgeCircleState extends State<_LevelBadgeCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  int _previousLevel = 0;

  @override
  void initState() {
    super.initState();
    _previousLevel = widget.level;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _LevelBadgeCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.level > _previousLevel) {
      _controller.forward(from: 0);
    }
    _previousLevel = widget.level;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMaxLevel = widget.level >= GameConstants.maxLevel;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withOpacity(0.2),
                  widget.color.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: widget.color,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3 + (_glowAnimation.value / 50)),
                  blurRadius: 8 + _glowAnimation.value,
                  spreadRadius: _glowAnimation.value / 3,
                ),
                if (isMaxLevel)
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Level number
                Text(
                  '${widget.level}',
                  style: TextStyle(
                    fontSize: widget.size * 0.4,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
                // Emoji at top right
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.emoji,
                      style: TextStyle(fontSize: widget.size * 0.25),
                    ),
                  ),
                ),
                // Crown for max level
                if (isMaxLevel)
                  Positioned(
                    top: -widget.size * 0.15,
                    child: Text(
                      '👑',
                      style: TextStyle(fontSize: widget.size * 0.3),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Compact level badge for headers
class CompactLevelBadge extends ConsumerWidget {
  final double size;

  const CompactLevelBadge({
    super.key,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(currentLevelProvider);
    final emoji = ref.watch(levelEmojiProvider);
    final color = _getLevelColor(level);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$level',
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Positioned(
            top: -2,
            right: -2,
            child: Text(
              emoji,
              style: TextStyle(fontSize: size * 0.3),
            ),
          ),
        ],
      ),
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
