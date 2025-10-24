import 'package:flutter/material.dart';

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
  
  late Animation<double> _holdAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _glowAnimation;
  
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

    _holdAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_holdController);
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerExpand();
      }
    });
  }

  void _triggerExpand() {
    setState(() {
      _isCompleted = true;
    });
    _expandController.forward().then((_) {
      widget.onHoldComplete();
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    _expandController.dispose();
    _glowController.dispose();
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
    return AnimatedBuilder(
      animation: Listenable.merge([
        _holdAnimation,
        _expandAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Expanding blob effect (covers most of screen)
            if (_isCompleted)
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.0 + (_expandAnimation.value * 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.buttonColor.withOpacity(
                        (0.8 * _expandAnimation.value).clamp(0.0, 1.0)
                      ),
                    ),
                  ),
                ),
              ),
            
            // Glow aura while holding
            if (_isHolding)
              Transform.scale(
                scale: 1.0 + (_glowAnimation.value * 0.3),
                child: Container(
                  width: widget.width * 1.5,
                  height: widget.height * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.buttonColor.withOpacity(
                      (0.2 * _glowAnimation.value).clamp(0.0, 1.0)
                    ),
                  ),
                ),
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
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
