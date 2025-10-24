import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/sliders/slide_to_act_slider.dart';
import '../../widgets/overlays/fail_screen_overlay.dart';

class FocusTimerScreen extends StatefulWidget {
  final int durationMinutes;
  
  const FocusTimerScreen({super.key, required this.durationMinutes});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _showFailScreen = false;
  Offset? _sliderPosition;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _totalSeconds = widget.durationMinutes * 60;
    
    // Pulse animation for focus effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseController.repeat(reverse: true);
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
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
        } else {
          _timer.cancel();
          _isRunning = false;
          _pulseController.stop();
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
                  
                  // Enhanced circular progress bar with timer inside and pulse animation
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFFD700).withOpacity(0.3 * _pulseAnimation.value),
                                  blurRadius: 30,
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
                                    value: 1.0 - (_remainingSeconds / _totalSeconds),
                                    strokeWidth: 12,
                                    backgroundColor: Colors.grey.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                                  ),
                                ),
                                
                                // Timer display in center
                                Text(
                                  _formatTime(_remainingSeconds),
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontFamily: 'Inter',
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 10,
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
