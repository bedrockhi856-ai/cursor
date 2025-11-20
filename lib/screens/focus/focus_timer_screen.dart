import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class FocusTimerScreen extends StatefulWidget {
  final int durationMinutes;
  
  const FocusTimerScreen({super.key, required this.durationMinutes});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

enum BreathingPhase { inhale, hold, exhale }

class _FocusTimerScreenState extends State<FocusTimerScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _cycleController;
  late AnimationController _auraController;
  late Animation<double> _scaleAnimation;
  
  Timer? _sessionTimer;
  Timer? _phaseTimer;
  
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isPaused = false;
  
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _phaseRemainingSeconds = 4;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _totalSeconds = widget.durationMinutes * 60;
    
    // Breathing animation controller (4 seconds per phase)
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // Cycle controller for continuous animation
    _cycleController = AnimationController(
      duration: const Duration(seconds: 25), // Full cycle: 4+7+8+6
      vsync: this,
    );
    
    // Aura rotation controller for gentle color shifting
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
    
    // Scale animation with smooth easing (14% expansion from min to max)
    _scaleAnimation = Tween<double>(
      begin: 0.86,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );
    
    _startBreathingCycle();
    _startSessionTimer();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    _breathingController.dispose();
    _cycleController.dispose();
    _auraController.dispose();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _sessionTimer?.cancel();
            _phaseTimer?.cancel();
            _breathingController.stop();
            _showCompletionDialog();
          }
        });
      }
    });
  }

  void _startBreathingCycle() {
    _startInhalePhase();
  }

  void _startInhalePhase() {
    setState(() {
      _currentPhase = BreathingPhase.inhale;
      _phaseRemainingSeconds = 4;
    });
    
    _breathingController.duration = const Duration(seconds: 4);
    _breathingController.forward(from: 0);
    
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _phaseRemainingSeconds--;
      });
    });
    
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_isPaused) {
        _phaseTimer?.cancel();
        _startHoldPhase();
      }
    });
  }

  void _startHoldPhase() {
    setState(() {
      _currentPhase = BreathingPhase.hold;
      _phaseRemainingSeconds = 7;
    });
    
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _phaseRemainingSeconds--;
      });
    });
    
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted && !_isPaused) {
        _phaseTimer?.cancel();
        _startExhalePhase();
      }
    });
  }

  void _startExhalePhase() {
    setState(() {
      _currentPhase = BreathingPhase.exhale;
      _phaseRemainingSeconds = 8;
    });
    
    _breathingController.duration = const Duration(seconds: 8);
    _breathingController.reverse(from: 1.0);
    
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _phaseRemainingSeconds--;
      });
    });
    
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && !_isPaused) {
        _phaseTimer?.cancel();
        _startInhalePhase(); // Loop back to inhale
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _breathingController.stop();
      _auraController.stop();
      _phaseTimer?.cancel();
    } else {
      // Resume from current phase
      _auraController.repeat();
      if (_currentPhase == BreathingPhase.inhale) {
        _startInhalePhase();
      } else if (_currentPhase == BreathingPhase.hold) {
        _startHoldPhase();
      } else {
        _startExhalePhase();
      }
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      // Show hours:minutes:seconds for sessions >= 1 hour
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      // Show minutes:seconds for sessions < 1 hour
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  String get _breathingInstruction {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Inhale through your nose';
      case BreathingPhase.hold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Exhale through your mouth';
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: const Text('Great job! You\'ve completed your focus session.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match app design
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Focus Session',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Breathing circle with animation
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated breathing circle with rotating colors
                  AnimatedBuilder(
                    animation: Listenable.merge([_scaleAnimation, _auraController]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 300,
                          height: 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotating colored border
                              Transform.rotate(
                                angle: _auraController.value * 2 * math.pi,
                                child: CustomPaint(
                                  size: const Size(300, 300),
                                  painter: _QuarterBorderPainter(
                                    animationValue: _scaleAnimation.value,
                                  ),
                                ),
                              ),
                              // White circle background
                              Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
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
                  // Static timer (doesn't scale or rotate)
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: _remainingSeconds >= 3600 ? 48 : 64,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF2C2C2C),
                      fontFamily: 'Inter',
                      letterSpacing: 2,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Breathing instruction text
            Text(
              _breathingInstruction,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Phase duration
            Text(
              '($_phaseRemainingSeconds sec)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Inter',
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 1.0 - (_remainingSeconds / _totalSeconds),
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                  minHeight: 6,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Timer display
            Text(
              _formatTime(_remainingSeconds),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Pause button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: GestureDetector(
                onTap: _togglePause,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isPaused ? 'Resume' : 'Pause',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
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
}

// Custom painter for 4-quarter colored border with subtle aura
class _QuarterBorderPainter extends CustomPainter {
  final double animationValue;

  _QuarterBorderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 6.0 + (2.0 * animationValue); // Border thickness increases with breathing

    // Define 4 pastel colors for each quarter
    final colors = [
      const Color(0xFFFFC8DC), // Soft pink (top-right)
      const Color(0xFFFFE6B3), // Soft yellow (bottom-right)
      const Color(0xFFC8FFD1), // Soft mint (bottom-left)
      const Color(0xFFD6E0FF), // Soft blue (top-left)
    ];

    // Draw each quarter arc with aura layers
    for (int i = 0; i < 4; i++) {
      final color = colors[i];
      
      // Calculate start and sweep angles for each quarter
      // Start from top (270 degrees) and go clockwise
      final startAngle = (math.pi * 1.5) + (i * math.pi / 2); // -90° + (i * 90°)
      final sweepAngle = math.pi / 2; // 90 degrees
      
      // Outer aura layer (most diffused)
      final auraPaint1 = Paint()
        ..color = color.withOpacity(0.15 + (0.15 * animationValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 16
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        auraPaint1,
      );
      
      // Middle aura layer
      final auraPaint2 = Paint()
        ..color = color.withOpacity(0.3 + (0.25 * animationValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        auraPaint2,
      );
      
      // Inner aura layer
      final auraPaint3 = Paint()
        ..color = color.withOpacity(0.5 + (0.3 * animationValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        auraPaint3,
      );

      // Main solid border
      final mainPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        mainPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_QuarterBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
