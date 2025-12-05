import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_buddy/data/providers/game_provider.dart';

/// Gem counter widget with animated gem icon
class GemCounter extends ConsumerStatefulWidget {
  /// Size of the gem icon
  final double iconSize;
  
  /// Whether to show the "gems" label
  final bool showLabel;
  
  /// Compact mode for headers
  final bool compact;

  const GemCounter({
    super.key,
    this.iconSize = 24,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  ConsumerState<GemCounter> createState() => _GemCounterState();
}

class _GemCounterState extends ConsumerState<GemCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int _previousGems = 0;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _playBounce() {
    _bounceController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final gems = ref.watch(totalGemsProvider);

    // Animate when gems increase
    if (gems > _previousGems && _previousGems != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playBounce();
      });
    }
    _previousGems = gems;

    if (widget.compact) {
      return _buildCompact(context, gems);
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: child,
              );
            },
            child: _GemIcon(size: widget.iconSize),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatNumber(gems),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
              if (widget.showLabel)
                Text(
                  'gems',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.purple.shade400,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context, int gems) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GemIcon(size: widget.iconSize * 0.8),
        const SizedBox(width: 4),
        Text(
          _formatNumber(gems),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade700,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// Custom gem icon with gradient
class _GemIcon extends StatelessWidget {
  final double size;

  const _GemIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade300,
            Colors.blue.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '💎',
          style: TextStyle(fontSize: size * 0.6),
        ),
      ),
    );
  }
}

/// Add gems button for in-app purchases or rewards
class AddGemsButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const AddGemsButton({
    super.key,
    this.onTap,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.shade100,
          border: Border.all(color: Colors.green.shade400),
        ),
        child: Icon(
          Icons.add,
          size: size * 0.6,
          color: Colors.green.shade700,
        ),
      ),
    );
  }
}

/// Mini gem badge for tight spaces
class MiniGemBadge extends ConsumerWidget {
  const MiniGemBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gems = ref.watch(totalGemsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            _formatNumber(gems),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
