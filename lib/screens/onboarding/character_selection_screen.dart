import 'package:flutter/material.dart';
import '../home/home_screen.dart';

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
