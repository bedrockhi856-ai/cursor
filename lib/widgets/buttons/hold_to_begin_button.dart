import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A button that requires the user to hold for 2 seconds
/// Features expanding blob effect and glow animation
class HoldToBeginButton extends StatefulWidget {
  final VoidCallback onHoldComplete;
  final String text;
  final Color buttonColor;
  final double width;
  final double height;

  const HoldToBeginButton({
    super.key,
    required this.onHoldComplete,
    this.text = 'hold',
    this.buttonColor = const Color(0xFFFF6B35),
    this.width = 120,
    this.height = 60,
  });

  @override
  State<HoldToBeginButton> createState() => _HoldToBeginButtonState();
}

class _HoldToBeginButtonState extends State<HoldToBeginButton>
    with TickerProviderStateMixin {
  late AnimationController _holdController;
  late AnimationController _expandController;
  late AnimationController _glowController;
  late AnimationController _rippleController;
  
  late Animation<double> _holdAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isHolding = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    
    _holdController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _holdAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_holdController);
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeInOut),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerExpand();
      }
    });

    // Start ripple animation on loop
    _rippleController.repeat();
  }

  void _triggerExpand() {
    setState(() {
      _isCompleted = true;
    });
    widget.onHoldComplete();
  }

  @override
  void dispose() {
    _holdController.dispose();
    _expandController.dispose();
    _glowController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _startHold() {
    setState(() {
      _isHolding = true;
    });
    _holdController.forward();
    _glowController.forward();
  }

  void _stopHold() {
    setState(() {
      _isHolding = false;
    });
    _holdController.reset();
    _glowController.stop();
    _glowController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _rippleAnimation,
        builder: (context, _) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Ripple 1 (constant)
                _buildRipple(0.0, 0.5, false),
                
                // Ripple 2 (constant)
                _buildRipple(0.35, 0.5, false),
                
                // Ripple 3 (constant)
                _buildRipple(0.7, 0.5, false),
                
                // Hold ripples (larger, only when holding)
                if (_isHolding) ...[
                  _buildRipple(0.0, 2.5, true),
                  _buildRipple(0.25, 2.5, true),
                  _buildRipple(0.5, 2.5, true),
                  _buildRipple(0.75, 2.5, true),
                ],
                
                // Screen-filling circular glow while holding
                if (_isHolding)
                  AnimatedBuilder(
                    animation: _holdAnimation,
                    builder: (context, _) {
                      return Positioned(
                        left: -(MediaQuery.of(context).size.width * 2),
                        right: -(MediaQuery.of(context).size.width * 2),
                        top: -(MediaQuery.of(context).size.height * 2),
                        bottom: -(MediaQuery.of(context).size.height * 2),
                        child: Transform.scale(
                          scale: _holdAnimation.value * 3.0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                (0.3 * _holdAnimation.value).clamp(0.0, 1.0)
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                
                // Small glow aura while holding
                if (_isHolding)
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, _) {
                      return Positioned(
                        left: -(widget.width * 0.25),
                        right: -(widget.width * 0.25),
                        top: -(widget.height * 0.25),
                        bottom: -(widget.height * 0.25),
                        child: Transform.scale(
                          scale: 1.0 + (_glowAnimation.value * 0.3),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                (0.2 * _glowAnimation.value).clamp(0.0, 1.0)
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              
              // Main button
              GestureDetector(
                onTapDown: (_) => _startHold(),
                onTapUp: (_) => _stopHold(),
                onTapCancel: () => _stopHold(),
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: widget.buttonColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.buttonColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/illustrations/fingerprint.svg',
                      width: widget.width * 0.5,
                      height: widget.height * 0.5,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      ),
    );
  }

  Widget _buildRipple(double delay, double maxScale, bool isHoldRipple) {
    // Calculate the ripple animation value based on delay
    double rippleValue = (_rippleAnimation.value + delay) % 1.0;
    
    // Use stronger opacity for hold ripples
    final baseOpacity = isHoldRipple ? 0.4 : 0.3;
    
    return Positioned(
      left: -(widget.width * maxScale),
      right: -(widget.width * maxScale),
      top: -(widget.height * maxScale),
      bottom: -(widget.height * maxScale),
      child: Transform.scale(
        scale: 1.0 + (rippleValue * maxScale),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isHoldRipple 
              ? Border.all(
                  color: widget.buttonColor.withOpacity(
                    (baseOpacity * (1.0 - rippleValue)).clamp(0.0, 1.0)
                  ),
                  width: 2.5,
                )
              : null,
            color: isHoldRipple 
              ? null
              : widget.buttonColor.withOpacity(
                  (baseOpacity * (1.0 - rippleValue)).clamp(0.0, 1.0)
                ),
          ),
        ),
      ),
    );
  }
}
