import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../../core/constants/app_constants.dart';

/// Slide to surrender slider with visual feedback
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
    
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final sliderWidth = renderBox.size.width;
    
    setState(() {
      _slideProgress = (localPosition.dx / sliderWidth).clamp(0.0, 1.0);
    });
  }
  
  void _onPanEnd(DragEndDetails details) {
    if (_isCompleted) return;
    
    if (_slideProgress >= 0.85) {
      _completeSlide();
    } else {
      _resetSlide();
    }
    
    setState(() {
      _isDragging = false;
    });
  }
  
  Future<void> _completeSlide() async {
    setState(() {
      _isCompleted = true;
      _slideProgress = 1.0;
    });
    
    // Get slider center position
    final renderBox = context.findRenderObject() as RenderBox;
    final sliderCenterPosition = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height / 2)
    );
    widget.onSliderPosition(sliderCenterPosition);
    
    // Haptic feedback
    await Haptics.vibrate(HapticsType.error);
    
    // Flash animation
    _flashController.forward().then((_) {
      _flashController.reverse();
    });
    
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
        child: SizedBox(
          width: sliderWidth,
          height: sliderHeight,
          child: Stack(
            children: [
              // Background track
              Container(
                width: sliderWidth,
                height: sliderHeight,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(sliderHeight / 2),
                ),
              ),
              
              // Red fill with radial gradient
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
                        gradient: const RadialGradient(
                          center: Alignment.centerLeft,
                          radius: 1.5,
                          colors: [
                            Color(0xFFFF1744), // Bright red center
                            Color(0xFFD32F2F), // Medium red
                            Color(0xFFB71C1C), // Dark red edges
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
                      color: const Color(0xFFFF0000).withOpacity(
                        (_flashAnimation.value * 0.3).clamp(0.0, 1.0)
                      ),
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
                        color: AppColors.white,
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
                          color: AppColors.primaryGold,
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
                  _isCompleted ? AppStrings.surrendered : AppStrings.slideToSurrender,
                  style: TextStyle(
                    fontSize: sliderHeight * 0.35,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    fontFamily: AppFonts.inter,
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
