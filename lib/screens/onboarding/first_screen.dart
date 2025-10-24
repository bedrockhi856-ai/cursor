import 'package:flutter/material.dart';
import 'second_screen.dart';
import '../../widgets/buttons/hold_to_begin_button.dart';

class FirstScreen extends StatefulWidget {
  final int? regainableYears;
  const FirstScreen({super.key, this.regainableYears});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> with TickerProviderStateMixin {
  bool isSwitchOn = false;
  late AnimationController _headingController;
  late AnimationController _switchController;
  late AnimationController _backgroundController;
  late AnimationController _holdController;
  
  late Animation<double> _headingAnimation;
  late Animation<double> _switchAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _holdAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _headingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _switchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _holdController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _headingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headingController,
      curve: Curves.easeOut,
    ));
    
    _switchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _holdAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _holdController,
      curve: Curves.easeInOut,
    ));
    
    _headingController.forward();
    _holdController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _headingController.dispose();
    _switchController.dispose();
    _backgroundController.dispose();
    _holdController.dispose();
    super.dispose();
  }
  
  void onHoldComplete() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SecondScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int regainYears = widget.regainableYears ?? 3;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _headingAnimation,
          _switchAnimation,
          _backgroundAnimation,
          _holdAnimation,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/background/darkphone.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity((0.4 + (0.1 * _backgroundAnimation.value)).clamp(0.0, 1.0)),
                  BlendMode.darken,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    AnimatedOpacity(
                      opacity: _headingAnimation.value,
                      duration: const Duration(milliseconds: 600),
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _headingAnimation.value)),
                        child: Text(
                          'Want to regain $regainYears years\nof your life?',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inter',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  isSwitchOn ? Icons.lock_open : Icons.lock,
                                  key: ValueKey(isSwitchOn),
                                  size: 28,
                                  color: isSwitchOn ? Colors.green[600] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Freedom Switch',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    Text(
                                      'Turn ON to unlock your potential',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSwitchOn = !isSwitchOn;
                                  });
                                  if (isSwitchOn) {
                                    _switchController.forward();
                                    _backgroundController.forward();
                                  } else {
                                    _switchController.reverse();
                                    _backgroundController.reverse();
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 48,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSwitchOn ? Colors.green[600] : Colors.grey[600],
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isSwitchOn ? Colors.green[600] : Colors.grey[600])!.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 300),
                                    alignment: isSwitchOn ? Alignment.centerRight : Alignment.centerLeft,
                                    curve: Curves.easeOutBack,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      margin: EdgeInsets.only(
                                        left: isSwitchOn ? 22 : 2,
                                        right: isSwitchOn ? 2 : 22,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: HoldToBeginButton(
                        onHoldComplete: onHoldComplete,
                        text: 'hold',
                        buttonColor: const Color(0xFFFF6B35),
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
