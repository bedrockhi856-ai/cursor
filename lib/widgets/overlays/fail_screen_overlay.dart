import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Displays failure screen with ripple animation from slider position
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
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
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
    
    _rippleController.forward().then((_) {
      if (mounted) {
        _textController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _buttonController.forward();
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
        return SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            children: [
              // Red ripple effect
              Positioned(
                left: widget.sliderPosition.dx - 30,
                top: widget.sliderPosition.dy - 30,
                child: Transform.scale(
                  scale: 1.0 + (_rippleAnimation.value * 50.0),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error.withOpacity(1.0),
                    ),
                  ),
                ),
              ),
              
              Column(
                children: [
                  const Spacer(),
                  
                  // Main text
                  Transform.scale(
                    scale: _textAnimation.value.clamp(0.0, 2.0),
                    child: Opacity(
                      opacity: _textAnimation.value.clamp(0.0, 1.0),
                      child: Text(
                        AppStrings.betterLuckNextTime,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                          fontFamily: AppFonts.inter,
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
                  
                  // Continue button
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
                            onPressed: widget.onComplete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.darkRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                            ),
                            child: Text(
                              AppStrings.continueButton,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.inter,
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
