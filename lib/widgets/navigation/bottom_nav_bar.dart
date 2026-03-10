import 'package:flutter/material.dart';

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                Icons.home_rounded,
                'Home',
                const Color(0xFF58CC02), // Green
                currentRoute == 'Home',
              ),
              _buildNavItem(
                context,
                Icons.local_fire_department_rounded,
                'Focus',
                const Color(0xFFFF9600), // Orange
                currentRoute == 'Map',
              ),
              _buildNavItem(
                context,
                Icons.bar_chart_rounded,
                'Stats',
                const Color(0xFF1CB0F6), // Blue
                currentRoute == 'Stats',
              ),
              _buildNavItem(
                context,
                Icons.person_rounded,
                'Profile',
                const Color(0xFFCE82FF), // Purple
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
    IconData icon,
    String label,
    Color themeColor,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(context, label),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: isSelected ? 56 : 48,
                height: isSelected ? 56 : 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? themeColor
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(isSelected ? 16 : 12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: themeColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 28 : 24,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF94A3B8),
                ),
              ),
              
              // Label
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? themeColor : const Color(0xFF94A3B8),
                  letterSpacing: 0.3,
                  height: 1,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
      case 'Focus':
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
