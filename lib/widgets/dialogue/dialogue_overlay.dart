import 'package:flutter/material.dart';
import 'dart:async';

/// A storybook-style dialogue overlay matching the Duolingo design
/// Character on left, text box on right, progress bar at top
class DialogueOverlay extends StatefulWidget {
  /// List of dialogue sentences to display
  final List<String> dialogues;
  
  /// Character image asset path
  final String characterImage;
  
  /// Character name (optional)
  final String characterName;
  
  /// Callback when all dialogues are complete
  final VoidCallback onComplete;
  
  /// Typing speed in milliseconds per character
  final int typingSpeed;

  const DialogueOverlay({
    super.key,
    required this.dialogues,
    required this.characterImage,
    required this.characterName,
    required this.onComplete,
    this.typingSpeed = 35,
  });

  @override
  State<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends State<DialogueOverlay>
    with TickerProviderStateMixin {
  int _currentDialogueIndex = 0;
  String _displayedText = '';
  bool _isTyping = false;
  Timer? _typingTimer;
  
  late AnimationController _characterPopController;
  late Animation<double> _characterScaleAnimation;
  late Animation<double> _characterFadeAnimation;
  
  late AnimationController _textBoxController;
  late Animation<double> _textBoxAnimation;
  late Animation<Offset> _textBoxSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startEntryAnimation();
  }

  void _initAnimations() {
    // Character pops in with scale overshoot
    _characterPopController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _characterScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _characterPopController,
      curve: Curves.elasticOut,
    ));
    _characterFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _characterPopController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Text box fades and slides in from right
    _textBoxController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _textBoxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textBoxController,
      curve: Curves.easeOut,
    ));
    _textBoxSlideAnimation = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textBoxController,
      curve: Curves.easeOut,
    ));
  }

  void _startEntryAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    _characterPopController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textBoxController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _startTyping();
  }

  void _startTyping() {
    if (_currentDialogueIndex >= widget.dialogues.length) {
      widget.onComplete();
      return;
    }

    setState(() {
      _isTyping = true;
      _displayedText = '';
    });

    final fullText = widget.dialogues[_currentDialogueIndex];
    int charIndex = 0;

    _typingTimer = Timer.periodic(
      Duration(milliseconds: widget.typingSpeed),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (charIndex < fullText.length) {
          setState(() {
            _displayedText = fullText.substring(0, charIndex + 1);
          });
          charIndex++;
        } else {
          timer.cancel();
          setState(() {
            _isTyping = false;
          });
        }
      },
    );
  }

  void _onTap() {
    if (_isTyping) {
      // Skip to end of current dialogue
      _typingTimer?.cancel();
      setState(() {
        _displayedText = widget.dialogues[_currentDialogueIndex];
        _isTyping = false;
      });
    } else {
      // Move to next dialogue
      setState(() {
        _currentDialogueIndex++;
      });
      
      if (_currentDialogueIndex >= widget.dialogues.length) {
        widget.onComplete();
      } else {
        _startTyping();
      }
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _characterPopController.dispose();
    _textBoxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top progress bar with icons
              _buildProgressBar(),
              
              // Main content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          // Character on the left side (bottom aligned)
                          Positioned(
                            left: -109,
                            bottom: constraints.maxHeight * 0.0,
                            child: FadeTransition(
                              opacity: _characterFadeAnimation,
                              child: ScaleTransition(
                                scale: _characterScaleAnimation,
                                alignment: Alignment.bottomCenter,
                                child: _buildCharacter(constraints),
                              ),
                            ),
                          ),
                          
                          // Text box on the right (beside head)
                          Positioned(
                            right: 0,
                            top: constraints.maxHeight * 0.28,
                            left: constraints.maxWidth * 0.42,
                            child: FadeTransition(
                              opacity: _textBoxAnimation,
                              child: SlideTransition(
                                position: _textBoxSlideAnimation,
                                child: _buildTextBox(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              
              // Bottom dots indicator
              _buildDotsIndicator(),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = ((_currentDialogueIndex + 1) / widget.dialogues.length);
    
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 22, bottom: 12),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            return Container(
              width: barWidth,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: barWidth * progress,
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCharacter(BoxConstraints constraints) {
    // No aura/glow - clean image display
    return SizedBox(
      width: constraints.maxWidth * 1.10,
      height: constraints.maxHeight * 1.05,
      child: Image.asset(
        widget.characterImage,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image not found
          return Center(
            child: Container(
              width: 150,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '🧙‍♂️',
                  style: TextStyle(fontSize: 80),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextBox() {
    // Get the full text to maintain consistent box size
    final fullText = widget.dialogues[_currentDialogueIndex];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Invisible full text to maintain box size
          Opacity(
            opacity: 0,
            child: Text(
              fullText,
              style: const TextStyle(
                fontSize: 17,
                height: 1.5,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
                fontFamily: 'Georgia',
                letterSpacing: 0.2,
              ),
            ),
          ),
          // Visible animated text
          Text(
            _displayedText,
            style: const TextStyle(
              fontSize: 17,
              height: 1.5,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
              fontFamily: 'Georgia',
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.dialogues.length, (index) {
        final isActive = index == _currentDialogueIndex;
        final isCompleted = index < _currentDialogueIndex;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? const Color(0xFF9E9E9E)
                : const Color(0xFFD9D9D9),
          ),
        );
      }),
    );
  }
}

/// Animated fractionally sized box for smooth progress bar
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final AlignmentGeometry alignment;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    required this.widthFactor,
    required this.alignment,
    required this.child,
  });

  @override
  ImplicitlyAnimatedWidgetState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends ImplicitlyAnimatedWidgetState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}

/// Blinking cursor widget for typing effect
class _TypingCursor extends StatefulWidget {
  @override
  State<_TypingCursor> createState() => _TypingCursorState();
}

class _TypingCursorState extends State<_TypingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 2,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
    );
  }
}
