import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/clippers/progress_mountain_clipper.dart';
import '../../data/providers/providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with TickerProviderStateMixin {
  // Define level positions as percentages of container dimensions
  final List<Map<String, dynamic>> levelPositions = [
    {'level': 10, 'title': 'Summit', 'topPercent': 0.017, 'leftPercent': 0.497},
    {'level': 9, 'title': 'Legend', 'topPercent': 0.110, 'leftPercent': 0.560},
    {'level': 8, 'title': 'Master', 'topPercent': 0.190, 'leftPercent': 0.347},
    {'level': 7, 'title': 'Hero', 'topPercent': 0.275, 'leftPercent': 0.520},
    {'level': 6, 'title': 'Champion', 'topPercent': 0.360, 'leftPercent': 0.387},
    {'level': 5, 'title': 'Explorer', 'topPercent': 0.465, 'leftPercent': 0.453},
    {'level': 4, 'title': 'Adventurer', 'topPercent': 0.580, 'leftPercent': 0.395},
    {'level': 3, 'title': 'Seeker', 'topPercent': 0.670, 'leftPercent': 0.627},
    {'level': 2, 'title': 'Novice', 'topPercent': 0.780, 'leftPercent': 0.693},
    {'level': 1, 'title': 'Beginner', 'topPercent': 0.890, 'leftPercent': 0.600},
  ];
  
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
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
    final progress = ref.watch(progressProvider);
    final currentLevel = progress?.currentLevel ?? 1;
    final highestCompletedLevel = currentLevel - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final containerHeight = screenWidth * 5.33;
            
            return SingleChildScrollView(
              child: SizedBox(
                height: containerHeight,
                width: screenWidth,
                child: Stack(
                  children: [
                    RepaintBoundary(
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
                    ),
                    
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        double colorfulProgress = _calculateColorfulProgress(highestCompletedLevel);
                        
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
                    
                    ...levelPositions.map((levelData) {
                      final topPosition = containerHeight * levelData['topPercent'];
                      final leftPosition = (screenWidth * levelData['leftPercent']) - 40;
                      final isUnlocked = levelData['level'] <= currentLevel;
                      
                      return Positioned(
                        top: topPosition,
                        left: leftPosition.clamp(0.0, screenWidth - 80),
                        child: _buildLevelNode(
                          levelData['level'],
                          levelData['title'],
                          isUnlocked,
                          currentLevel,
                          highestCompletedLevel,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  double _calculateColorfulProgress(int highestCompletedLevel) {
    if (highestCompletedLevel == 0) return 0.0;
    
    double highestCompletedPosition = 1.0;
    
    for (var level in levelPositions) {
      if (level['level'] <= highestCompletedLevel) {
        if (level['topPercent'] < highestCompletedPosition) {
          highestCompletedPosition = level['topPercent'];
        }
      }
    }
    
    return 1.0 - highestCompletedPosition;
  }

  Widget _buildLevelNode(int level, String title, bool isUnlocked, int currentLevel, int highestCompletedLevel) {
    final bool isCurrentLevel = level == currentLevel;
    final bool isCompleted = level <= highestCompletedLevel;
    
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
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
          if (isCurrentLevel) ...[
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
          
          SizedBox(
            width: 80,
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
                    child: SvgPicture.asset(
                      _getSvgAssetForLevel(isCompleted, isCurrentLevel),
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
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
      return 'assets/illustrations/green.svg';
    } else if (isCompleted) {
      return 'assets/illustrations/green.svg';
    } else {
      return 'assets/illustrations/grey.svg';
    }
  }
  
  Color _getLevelNumberBackgroundColor(bool isCompleted, bool isCurrentLevel) {
    if (isCurrentLevel) {
      return const Color(0xFFFFD700).withOpacity(0.9);
    } else if (isCompleted) {
      return Colors.green.withOpacity(0.8);
    } else {
      return Colors.grey.withOpacity(0.6);
    }
  }
  
  Color _getLevelNumberTextColor(bool isCompleted, bool isCurrentLevel) {
    if (isCurrentLevel) {
      return Colors.black;
    } else if (isCompleted) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }
}
