import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/providers.dart';

class CharacterSelectionScreen extends ConsumerStatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  ConsumerState<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends ConsumerState<CharacterSelectionScreen> 
    with SingleTickerProviderStateMixin {
  int selectedCharacter = 0;
  
  // Single animation controller for staggered card entry
  late AnimationController _entryController;
  
  final List<Map<String, String>> characters = [
    {'name': 'David', 'title': 'unemployed engineer'},
    {'name': 'David', 'title': 'unemployed engineer'},
    {'name': 'David', 'title': 'unemployed engineer'},
    {'name': 'David', 'title': 'unemployed engineer'},
  ];

  @override
  void initState() {
    super.initState();
    
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Start entry animation
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _onCharacterTap(int index) {
    setState(() {
      selectedCharacter = index;
    });
  }

  void _onContinueTap() async {
    debugPrint('🎯 CharacterSelection: Starting onboarding completion...');
    debugPrint('🎯 CharacterSelection: Selected character index: $selectedCharacter');
    
    // Save character selection and mark onboarding as complete
    await ref.read(userProvider.notifier).updateCharacter('character_$selectedCharacter');
    await ref.read(userProvider.notifier).completeOnboarding();
    
    // Debug: Verify save
    final user = ref.read(userProvider);
    debugPrint('✅ CharacterSelection: Onboarding complete!');
    debugPrint('✅ CharacterSelection: User data: age=${user?.age}, character=${user?.characterId}');
    debugPrint('✅ CharacterSelection: Onboarding flag: ${user?.onboardingCompleted}');
    
    if (mounted) {
      debugPrint('🔄 CharacterSelection: Navigating to home screen...');
      context.go(AppRoutes.home);
    }
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
                  const Icon(
                    Icons.menu,
                    size: 24,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 12),
                  const Text(
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
                    
                    // Staggered delay based on index
                    final delay = index * 0.15;
                    final start = delay.clamp(0.0, 0.7);
                    final end = (delay + 0.3).clamp(0.0, 1.0);
                    
                    return AnimatedBuilder(
                      animation: _entryController,
                      builder: (context, _) {
                        // Calculate animation value for this specific card
                        final progress = _entryController.value;
                        double cardValue;
                        if (progress < start) {
                          cardValue = 0.0;
                        } else if (progress > end) {
                          cardValue = 1.0;
                        } else {
                          cardValue = ((progress - start) / (end - start)).clamp(0.0, 1.0);
                        }
                        
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - cardValue)),
                          child: Opacity(
                            opacity: cardValue,
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
            
            // Continue button
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                  child: const Center(
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
            // Profile picture
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected 
                    ? const Color(0xFFFFD93D).withOpacity(0.2)
                    : Colors.grey.shade200,
              ),
              child: Icon(
                Icons.person,
                size: 30,
                color: isSelected 
                    ? const Color(0xFFFFD93D)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            // Character info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    characters[index]['name']!,
                    style: const TextStyle(
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
            // Checkmark for selected
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD93D),
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
