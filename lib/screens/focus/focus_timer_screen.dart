import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:study_buddy/data/providers/game_provider.dart';
import 'package:study_buddy/widgets/overlays/celebration_overlay.dart';

class FocusTimerScreen extends ConsumerStatefulWidget {
  final int durationMinutes;
  
  const FocusTimerScreen({super.key, required this.durationMinutes});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

enum BreathingPhase { inhale, hold, exhale }

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _breathingController;
  late AnimationController _cycleController;
  late AnimationController _auraController;
  late AnimationController _buttonController;
  late AnimationController _phaseTextController;
  late Animation<double> _scaleAnimation;
  Animation<double>? _buttonScaleAnimationInternal;
  
  Animation<double> get _buttonScaleAnimation => 
      _buttonScaleAnimationInternal ?? const AlwaysStoppedAnimation(1.0);
  
  Timer? _sessionTimer;
  Timer? _phaseTimer;
  Timer? _phaseDelayTimer;
  
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isPaused = false;
  int _breathsCompleted = 0;
  
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _phaseRemainingSeconds = 4;
  
  // Store animation state for resume
  double _pausedAnimationValue = 0.0;
  double _pausedAuraValue = 0.0;
  
  // Background timer handling - track when session should end
  DateTime? _sessionEndTime;
  DateTime? _pausedAt;
  Duration _pausedDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Register as lifecycle observer to handle background/foreground transitions
    WidgetsBinding.instance.addObserver(this);
    
    _remainingSeconds = widget.durationMinutes * 60;
    _totalSeconds = widget.durationMinutes * 60;
    
    // Set the absolute end time for the session
    _sessionEndTime = DateTime.now().add(Duration(seconds: _totalSeconds));
    
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
    
    // Button animation controller for scale feedback
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    // Phase text animation controller
    _phaseTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
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
    
