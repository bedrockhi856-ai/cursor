import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/dialogue/dialogue_overlay.dart';
import '../../core/router/app_router.dart';

/// The guide (Jack) introduces the game concept before character selection
class GuideIntroScreen extends StatelessWidget {
  const GuideIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueOverlay(
      characterImage: 'assets/illustrations/jackbhai.png',
      characterName: 'Jack',
      dialogues: const [
        "Hey Chief! Life is rough for us, but finally your arrival gives us hope.",
        "You select a character and your focus earns you Lumina.",
        "Your character grows using Lumina. Help them heal!",
      ],
      onComplete: () {
        context.go(AppRoutes.onboardingCharacter);
      },
    );
  }
}
