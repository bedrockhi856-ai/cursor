import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'onboarding_screens.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart' hide RadialGradient;

// Returns 75% of the input years, rounded to the nearest integer
int getRegainableYears(double years) {
  return (years * 0.75).round();
}

// Custom clipper for progressive mountain color reveal
class ProgressMountainClipper extends CustomClipper<Path> {
  final double progress;
  
  ProgressMountainClipper(this.progress);
  
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // Calculate clip height from bottom based on progress (0.0 to 1.0)
    double clipHeight = size.height * progress;
    
    // Start from bottom-left corner
    path.moveTo(0, size.height);
    
    // Draw bottom edge
    path.lineTo(size.width, size.height);
    
    // Draw right edge up to clip line
    path.lineTo(size.width, size.height - clipHeight);
    
    // Create organic mountain-like curve for the clip line
    // This creates a natural transition that follows mountain contours
    double controlPointOffset = size.width * 0.1;
    
    // Add curves to make the clip line look more natural/organic
    for (int i = 4; i >= 0; i--) {
      double x = size.width * (i / 4.0);
      double y = size.height - clipHeight;
      
      // Add some variation to make it look more natural
      double variation = (i % 2 == 0 ? 10 : -10) * (1 - progress);
      y += variation;
      
      if (i == 4) {
        // Starting point already set above
        continue;
      } else if (i == 0) {
        // End point
        path.lineTo(x, y);
      } else {
        // Control points for smooth curve
        double prevX = size.width * ((i + 1) / 4.0);
        double prevY = size.height - clipHeight + ((i + 1) % 2 == 0 ? 10 : -10) * (1 - progress);
        
        path.quadraticBezierTo(
          (prevX + x) / 2, 
          (prevY + y) / 2 + variation * 0.5, 
          x, 
          y
        );
      }
    }
    
    // Connect back to bottom-left corner
    path.lineTo(0, size.height);
    
    // Close the path
    path.close();
    
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper is ProgressMountainClipper && oldClipper.progress != progress;
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const AgeScreen(), // Start with onboarding
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            viewPadding: EdgeInsets.zero,
          ),
          child: child!,
        );
      },
    );
  }
}



// Focus Screen - For timer and focus sessions
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Mode',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF6B35).withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.timer,
                          size: 80,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Ready to Focus?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Start a focused work session',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TimerSetupScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Start Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Advanced Timer Setup Screen with iOS-like 3D wheels and ripple hold button
class TimerSetupScreen extends StatefulWidget {
  const TimerSetupScreen({super.key});
  