    // Button scale animation for haptic feel
    _buttonScaleAnimationInternal = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeInOut,
      ),
    );
    
    _startBreathingCycle();
    _startSessionTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    _breathingController.dispose();
    _cycleController.dispose();
    _auraController.dispose();
    _buttonController.dispose();
    _phaseTextController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background - record pause time if not already paused
      if (!_isPaused) {
        _pausedAt = DateTime.now();
        // Stop animations to save battery
        _breathingController.stop();
        _auraController.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App coming back to foreground - calculate elapsed time
      _onAppResumed();
    }
  }
  
  void _onAppResumed() {
    if (_sessionEndTime == null) return;
    
    final now = DateTime.now();
    
    // If user had manually paused before backgrounding, just resume animations
    if (_isPaused) {
      // Don't update remaining time - user paused it
      return;
    }
    
    // Calculate how much time passed while in background
    if (_pausedAt != null) {
      final backgroundDuration = now.difference(_pausedAt!);
      _pausedAt = null;
      
      // Update remaining seconds based on actual elapsed time
      final newRemaining = _sessionEndTime!.difference(now).inSeconds;
      
      if (newRemaining <= 0) {
        // Session completed while in background!
        setState(() {
          _remainingSeconds = 0;
        });
        _sessionTimer?.cancel();
        _phaseTimer?.cancel();
        _breathingController.stop();
        _showCompletionDialog();
      } else {
        setState(() {
          _remainingSeconds = newRemaining;
        });
        
        // Resume animations
        _auraController.repeat();
        // Restart breathing cycle fresh
        _startBreathingCycle();
      }
    }
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        // Use timestamp-based calculation for accuracy
        if (_sessionEndTime != null) {
          final now = DateTime.now();
          final newRemaining = _sessionEndTime!.difference(now).inSeconds;
          
          setState(() {
            _remainingSeconds = newRemaining > 0 ? newRemaining : 0;
          });
          
          if (_remainingSeconds <= 0) {
            _sessionTimer?.cancel();
            _phaseTimer?.cancel();
            _breathingController.stop();
            _showCompletionDialog();
          }
        }
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
        setState(() {
          _breathsCompleted++; // Count completed breath cycle
        });
        _startInhalePhase(); // Loop back to inhale
      }
    });
  }

  void _togglePause() async {
    // Add haptic feedback
    HapticFeedback.mediumImpact();
    
    // Animate button press
    await _buttonController.forward();
    await _buttonController.reverse();
    
    if (!_isPaused) {
      // Pausing - save current animation state and pause time
      _pausedAnimationValue = _breathingController.value;
      _pausedAuraValue = _auraController.value;
      _pausedAt = DateTime.now(); // Record when user paused
      _breathingController.stop();
      _auraController.stop();
      _phaseTimer?.cancel();
      _phaseDelayTimer?.cancel();
    } else {
      // Resuming - adjust end time to account for paused duration
      if (_pausedAt != null && _sessionEndTime != null) {
        final pauseDuration = DateTime.now().difference(_pausedAt!);
        _sessionEndTime = _sessionEndTime!.add(pauseDuration);
        _pausedAt = null;
      }
      
      // Resume animations
      _auraController.forward(from: _pausedAuraValue);
      _auraController.repeat();
      
      // Resume breathing animation from where it was
      if (_currentPhase == BreathingPhase.inhale) {
        _breathingController.forward(from: _pausedAnimationValue);
        _restartPhaseTimer(_phaseRemainingSeconds, BreathingPhase.hold);
      } else if (_currentPhase == BreathingPhase.hold) {
        // Hold phase doesn't animate the breathing controller
        _restartPhaseTimer(_phaseRemainingSeconds, BreathingPhase.exhale);
      } else {
        _breathingController.reverse(from: _pausedAnimationValue);
        _restartPhaseTimer(_phaseRemainingSeconds, BreathingPhase.inhale);
      }
    }
    
    setState(() {
      _isPaused = !_isPaused;
    });
  }
  
  void _restartPhaseTimer(int remainingSeconds, BreathingPhase nextPhase) {
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _phaseRemainingSeconds--;
        });
      }
    });
    
    Future.delayed(Duration(seconds: remainingSeconds), () {
      if (mounted && !_isPaused) {
        _phaseTimer?.cancel();
        if (nextPhase == BreathingPhase.hold) {
          _startHoldPhase();
        } else if (nextPhase == BreathingPhase.exhale) {
          _startExhalePhase();
        } else {
          setState(() {
            _breathsCompleted++;
          });
          _startInhalePhase();
        }
      }
    });
  }

  double get _sessionProgress {
    if (_totalSeconds == 0) return 0.0;
    return 1.0 - (_remainingSeconds / _totalSeconds);
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

  Future<void> _showCompletionDialog() async {
    final parentContext = context;
    
    // Calculate focus minutes completed
    final focusMinutes = ((_totalSeconds - _remainingSeconds) / 60).ceil();
    
    // Complete the session and get rewards
    try {
      final gameNotifier = ref.read(gameStateProvider.notifier);
      final result = await gameNotifier.completeSession(
        focusMinutes: focusMinutes > 0 ? focusMinutes : widget.durationMinutes,
        completedSession: true, // Session was completed, not quit early
      );
      
      // Show celebration overlay
      if (parentContext.mounted) {
        showSessionCelebrations(
          parentContext,
          result,
          onComplete: () {
            if (parentContext.mounted) {
              parentContext.pop(); // Go back using GoRouter
            }
          },
        );
      }
    } catch (e) {
      // If gamification fails, just show the simple dialog
      if (parentContext.mounted) {
        showDialog(
          context: parentContext,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Session Complete!'),
            content: const Text('Great job! You\'ve completed your focus session.'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await Future.delayed(const Duration(milliseconds: 100));
                  if (parentContext.mounted) {
                    parentContext.pop();
                  }
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await Future.delayed(const Duration(milliseconds: 50));
                      if (context.mounted) {
                        context.pop();
                      }
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
                  const Spacer(),
                  // Session stats pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.air_rounded,
                          size: 16,
                          color: const Color(0xFFFF6B35),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_breathsCompleted',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF6B35),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Breathing circle with animation
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated breathing circle with rotating colors
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      child: AnimatedBuilder(
                        animation: _auraController,
                        builder: (context, _) {
                          return Transform.rotate(
                            angle: _auraController.value * 2 * math.pi,
                            child: CustomPaint(
                              size: const Size(300, 300),
                              painter: _QuarterBorderPainter(
                                animationValue: _scaleAnimation.value,
                              ),
                            ),
                          );
                        },
                      ),
                      builder: (context, rotatingBorder) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: SizedBox(
                            width: 300,
                            height: 300,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Rotating colored border
                                rotatingBorder!,
                                // White circle background (removed expensive BackdropFilter)
                                Container(
                                  width: 280,
                                  height: 280,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF2F2F2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x0F000000),
                                        blurRadius: 25,
                                        offset: Offset(0, 8),
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
                  // Timer and phase info (static)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Phase indicator with animated text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _currentPhase.name.toUpperCase(),
                          key: ValueKey<BreathingPhase>(_currentPhase),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getPhaseColor().withOpacity(0.8),
                            fontFamily: 'Inter',
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Timer display
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: _remainingSeconds >= 3600 ? 44 : 56,
                          fontWeight: FontWeight.w200,
                          color: const Color(0xFF2C2C2C),
                          fontFamily: 'Inter',
                          letterSpacing: 2,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Phase countdown pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getPhaseColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_phaseRemainingSeconds sec',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _getPhaseColor(),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 3),
            
            // Minimal liquid-fill pause/resume button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: GestureDetector(
                onTap: _togglePause,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.grey[350]!,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(27),
                    child: Stack(
                      children: [
                        // Liquid fill based on session progress
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            width: (MediaQuery.of(context).size.width - 120) * _sessionProgress,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF58CC02).withOpacity(0.6),
                                  const Color(0xFF58CC02).withOpacity(0.8),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                        // Button content
                        Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Row(
                              key: ValueKey<bool>(_isPaused),
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                  color: const Color(0xFF3C3C3C),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isPaused ? 'Resume' : 'Pause',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3C3C3C),
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  Color _getPhaseColor() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return const Color(0xFF4CAF50); // Green for inhale
      case BreathingPhase.hold:
        return const Color(0xFFFF9800); // Orange for hold
      case BreathingPhase.exhale:
        return const Color(0xFF2196F3); // Blue for exhale
    }
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

// Custom painter for session progress ring
class _SessionProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  
  _SessionProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 4.0;
    
    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 2 - math.pi / 2,
          colors: [
            progressColor.withOpacity(0.4),
            progressColor,
            progressColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        progress * 2 * math.pi, // Sweep based on progress
        false,
        progressPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(_SessionProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.progressColor != progressColor;
  }
}
