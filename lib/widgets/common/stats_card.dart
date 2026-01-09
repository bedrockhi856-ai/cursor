import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// A card widget that displays a statistic with icon, value, and label
/// Used on the home screen to show streak and productive time
class StatsCard extends StatelessWidget {
  /// The icon to display
  final IconData icon;
  
  /// The color of the icon
  final Color iconColor;
  
  /// The main value to display (e.g., "5 days")
  final String value;
  
  /// The label below the value (e.g., "streak")
  final String label;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingDf,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: AppColors.greyBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
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
            AppSpacing.verticalSm,
            Text(
              value,
              style: AppTypography.statValue,
            ),
            Text(
              label,
              style: AppTypography.statLabel,
            ),
          ],
        ),
      ),
    );
  }
}

/// Streak stats card with fire icon
class StreakCard extends StatelessWidget {
  final int streak;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      icon: Icons.local_fire_department,
      iconColor: AppColors.orange,
      value: '$streak days',
      label: 'streak',
      onTap: onTap,
    );
  }
}

/// Productive time stats card with clock icon
class ProductiveTimeCard extends StatelessWidget {
  final int minutes;
  final VoidCallback? onTap;

  const ProductiveTimeCard({
    super.key,
    required this.minutes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      icon: Icons.access_time,
      iconColor: AppColors.blue,
      value: '$minutes min',
      label: 'productive',
      onTap: onTap,
    );
  }
}
