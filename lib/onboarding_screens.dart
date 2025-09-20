import 'package:flutter/material.dart';
import 'main.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({Key? key}) : super(key: key);

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> with TickerProviderStateMixin {
  String age = '';
  final TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    
    // Auto-focus the age input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                                 child: Text(
                   'What is your age?',
                   textAlign: TextAlign.center,
                   style: TextStyle(
                    fontSize: 32,
                     fontWeight: FontWeight.w600,
                     fontFamily: 'Inter',
                     color: Colors.black,
                   ),
                 ),
              ),
              const SizedBox(height: 100),
              Center(
                child: Container(
                  width: 120,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                                             style: const TextStyle(
                         fontSize: 24,
                         fontWeight: FontWeight.bold,
                         color: Colors.black,
                         fontFamily: 'Inter',
                       ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '00',
                                                 hintStyle: TextStyle(
                           color: Colors.black54,
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                         ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        setState(() {
                          age = val;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                child: AnimatedBuilder(
                  animation: _buttonAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonAnimation.value,
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD12A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                            shadowColor: Colors.black.withValues(alpha: 0.2),
                          ),
                          onPressed: age.isNotEmpty ? () {
                            _buttonController.forward().then((_) {
                              _buttonController.reverse();
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => PhoneUsageScreen(age: age),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                      )),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              );
                            });
                          } : null,
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class PhoneUsageScreen extends StatefulWidget {
  final String age;
  const PhoneUsageScreen({Key? key, required this.age}) : super(key: key);

  @override
  State<PhoneUsageScreen> createState() => _PhoneUsageScreenState();
}

class _PhoneUsageScreenState extends State<PhoneUsageScreen> with TickerProviderStateMixin {
  int selected = 1;
  final List<String> options = [
    '1–2 Hours',
    '2–3 Hours',
    '3–4 Hours',
    '4–5 Hours',
  ];
  
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            const SizedBox(height: 40), // Much smaller top spacing
               const Padding(
                 padding: EdgeInsets.symmetric(horizontal: 24.0),
                 child: Text(
                   'How much time do you spend on your phone?',
                   textAlign: TextAlign.center,
                   style: TextStyle(
                     fontSize: 28,
                     fontWeight: FontWeight.w600,
                     fontFamily: 'Inter',
                     color: Colors.black,
                   ),
                 ),
               ),
            const SizedBox(height: 30), // Balanced spacing
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(options.length, (i) => _buildOption(i)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: AnimatedBuilder(
                animation: _buttonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonAnimation.value,
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD12A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                        ),
                        onPressed: () {
                          _buttonController.forward().then((_) {
                            _buttonController.reverse();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => ProfessionalResultScreen(
                                  age: widget.age,
                                  usageIndex: selected,
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    )),
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                              ),
                            );
                          });
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildOption(int i) {
    final bool isSelected = selected == i;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selected = i;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF8E1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFD12A) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFFFFD12A).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Transform.scale(
              scale: isSelected ? 1.05 : 1.0,
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class ProfessionalResultScreen extends StatefulWidget {
  final String age;
  final int usageIndex;
  ProfessionalResultScreen({Key? key, required this.age, required this.usageIndex}) : super(key: key);

  final List<double> avgHours = [1.5, 2.5, 3.5, 4.5];

  @override
  State<ProfessionalResultScreen> createState() => _ProfessionalResultScreenState();
}

class _ProfessionalResultScreenState extends State<ProfessionalResultScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _headingController;
  late AnimationController _cardController;
  late AnimationController _subtextController;
  late AnimationController _floatingController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _headingAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _subtextAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Button animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Heading fade in animation
    _headingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Card pop-in animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Subtext fade in animation
    _subtextController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Floating animation for illustration
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: 8.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _headingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headingController,
      curve: Curves.easeOut,
    ));
    
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));
    
    _subtextAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _subtextController,
      curve: Curves.easeOut,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _headingController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _subtextController.forward();
    });
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headingController.dispose();
    _cardController.dispose();
    _subtextController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int ageInt = int.tryParse(widget.age) ?? 0;
    double hoursPerDay = widget.avgHours[widget.usageIndex];
    int years = 75 - ageInt;
    double totalUnproductiveYears = (hoursPerDay * 365 * years) / 24 / 365;
    String resultStr = totalUnproductiveYears.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _headingAnimation,
          _cardAnimation,
          _subtextAnimation,
          _floatingAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Main heading - fade in from top
              Positioned(
                top: 96,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _headingAnimation.value.clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 500),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _headingAnimation.value)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'This is how much time\nyou might lose',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Color(0xFF1F2937), // Dark navy
                            height: 1.3,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Main illustration - floating animation
              Positioned(
                top: 240 + (8 * _floatingAnimation.value),
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 320,
                    height: 300,
                    child: Image.asset(
                      'assets/illustrations/sad2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
          
              // White rounded card with years - pop-in animation
              Positioned(
                top: 584,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _cardAnimation.value.clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 600),
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * _cardAnimation.value),
                    child: Center(
                      child: Container(
                        width: 260,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$resultStr years',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Inter',
                              color: const Color(0xFFFF7A00),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          
              // Subtext - fade in with delay
              Positioned(
                top: 696,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _subtextAnimation.value.clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 400),
                  child: Center(
                    child: Text(
                      'Spent Unproductively',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: const Color(0xFF1E1E1E),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
          


              // Yellow button with gradient and ripple effect
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color(0xFFFFD12A),
                          boxShadow: [
                            BoxShadow(
                                                             color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTapDown: (_) => _animationController.forward(),
                            onTapUp: (_) => _animationController.reverse(),
                            onTapCancel: () => _animationController.reverse(),
                            onTap: () {
                              final regainableYears = getRegainableYears(double.tryParse(resultStr) ?? 0);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => FirstScreen(regainableYears: regainableYears)),
                              );
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const SecondScreen()),
                                );
                              });
                            },
                            child: Center(
                              child: Text(
                                'I want my time back',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}