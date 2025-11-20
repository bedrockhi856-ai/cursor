import 'package:flutter/material.dart';
import 'focus_timer_screen.dart';

class TimerSetupScreen extends StatefulWidget {
  const TimerSetupScreen({super.key});

  @override
  State<TimerSetupScreen> createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> with SingleTickerProviderStateMixin {
  int timerMinutes = 25;
  final TextEditingController _timerController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<int> presetMinutes = [5, 15, 25, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    _timerController.text = timerMinutes.toString();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void incrementTimer() {
    setState(() {
      timerMinutes++;
      _timerController.text = timerMinutes.toString();
    });
  }

  void decrementTimer() {
    setState(() {
      if (timerMinutes > 1) {
        timerMinutes--;
        _timerController.text = timerMinutes.toString();
      }
    });
  }

  void setPresetMinutes(int minutes) {
    setState(() {
      timerMinutes = minutes;
      _timerController.text = timerMinutes.toString();
    });
  }

  void _showCustomTimerDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Custom Timer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _timerController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Color(0xFF6366F1),
                  ),
                  decoration: InputDecoration(
                    hintText: '25',
                    hintStyle: TextStyle(
                      color: Colors.grey[300],
                    ),
                    suffixText: 'min',
                    suffixStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontFamily: 'Inter',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                  onChanged: (value) {
                    int? newValue = int.tryParse(value);
                    if (newValue != null && newValue > 0) {
                      timerMinutes = newValue;
                    }
                  },
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _timerController.text = timerMinutes.toString();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          int? newValue = int.tryParse(_timerController.text);
                          if (newValue != null && newValue > 0) {
                            setState(() {
                              timerMinutes = newValue;
                            });
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Set Timer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Focus Timer',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 44), // Balance the back button
                    ],
                  ),
                ),
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        'How long do you want\nto focus?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Timer Display Circle
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: _showCustomTimerDialog,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$timerMinutes',
                                        style: TextStyle(
                                          fontSize: 72,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'minutes',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // +/- Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Minus button
                          GestureDetector(
                            onTap: decrementTimer,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 80),
                          
                          // Plus button
                          GestureDetector(
                            onTap: incrementTimer,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Preset buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 12),
                              child: Text(
                                'Quick Select',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: presetMinutes.map((minutes) {
                                bool isSelected = timerMinutes == minutes;
                                return GestureDetector(
                                  onTap: () => setPresetMinutes(minutes),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Colors.white 
                                          : Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      '${minutes}m',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected 
                                            ? Color(0xFF6366F1) 
                                            : Colors.white,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Start button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              FocusTimerScreen(durationMinutes: timerMinutes),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: Duration(milliseconds: 400),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Start Focus Session',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF6366F1),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
