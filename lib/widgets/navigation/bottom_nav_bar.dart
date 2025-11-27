import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Reusable bottom navigation bar
/// Used across Home, Map, Stats, and Profile screens
class BottomNavBar extends StatelessWidget {
  final String currentRoute;
  
  const BottomNavBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.home_rounded,
                'Home',
                Icons.home_outlined,
                currentRoute == 'Home',
              ),
              _buildNavItem(
                context,
                Icons.map_rounded,
                'Map',
                Icons.map_outlined,
                currentRoute == 'Map',
              ),
              _buildNavItem(
                context,
                Icons.bar_chart_rounded,
                'Stats',
                Icons.bar_chart_outlined,
                currentRoute == 'Stats',
              ),
              _buildNavItem(
                context,
                Icons.person_rounded,
                'Profile',
                Icons.person_outlined,
                currentRoute == 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData activeIcon,
    String label,
    IconData inactiveIcon,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _handleNavigation(context, label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.defaultRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                size: AppDimens.iconSize,
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.grey.shade600,
                fontFamily: AppFonts.inter,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String label) async {
    if (label == currentRoute) return; // Already on this screen
    
    // Wait for gesture to complete
    await Future.delayed(const Duration(milliseconds: 50));
    if (!context.mounted) return;
    
    // Navigation logic - using named routes would be better in production
    switch (label) {
      case 'Home':
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 'Map':
        // Navigate to MapScreen
        Navigator.of(context).pushReplacementNamed('/map');
        break;
      case 'Stats':
        // Navigate to StatsScreen
        Navigator.of(context).pushReplacementNamed('/stats');
        break;
      case 'Profile':
        // Navigate to ProfileScreen
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }
}
