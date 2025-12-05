import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_buddy/data/providers/game_provider.dart';

/// Streak counter widget with fire emoji animation
/// Shows current streak with optional milestone indicator
class StreakCounter extends ConsumerStatefulWidget {
  /// Size of the fire emoji
  final double iconSize;
  
  /// Whether to show the "day streak" text
  final bool showLabel;
  
  /// Whether to animate when at risk
  final bool animateWhenAtRisk;
  
  /// Compact mode for headers
  final bool compact;

  const StreakCounter({
    super.key,
    this.iconSize = 28,
    this.showLabel = true,
    this.animateWhenAtRisk = true,
    this.compact = false,
  });

  @override
  ConsumerState<StreakCounter> createState() => _StreakCounterState();
}

class _StreakCounterState extends ConsumerState<StreakCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startPulse() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulse() {
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(gameStateProvider);
    final streak = stats.currentStreak;
    final isAtRisk = !stats.hasActivityToday && streak > 0;
    final nextMilestone = stats.nextMilestone;
    final daysToMilestone = stats.daysToNextMilestone;

    // Animate when streak is at risk
    if (widget.animateWhenAtRisk && isAtRisk) {
      _startPulse();
    } else {
      _stopPulse();
    }

    if (widget.compact) {
      return _buildCompact(context, streak, isAtRisk);
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(streak, isAtRisk),
        borderRadius: BorderRadius.circular(16),
        border: isAtRisk
            ? Border.all(color: Colors.orange.shade300, width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isAtRisk ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Text(
              _getStreakEmoji(streak),
              style: TextStyle(fontSize: widget.iconSize),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$streak',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(streak, isAtRisk),
                    ),
                  ),
                  if (widget.showLabel) ...[
                    const SizedBox(width: 4),
                    Text(
                      streak == 1 ? 'day' : 'days',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getTextColor(streak, isAtRisk).withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
              if (nextMilestone != null && daysToMilestone != null) ...[
                Text(
                  '$daysToMilestone days to $nextMilestone 🎉',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getTextColor(streak, isAtRisk).withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
          if (isAtRisk) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'At Risk!',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context, int streak, bool isAtRisk) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getStreakEmoji(streak),
          style: TextStyle(fontSize: widget.iconSize * 0.8),
        ),
        const SizedBox(width: 4),
        Text(
          '$streak',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getTextColor(streak, isAtRisk),
          ),
        ),
      ],
    );
  }

  String _getStreakEmoji(int streak) {
    if (streak == 0) return '❄️';
    if (streak < 3) return '🔥';
    if (streak < 7) return '🔥';
    if (streak < 14) return '🔥';
    if (streak < 30) return '💪🔥';
    if (streak < 100) return '⚡🔥';
    return '🏆🔥';
  }

  Color _getBackgroundColor(int streak, bool isAtRisk) {
    if (streak == 0) return Colors.grey.shade100;
    if (isAtRisk) return Colors.orange.shade50;
    if (streak >= 30) return Colors.orange.shade100;
    if (streak >= 7) return Colors.orange.shade50;
    return Colors.orange.shade50;
  }

  Color _getTextColor(int streak, bool isAtRisk) {
    if (streak == 0) return Colors.grey.shade600;
    if (isAtRisk) return Colors.orange.shade700;
    return Colors.orange.shade800;
  }
}

/// Mini streak indicator for tight spaces
class MiniStreakBadge extends ConsumerWidget {
  const MiniStreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(currentStreakProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: streak > 0 ? Colors.orange.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            streak > 0 ? '🔥' : '❄️',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: streak > 0 ? Colors.orange.shade800 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
