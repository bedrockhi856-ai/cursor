import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/strings.dart';

/// A chat bubble widget that displays a buddy message
/// Used on the home screen to show motivational messages
class BuddyChatBubble extends StatelessWidget {
  /// The buddy's name
  final String buddyName;
  
  /// The message to display
  final String message;
  
  /// Whether to show typing indicator instead of message
  final bool isTyping;
  
  /// Animation value for typing indicator (0.0 to 1.0)
  final double typingAnimationValue;

  const BuddyChatBubble({
    super.key,
    this.buddyName = 'Your Buddy',
    required this.message,
    this.isTyping = false,
    this.typingAnimationValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightBlue,
          ),
          child: Icon(
            Icons.person,
            size: 32,
            color: AppColors.blueIcon,
          ),
        ),
        AppSpacing.horizontalDf,
        // Chat bubble
        Expanded(
          child: Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: AppColors.deepBlue,
              borderRadius: AppRadius.radiusLg,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowStrong,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buddyName,
                  style: AppTypography.chatTitle,
                ),
                const SizedBox(height: 6),
                if (isTyping)
                  _buildTypingIndicator()
                else
                  Text(
                    message,
                    style: AppTypography.chatBubble,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) {
          // Stagger the animation for each dot
          final delay = i * 0.2;
          final animValue = ((typingAnimationValue + delay) % 1.0);
          final opacity = 0.3 + (0.7 * (animValue < 0.5 ? animValue * 2 : (1 - animValue) * 2));
          
          return Container(
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Static version of buddy chat bubble (no animation)
class StaticBuddyChatBubble extends StatelessWidget {
  final String userName;
  final int streak;

  const StaticBuddyChatBubble({
    super.key,
    required this.userName,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return BuddyChatBubble(
      message: AppStrings.getMotivationalMessage(userName, streak),
      isTyping: false,
    );
  }
}