  @override
  State<TimerSetupScreen> createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> with TickerProviderStateMixin {
  int selectedHours = 0;
  int selectedMinutes = 25; // Default to 25 minutes (Pomodoro)
  
  // No longer needed - removed ripple animation controllers
  
  @override
  void initState() {
    super.initState();
    // Simplified - no animation controllers needed for simple start button
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Set Timer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Time display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${selectedHours.toString().padLeft(2, '0')}:${selectedMinutes.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFFFF6B35),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // iOS-like 3D Picker wheels
            Expanded(
              child: Container(
                height: 320,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Hours picker
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Hours',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: CupertinoPicker(
                              backgroundColor: Colors.transparent,
                              itemExtent: 45,
                              diameterRatio: 0.8, // More 3D effect
                              squeeze: 1.2, // Increased squeeze for 3D effect
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  selectedHours = value;
                                });
                                HapticFeedback.selectionClick();
                              },
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedHours,
                              ),
                              children: List.generate(24, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Divider
                    Container(
                      width: 1,
                      height: 240,
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    
                    // Minutes picker
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Minutes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: CupertinoPicker(
                              backgroundColor: Colors.transparent,
                              itemExtent: 45,
                              diameterRatio: 0.8, // More 3D effect
                              squeeze: 1.2, // Increased squeeze for 3D effect
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  selectedMinutes = value;
                                });
                                HapticFeedback.selectionClick();
                              },
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedMinutes,
                              ),
                              children: List.generate(60, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Quick preset buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Presets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPresetButton('5 min', 0, 5),
                      const SizedBox(width: 12),
                      _buildPresetButton('15 min', 0, 15),
                      const SizedBox(width: 12),
                      _buildPresetButton('25 min', 0, 25),
                      const SizedBox(width: 12),
                      _buildPresetButton('1 hour', 1, 0),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Start button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FocusTimerScreen(
                        durationMinutes: (selectedHours * 60) + selectedMinutes,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'START',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPresetButton(String label, int hours, int minutes) {
    final isSelected = selectedHours == hours && selectedMinutes == minutes;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedHours = hours;
            selectedMinutes = minutes;
          });
          HapticFeedback.selectionClick();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(
              color: const Color(0xFFFF6B35),
              width: 2,
            ) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.black54,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Simple Timer Screen
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});
  
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simple Timer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF6B35).withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.timer,
                          size: 80,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Basic Timer View',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No animation here',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Progress Screen - For tracking achievements and stats
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildProgressCard(
                      'Total Focus Time',
                      '12h 34m',
                      Icons.timer,
                      const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCard(
                      'Sessions Completed',
                      '24',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCard(
                      'Current Streak',
                      '7 days',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCard(
                      'Best Session',
                      '45m',
                      Icons.star,
                      Colors.amber,
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

  Widget _buildProgressCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, String label, IconData inactiveIcon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.pop(context);
        } else if (label == 'Profile') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else if (label == 'Map') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        }
        // Stats stays on current screen
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
                fontFamily: 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Screen - For user settings and preferences
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                _buildNavItem(Icons.home_rounded, 'Home', Icons.home_outlined, false),
                _buildNavItem(Icons.map_rounded, 'Map', Icons.map_outlined, false),
                _buildNavItem(Icons.bar_chart_rounded, 'Stats', Icons.bar_chart_outlined, false),
                _buildNavItem(Icons.person_rounded, 'Profile', Icons.person_outlined, true),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mohiddin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Focus Enthusiast',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileItem(Icons.settings, 'Settings'),
                    _buildProfileItem(Icons.notifications, 'Notifications'),
                    _buildProfileItem(Icons.help, 'Help & Support'),
                    _buildProfileItem(Icons.info, 'About'),
                    _buildProfileItem(Icons.logout, 'Logout', isDestructive: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.grey.shade700,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black,
            fontFamily: 'Inter',
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, String label, IconData inactiveIcon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.pop(context);
        } else if (label == 'Stats') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StatsScreen()),
          );
        } else if (label == 'Map') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        }
        // Profile stays on current screen
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
                fontFamily: 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// Stats Screen - For displaying user statistics
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                _buildNavItem(Icons.home_rounded, 'Home', Icons.home_outlined, false),
                _buildNavItem(Icons.map_rounded, 'Map', Icons.map_outlined, false),
                _buildNavItem(Icons.bar_chart_rounded, 'Stats', Icons.bar_chart_outlined, true),
                _buildNavItem(Icons.person_rounded, 'Profile', Icons.person_outlined, false),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Stats',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildStatCard(
                      'Total Focus Time',
                      '12h 34m',
                      Icons.timer,
                      const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Sessions Completed',
                      '24',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Current Streak',
                      '7 days',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Best Session',
                      '45m',
                      Icons.star,
                      Colors.amber,
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

  Widget _buildNavItem(IconData activeIcon, String label, IconData inactiveIcon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.pop(context);
        } else if (label == 'Profile') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else if (label == 'Map') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        }
        // Stats stays on current screen
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
                fontFamily: 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Mountain Screen - For level progression with mountain background
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  // Define level positions as percentages of container dimensions
  // These percentages are based on your original coordinates converted to percentages
  // Original container was roughly width: screenWidth, height: 2000
  // Assuming your test device was ~375px wide (standard iPhone width)
  final List<Map<String, dynamic>> levelPositions = [
    {'level': 10, 'title': 'Summit', 'topPercent': 0.017, 'leftPercent': 0.497, 'unlocked': false}, // y=34/2000, x=186/375
    {'level': 9, 'title': 'Legend', 'topPercent': 0.110, 'leftPercent': 0.560, 'unlocked': false}, // y=220/2000, x=210/375  
    {'level': 8, 'title': 'Master', 'topPercent': 0.190, 'leftPercent': 0.347, 'unlocked': false}, // y=380/2000, x=130/375
    {'level': 7, 'title': 'Hero', 'topPercent': 0.275, 'leftPercent': 0.520, 'unlocked': false}, // y=550/2000, x=195/375
    {'level': 6, 'title': 'Champion', 'topPercent': 0.360, 'leftPercent': 0.387, 'unlocked': false}, // y=720/2000, x=145/375
    {'level': 5, 'title': 'Explorer', 'topPercent': 0.465, 'leftPercent': 0.453, 'unlocked': false}, // y=930/2000, x=170/375
    {'level': 4, 'title': 'Adventurer', 'topPercent': 0.580, 'leftPercent': 0.395, 'unlocked': false}, // y=1160/2000, x=148/375
    {'level': 3, 'title': 'Seeker', 'topPercent': 0.670, 'leftPercent': 0.627, 'unlocked': true}, // y=1340/2000, x=235/375
    {'level': 2, 'title': 'Novice', 'topPercent': 0.780, 'leftPercent': 0.693, 'unlocked': true}, // y=1560/2000, x=260/375
    {'level': 1, 'title': 'Beginner', 'topPercent': 0.890, 'leftPercent': 0.600, 'unlocked': true}, // y=1780/2000, x=225/375
  ];
  
  // User's current progress (simulate user being at level 3)
  int currentLevel = 3;
  int highestCompletedLevel = 2;
  
  // Animation controllers for glow effect on current level
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Glow animation controller for current level
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Pulse animation controller for current level
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start continuous animations for current level highlight
    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                _buildNavItem(Icons.home_rounded, 'Home', Icons.home_outlined, false),
                _buildNavItem(Icons.map_rounded, 'Map', Icons.map_outlined, true),
                _buildNavItem(Icons.bar_chart_rounded, 'Stats', Icons.bar_chart_outlined, false),
                _buildNavItem(Icons.person_rounded, 'Profile', Icons.person_outlined, false),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive dimensions
            final screenWidth = constraints.maxWidth;
            final containerHeight = screenWidth * 5.33; // Maintain aspect ratio (2000/375 ≈ 5.33)
            
            return SingleChildScrollView(
              child: Container(
                height: containerHeight,
                width: screenWidth,
                child: Stack(
                  children: [
                    // Base greyscale mountain background
                    Container(
                      height: containerHeight,
                      width: screenWidth,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/background/no_color.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    // Colorful mountain overlay - reveals progressively based on progress
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        // Calculate progress-based mask
                        // Show colorful version from bottom up to highest completed level
                        double colorfulProgress = _calculateColorfulProgress();
                        
                        return ClipPath(
                          clipper: ProgressMountainClipper(colorfulProgress),
                          child: Container(
                            height: containerHeight,
                            width: screenWidth,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/background/color.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Level nodes positioned on top
                    ...levelPositions.map((levelData) {
                      // Calculate responsive positions
                      final topPosition = containerHeight * levelData['topPercent'];
                      final leftPosition = (screenWidth * levelData['leftPercent']) - 40; // 40 = half of icon width for centering
                      
                      return Positioned(
                        top: topPosition,
                        left: leftPosition.clamp(0.0, screenWidth - 80), // Ensure icon stays within bounds
                        child: _buildLevelNode(
                          levelData['level'],
                          levelData['title'],
                          levelData['unlocked'],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  // Calculate how much of the mountain should be colorful based on progress
  double _calculateColorfulProgress() {
    if (highestCompletedLevel == 0) return 0.0;
    
    // Find the highest completed level's position
    double highestCompletedPosition = 1.0; // Start from bottom (100%)
    
    for (var level in levelPositions) {
      if (level['level'] <= highestCompletedLevel) {
        // Update to the highest (smallest topPercent) completed level
        if (level['topPercent'] < highestCompletedPosition) {
          highestCompletedPosition = level['topPercent'];
        }
      }
    }
    
    // Return percentage from bottom (1.0) to highest completed level
    return 1.0 - highestCompletedPosition;
  }

  Widget _buildLevelNode(int level, String title, bool isUnlocked) {
    final bool isCurrentLevel = level == currentLevel;
    final bool isCompleted = level <= highestCompletedLevel;
    
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          // Handle level selection
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Level $level: $title'),
              backgroundColor: const Color(0xFFFF6B35),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complete previous levels to unlock this!'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      },
      child: Stack(
              alignment: Alignment.center,
              children: [
                // Enhanced glow effect for current level - multiple layers
                if (isCurrentLevel) ...[
                  // Outer glow layer (largest)
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.2 * _glowAnimation.value),
                              const Color(0xFFFFD700).withOpacity(0.05 * _glowAnimation.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Middle glow layer
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 110 * _pulseAnimation.value,
                        height: 110 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.6 * _glowAnimation.value),
                              const Color(0xFFFFD700).withOpacity(0.2 * _glowAnimation.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Inner bright core
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.8 * _glowAnimation.value),
                              const Color(0xFFFFD700).withOpacity(0.4 * _glowAnimation.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
                  
                // Main level node container
                Container(
                  width: 80,
                  height: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SVG checkpoint with enhanced styling based on state
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Add background color for current level
                          color: isCurrentLevel ? const Color(0xFFFFD700).withOpacity(0.1) : null,
                          border: isCurrentLevel ? Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2,
                          ) : null,
                          boxShadow: isCurrentLevel ? [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ] : isCompleted ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ] : null,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle : 
                          isCurrentLevel ? Icons.radio_button_checked : 
                          Icons.radio_button_unchecked,
                          size: 40,
                          color: isCompleted ? Colors.green : 
                                 isCurrentLevel ? const Color(0xFFFFD700) : 
                                 Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Level number with enhanced styling
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getLevelNumberBackgroundColor(isCompleted, isCurrentLevel),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$level',
                            style: TextStyle(
                              color: _getLevelNumberTextColor(isCompleted, isCurrentLevel),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  String _getSvgAssetForLevel(bool isCompleted, bool isCurrentLevel) {
    if (isCurrentLevel) {
      return 'assets/illustrations/green.svg'; // Current level uses colorful green
    } else if (isCompleted) {
      return 'assets/illustrations/green.svg'; // Completed levels use green
    } else {
      return 'assets/illustrations/grey.svg'; // Locked levels use grey
    }
  }
  
  Color _getLevelNumberBackgroundColor(bool isCompleted, bool isCurrentLevel) {
    if (isCurrentLevel) {
      return const Color(0xFFFFD700).withOpacity(0.9); // Gold background for current
    } else if (isCompleted) {
      return Colors.green.withOpacity(0.8); // Green background for completed
    } else {
      return Colors.grey.withOpacity(0.6); // Grey background for locked
    }
  }
  
  Color _getLevelNumberTextColor(bool isCompleted, bool isCurrentLevel) {
    if (isCurrentLevel) {
      return Colors.black; // Dark text on gold background
    } else if (isCompleted) {
      return Colors.white; // White text on green background
    } else {
      return Colors.white; // White text on grey background
    }
  }

  Widget _buildNavItem(IconData activeIcon, String label, IconData inactiveIcon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.pop(context);
        } else if (label == 'Stats') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StatsScreen()),
          );
        } else if (label == 'Profile') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
        // Map stays on current screen
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
                fontFamily: 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class HoldToBeginButton extends StatefulWidget {
  final VoidCallback onHoldComplete;
  final String text;
  final Color buttonColor;
  final double width;
  final double height;

  const HoldToBeginButton({
    super.key,
    required this.onHoldComplete,
    this.text = 'hold',
    this.buttonColor = const Color(0xFFFF6B35),
    this.width = 120,
    this.height = 60,
  });

  @override
  State<HoldToBeginButton> createState() => _HoldToBeginButtonState();
}

class _HoldToBeginButtonState extends State<HoldToBeginButton>
    with TickerProviderStateMixin {
  late AnimationController _holdController;
  late AnimationController _expandController;
  late AnimationController _glowController;
  
  // 3 Continuous ripple controllers
  late AnimationController _rippleController1;
  late AnimationController _rippleController2;
  late AnimationController _rippleController3;
  
  late Animation<double> _holdAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _glowAnimation;
  
  // 3 Continuous ripple animations
  late Animation<double> _rippleAnimation1;
  late Animation<double> _rippleAnimation2;
  late Animation<double> _rippleAnimation3;
  
  bool _isHolding = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    
    // Hold animation (2 seconds)
    _holdController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Expand animation (blob expansion)
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Glow animation - continuous growing
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 3 Continuous ripple controllers with staggered timing
    _rippleController1 = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rippleController2 = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rippleController3 = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _holdAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_holdController);
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    // Create ripple animations
    _rippleAnimation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController1,
      curve: Curves.easeOut,
    ));
    
    _rippleAnimation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController2,
      curve: Curves.easeOut,
    ));
    
    _rippleAnimation3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController3,
      curve: Curves.easeOut,
    ));

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerExpand();
      }
    });
  }

  void _triggerExpand() {
    setState(() {
      _isCompleted = true;
    });
    _expandController.forward().then((_) {
      widget.onHoldComplete();
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    _expandController.dispose();
    _glowController.dispose();
    _rippleController1.dispose();
    _rippleController2.dispose();
    _rippleController3.dispose();
    super.dispose();
  }

  void _startHold() {
    setState(() {
      _isHolding = true;
    });
    _holdController.forward();
    _glowController.repeat(reverse: true);
    
    // Start 3 continuous ripples with staggered timing
    _rippleController1.repeat();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isHolding) _rippleController2.repeat();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_isHolding) _rippleController3.repeat();
    });
  }

  void _stopHold() {
    setState(() {
      _isHolding = false;
    });
    _holdController.reset();
    _glowController.stop();
    _glowController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _holdAnimation,
        _expandAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Expanding blob effect (covers most of screen)
            if (_isCompleted)
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.0 + (_expandAnimation.value * 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.buttonColor.withOpacity((0.8 * _expandAnimation.value).clamp(0.0, 1.0)),
                    ),
                  ),
                ),
              ),
            
            // Glow aura while holding
            if (_isHolding)
              Transform.scale(
                scale: 1.0 + (_glowAnimation.value * 0.3),
                child: Container(
                  width: widget.width * 1.5,
                  height: widget.height * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.buttonColor.withOpacity((0.2 * _glowAnimation.value).clamp(0.0, 1.0)),
                  ),
                ),
              ),
            
            // Main button
            GestureDetector(
              onTapDown: (_) => _startHold(),
              onTapUp: (_) => _stopHold(),
              onTapCancel: () => _stopHold(),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.buttonColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.buttonColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FirstScreen extends StatefulWidget {
  final int? regainableYears;
  const FirstScreen({super.key, this.regainableYears});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> with TickerProviderStateMixin {
  bool isSwitchOn = false;
  late AnimationController _headingController;
  late AnimationController _switchController;
  late AnimationController _backgroundController;
  late AnimationController _holdController;
  
  late Animation<double> _headingAnimation;
  late Animation<double> _switchAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _holdAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Heading fade in animation
    _headingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Switch toggle animation
    _switchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Background brightness animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Hold button pulse animation
    _holdController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _headingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headingController,
      curve: Curves.easeOut,
    ));
    
    _switchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _holdAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _holdController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _headingController.forward();
    _holdController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _headingController.dispose();
    _switchController.dispose();
    _backgroundController.dispose();
    _holdController.dispose();
    super.dispose();
  }
  
  void onHoldComplete() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SecondScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int regainYears = widget.regainableYears ?? 3;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _headingAnimation,
          _switchAnimation,
          _backgroundAnimation,
          _holdAnimation,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/background/darkphone.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity((0.4 + (0.1 * _backgroundAnimation.value)).clamp(0.0, 1.0)),
                  BlendMode.darken,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Heading - fade in from top
                    AnimatedOpacity(
                      opacity: _headingAnimation.value,
                      duration: const Duration(milliseconds: 600),
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _headingAnimation.value)),
                        child: Text(
                          'Want to regain $regainYears years\nof your life?',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inter',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Freedom Switch card with enhanced toggle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  isSwitchOn ? Icons.lock_open : Icons.lock,
                                  key: ValueKey(isSwitchOn),
                                  size: 28,
                                  color: isSwitchOn ? Colors.green[600] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Freedom Switch',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    Text(
                                      'Turn ON to unlock your potential',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Enhanced animated toggle switch
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSwitchOn = !isSwitchOn;
                                  });
                                  if (isSwitchOn) {
                                    _switchController.forward();
                                    _backgroundController.forward();
                                  } else {
                                    _switchController.reverse();
                                    _backgroundController.reverse();
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 48,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSwitchOn ? Colors.green[600] : Colors.grey[600],
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isSwitchOn ? Colors.green[600] : Colors.grey[600])!.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 300),
                                    alignment: isSwitchOn ? Alignment.centerRight : Alignment.centerLeft,
                                    curve: Curves.easeOutBack,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      margin: EdgeInsets.only(
                                        left: isSwitchOn ? 22 : 2,
                                        right: isSwitchOn ? 2 : 22,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Enhanced Hold button with ripple effect
                    Center(
                      child: HoldToBeginButton(
                        onHoldComplete: onHoldComplete,
                        text: 'hold',
                        buttonColor: const Color(0xFFFF6B35),
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> with TickerProviderStateMixin {
  bool _freedomSwitch = true; // Start with switch ON
  late AnimationController _switchController;
  late AnimationController _glowController;
  late Animation<double> _switchAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _switchController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _switchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _switchController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // Start with switch ON and animate it
    _switchController.forward();
    _glowController.forward();
  }

  @override
  void dispose() {
    _switchController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_freedomSwitch 
              ? 'assets/background/sunset2.jpg' 
              : 'assets/background/darkphone.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Title - centered with fade in
                AnimatedBuilder(
                  animation: _switchAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * _switchAnimation.value),
                      child: Opacity(
                        opacity: _switchAnimation.value,
                        child: Center(
                          child: Text(
                            'Freedom',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Georgia',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 2),
                // Freedom switch card - enhanced with animations
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.95 + (0.05 * _glowAnimation.value),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20 + (5 * _glowAnimation.value),
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.lock_open,
                                    key: const ValueKey('unlocked'),
                                    size: 28,
                                    color: Colors.green[600],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Freedom Switch',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      Text(
                                        'Your potential is now unlocked!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green[600],
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Animated toggle switch
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: 48,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.green[600],
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green[600]!.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                // Continue button with enhanced animations
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.3 + (0.1 * _glowAnimation.value)),
                            blurRadius: 15 + (5 * _glowAnimation.value),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const CharacterSelectionScreen()),
                            );
                          },
                          child: Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> 
    with TickerProviderStateMixin {
  int selectedCharacter = 0;
  
  // Animation controllers
  late AnimationController _cardAnimationController;
  late AnimationController _continueButtonController;
  late AnimationController _pulseController;
  
  // Animations
  late List<Animation<double>> _cardAnimations;
  late Animation<double> _continueButtonAnimation;
  late Animation<double> _pulseAnimation;
  
  final List<Map<String, String>> characters = [
    {'name': 'David', 'title': 'unemployed engineer'},
    {'name': 'David', 'title': 'unemployed engineer'},
    {'name': 'David', 'title': 'unemployed engineer'},
    {'name': 'David', 'title': 'unemployed engineer'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Card animation controller for staggered animations
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Continue button animation controller
    _continueButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Pulse animation controller for attention
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Create staggered card animations
    _cardAnimations = List.generate(
      characters.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.05, // Staggered by 0.05s
            (index + 1) * 0.05,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );
    
    // Continue button scale animation
    _continueButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _continueButtonController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Pulse animation for attention
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start card animations
    _cardAnimationController.forward();
    
    // Start pulse animation after 3 seconds if no character selected
    Future.delayed(const Duration(seconds: 3), () {
      if (selectedCharacter == 0 && mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _continueButtonController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onCharacterTap(int index) {
    setState(() {
      selectedCharacter = index;
    });
    
    // Stop pulse animation when character is selected
    _pulseController.stop();
    _pulseController.reset();
  }

  void _onContinueTap() {
    _continueButtonController.forward().then((_) {
      _continueButtonController.reverse();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with hamburger menu and app name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                      fontFamily: 'Arial',
                    ),
                  ),
                ],
              ),
            ),
            
            // Main title
            const SizedBox(height: 20),
            const Text(
              'Select your character',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Georgia',
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Character cards with staggered animations
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView.builder(
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedCharacter == index;
                    return AnimatedBuilder(
                      animation: _cardAnimations[index],
                      builder: (context, child) {
                                            return Transform.translate(
                      offset: Offset(0, 50 * (1 - _cardAnimations[index].value)),
                      child: Opacity(
                        opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildCharacterCard(index, isSelected),
                        ),
                      ),
                    );
                      },
                    );
                  },
                ),
              ),
            ),
            
            // Continue button with enhanced animations
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _continueButtonAnimation,
                  _pulseAnimation,
                ]),
                builder: (context, child) {
                  final scale = _continueButtonAnimation.value * 
                    (selectedCharacter == 0 ? _pulseAnimation.value : 1.0);
                  
                  return Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: _onContinueTap,
                        child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCard(int index, bool isSelected) {
    return GestureDetector(
      onTap: () => _onCharacterTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
            color: isSelected ? const Color(0xFFFFD93D) : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 12 : 8,
                                offset: const Offset(0, 2),
              spreadRadius: isSelected ? 2 : 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
            // Profile picture with ripple effect
            Stack(
              children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade200,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey.shade600,
                                ),
                ),
                // Ripple effect when selected
                if (isSelected)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD93D).withOpacity(0.2),
                    ),
                  ),
              ],
                              ),
                              const SizedBox(width: 16),
                              // Character info
            Expanded(
              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    characters[index]['name']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  Text(
                                    characters[index]['title']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
              ),
                              ),
                            ],
                        ),
                      ),
                    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _greetingController;
  late AnimationController _progressController;
  late AnimationController _speechController;
  late AnimationController _typingController;
  late AnimationController _focusButtonController;
  late AnimationController _pulseController;
  late AnimationController _longPressController;
  
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
    
    // Start animations
    _greetingController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _speechController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _typingController.forward();
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

  void _onFocusButtonTap() {
    _focusButtonController.forward().then((_) {
      _focusButtonController.reverse();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const TimerSetupScreen()),
      );
    });
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
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                _buildNavItem(Icons.home_rounded, 'Home', Icons.home_outlined, true),
                _buildNavItem(Icons.map_rounded, 'Map', Icons.map_outlined, false),
                _buildNavItem(Icons.bar_chart_rounded, 'Stats', Icons.bar_chart_outlined, false),
                _buildNavItem(Icons.person_rounded, 'Profile', Icons.person_outlined, false),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with hamburger menu, app name, and progress bar
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
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
                    // Progress bar with animation
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Level 2',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 1),
                        // XP Progress Bar with lightning icon
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 120,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                    widthFactor: (320 / 500) * _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                        color: Color(0xFFFF6B35),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.flash_on,
                              size: 16,
                              color: Color(0xFFFFD700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '320/500 XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                        );
                      },
                    ),
                  ],
                ),
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
                'Ready to grow again, Mohiddin?',
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                              color: Color(0xFFE3F2FD),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 32,
                              color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(width: 16),
                          // Chat bubble with typing indicator
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                                color: Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'David',
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
                            'My son said you look big papa, thanks to you mohiddin !!',
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
                      value: '97 days',
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
                      value: '1200 min',
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
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _focusButtonAnimation,
                    _pulseAnimation,
                    _longPressAnimation,
                  ]),
                  builder: (context, child) {
                    final scale = _focusButtonAnimation.value;
                    final pulseOpacity = _pulseAnimation.value;
                    final fillProgress = _longPressAnimation.value;
                    
                    return GestureDetector(
                      onTap: _onFocusButtonTap,
                      onLongPressStart: _onFocusButtonLongPressStart,
                      onLongPressEnd: _onFocusButtonLongPressEnd,
                      onLongPress: _onFocusButtonLongPressComplete,
                      child: Transform.scale(
                        scale: scale,
                        child: Stack(
                          children: [
                            // Pulsing glow effect
                            Container(
                              width: double.infinity,
                              height: 56,
                      decoration: BoxDecoration(
                                color: Color(0xFFFFD700).withOpacity(pulseOpacity * 0.3),
                        borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Main button with long press fill effect
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                                    color: Color(0xFFFFD700).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                              child: Stack(
                        children: [
                                  // Fill effect from left to right
                                  if (_isLongPressing)
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: FractionallySizedBox(
                                        widthFactor: fillProgress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFFB800),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Button text
                                  Center(
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
                    );
                  },
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
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
    // Flame icon grows and flickers
    // This will be handled by the animation system
  }

  void _onProductiveCardTap() {
    // Clock icon ticks forward twice
    // This will be handled by the animation system
  }

  Widget _buildNavItem(IconData activeIcon, String label, IconData inactiveIcon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Stats') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StatsScreen()),
          );
        } else if (label == 'Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else if (label == 'Map') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        }
        // Home stays on current screen
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade600,
                fontFamily: 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}


class FailScreenOverlay extends StatefulWidget {
  final int remainingMinutes;
  final VoidCallback onComplete;
  final Offset sliderPosition;
  
  const FailScreenOverlay({
    super.key,
    required this.remainingMinutes,
    required this.onComplete,
    required this.sliderPosition,
  });

  @override
  State<FailScreenOverlay> createState() => _FailScreenOverlayState();
}

class _FailScreenOverlayState extends State<FailScreenOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  
  late Animation<double> _rippleAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Ripple animation - starts from slider position and spreads
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    
    // Main text animation - slower and smoother
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Button animation - faster
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCubic),
    );
    
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    
    // Start ripple immediately
    _rippleController.forward().then((_) {
      if (mounted) {
        _textController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _buttonController.forward();
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _rippleController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_rippleAnimation, _textAnimation, _buttonAnimation]),
      builder: (context, child) {
        return Container(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            children: [
              // Red ripple effect starting from center of slider (like freedom switch)
              Positioned(
                left: widget.sliderPosition.dx - 30, // Center on slider
                top: widget.sliderPosition.dy - 30,
                child: Transform.scale(
                  scale: 1.0 + (_rippleAnimation.value * 50.0), // Much larger scale to cover whole screen
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF1744).withOpacity(1.0), // Full red opacity
                    ),
                  ),
                ),
              ),
              
              // Main content
              Column(
                children: [
                  // Spacer to push content down
                  const Spacer(),
                  
                  // Main text - perfectly centered
                  Transform.scale(
                    scale: _textAnimation.value.clamp(0.0, 2.0),
                    child: Opacity(
                      opacity: _textAnimation.value.clamp(0.0, 1.0),
                      child: Text(
                        'Better luck next time',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Button at bottom bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                    child: Opacity(
                      opacity: _buttonAnimation.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: _buttonAnimation.value.clamp(0.8, 1.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onComplete();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFB71C1C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SlideToActSlider extends StatefulWidget {
  final VoidCallback onSurrender;
  final Function(Offset) onSliderPosition;
  
  const SlideToActSlider({
    super.key,
    required this.onSurrender,
    required this.onSliderPosition,
  });

  @override
  State<SlideToActSlider> createState() => _SlideToActSliderState();
}

class _SlideToActSliderState extends State<SlideToActSlider>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _flashController;
  late Animation<double> _slideAnimation;
  late Animation<double> _flashAnimation;
  
  double _slideProgress = 0.0;
  bool _isDragging = false;
  bool _isCompleted = false;
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _flashController.dispose();
    super.dispose();
  }
  
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (_isCompleted) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final sliderWidth = renderBox.size.width;
    
    setState(() {
      _slideProgress = (localPosition.dx / sliderWidth).clamp(0.0, 1.0);
    });
  }
  
  void _onPanEnd(DragEndDetails details) {
    if (_isCompleted) return;
    
    if (_slideProgress >= 0.85) {
      // Complete the slide
      _completeSlide();
    } else {
      // Reset to start
      _resetSlide();
    }
    
    setState(() {
      _isDragging = false;
    });
  }
  
  void _completeSlide() async {
    setState(() {
      _isCompleted = true;
      _slideProgress = 1.0;
    });
    
    // Get slider center position (bottom center of the slider)
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final sliderCenterPosition = renderBox.localToGlobal(Offset(renderBox.size.width / 2, renderBox.size.height / 2));
    widget.onSliderPosition(sliderCenterPosition);
    
    // Haptic feedback (error buzz)
    await Haptics.vibrate(HapticsType.error);
    
    // Flash animation
    _flashController.forward().then((_) {
      _flashController.reverse();
    });
    
    // Trigger surrender function immediately to start ripple
    widget.onSurrender();
  }
  
  void _resetSlide() {
    setState(() {
      _slideProgress = 0.0;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sliderWidth = screenWidth * 0.85;
    final sliderHeight = sliderWidth / 7; // 7:1 ratio
    
    return Positioned(
      bottom: 20,
      left: (screenWidth - sliderWidth) / 2,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Container(
          width: sliderWidth,
          height: sliderHeight,
          child: Stack(
            children: [
              // Background track
              Container(
                width: sliderWidth,
                height: sliderHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700), // Bright yellow
                  borderRadius: BorderRadius.circular(sliderHeight / 2),
                ),
              ),
              
              // Red fill that reveals as user slides with radial gradient
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: sliderWidth * _slideProgress,
                      height: sliderHeight,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.centerLeft,
                          radius: 1.5,
                          colors: [
                            const Color(0xFFFF1744), // Bright red center
                            const Color(0xFFD32F2F), // Medium red
                            const Color(0xFFB71C1C), // Dark red edges
                          ],
                        ),
                        borderRadius: BorderRadius.circular(sliderHeight / 2),
                      ),
                    ),
                  );
                },
              ),
              
              // Flash overlay when completed
              AnimatedBuilder(
                animation: _flashAnimation,
                builder: (context, child) {
                  if (!_isCompleted) return const SizedBox.shrink();
                  
                  return Container(
                    width: sliderWidth,
                    height: sliderHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000).withOpacity((_flashAnimation.value * 0.3).clamp(0.0, 1.0)),
                      borderRadius: BorderRadius.circular(sliderHeight / 2),
                    ),
                  );
                },
              ),
              
              // White knob with arrow
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  final knobPosition = (sliderWidth - sliderHeight) * _slideProgress;
                  
                  return Positioned(
                    left: knobPosition,
                    top: 0,
                    child: Container(
                      width: sliderHeight,
                      height: sliderHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward,
                          color: const Color(0xFFFFD700),
                          size: sliderHeight * 0.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Text overlay
              Center(
                child: Text(
                  _isCompleted ? 'Surrendered!' : 'Slide to Surrender',
                  style: TextStyle(
                    fontSize: sliderHeight * 0.35,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FocusTimerScreen extends StatefulWidget {
  final int durationMinutes;
  
  const FocusTimerScreen({super.key, required this.durationMinutes});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> with TickerProviderStateMixin {
  late Timer _timer;
  
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _showFailScreen = false;
  Offset? _sliderPosition;
  
  // Rive animation variables
  Artboard? _riveArtboard;
  StateMachineController? _stateMachineController;
  SMIInput<double>? _progressInput;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _totalSeconds = widget.durationMinutes * 60;
    
    // Load Rive animation
    _loadRiveFile();
    
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  void _loadRiveFile() async {
    try {
      final data = await rootBundle.load('assets/animation/tree.riv');
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      
      // Try to get state machine controller
      var controller = StateMachineController.fromArtboard(
        artboard, 
        'State Machine 1' // Default state machine name
      );
      
      // If default doesn't work, try getting the first available state machine
      if (controller == null) {
        // Get the first state machine if default name doesn't work
        final stateMachine = artboard.stateMachines.isNotEmpty ? artboard.stateMachines.first : null;
        if (stateMachine != null) {
          controller = StateMachineController.fromArtboard(artboard, stateMachine.name);
        }
      }
      
      if (controller != null) {
        artboard.addController(controller);
        
        // Try to find progress input - common names
        _progressInput = controller.findInput<double>('progress') ??
                        controller.findInput<double>('Progress') ??
                        controller.findInput<double>('growth') ??
                        controller.findInput<double>('Growth');
      }
      
      setState(() {
        _riveArtboard = artboard;
        _stateMachineController = controller;
      });
      
      // Update initial progress
      _updateRiveProgress();
    } catch (e) {
      print('Error loading Rive file: $e');
      // Continue without Rive animation if loading fails
    }
  }
  
  void _updateRiveProgress() {
    if (_progressInput != null) {
      // Calculate progress from 0.0 to 1.0 (how much of the timer is completed)
      double progress = 1.0 - (_remainingSeconds / _totalSeconds);
      _progressInput!.value = progress;
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          // Update Rive animation progress as the timer counts down
          _updateRiveProgress();
        } else {
          _timer.cancel();
          _isRunning = false;
          // Ensure animation is at 100% when timer completes
          _updateRiveProgress();
        }
      });
    });
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _resumeTimer() {
    if (_isPaused) {
      _startTimer();
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _surrender() {
    _timer.cancel();
    setState(() {
      _showFailScreen = true;
    });
  }
  
  void _onSliderPosition(Offset position) {
    _sliderPosition = position;
  }
  
  void _onFailScreenComplete() {
    setState(() {
      _showFailScreen = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Speech bubble with improved styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Stay Focused',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '😰',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Enhanced circular progress bar with timer inside
                  Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular progress bar with enhanced styling
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: CircularProgressIndicator(
                              value: 1.0 - (_remainingSeconds / (widget.durationMinutes * 60)),
                              strokeWidth: 12,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                            ),
                          ),
                          
                          // Timer display inside the circle with enhanced styling
                          Text(
                            _formatTime(_remainingSeconds),
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  const Spacer(),
                  
                  // Bottom spacing for slider
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Slide to act slider positioned at bottom
          SlideToActSlider(
            onSurrender: _surrender,
            onSliderPosition: _onSliderPosition,
          ),
          
          // Fail screen overlay
          if (_showFailScreen && _sliderPosition != null)
            FailScreenOverlay(
              remainingMinutes: _remainingSeconds ~/ 60,
              onComplete: _onFailScreenComplete,
              sliderPosition: _sliderPosition!,
            ),
        ],
      ),
    );
  }
}