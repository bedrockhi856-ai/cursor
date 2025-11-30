import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class TimerSetupScreen extends StatefulWidget {
  const TimerSetupScreen({super.key});

  @override
  State<TimerSetupScreen> createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> {
  Duration _selectedDuration = const Duration(minutes: 25);
  
  final List<int> presetMinutes = [25, 40, 60, 90];
  
  // Scroll controllers for the pickers
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(
      initialItem: _selectedDuration.inHours,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedDuration.inMinutes % 60,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void setPresetMinutes(int minutes) {
    setState(() {
      _selectedDuration = Duration(minutes: minutes);
    });
    
    // Animate the wheels to the selected time with smooth animation
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    _hourController.animateToItem(
      hours,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
    
    _minuteController.animateToItem(
      mins,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 50));
                      if (context.mounted) context.pop();
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Set Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44), // Balance the back button
                ],
              ),
            ),
            
            // Title below header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'How long do you want\nto focus?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Georgia',
                  height: 1.3,
                ),
              ),
            ),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // iOS-style Timer Picker with custom hour limit
                  Transform.translate(
                    offset: const Offset(15, 0),
                    child: Center(
                      child: SizedBox(
                        height: 220,
                        width: 340,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Hours picker
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: _hourController,
                                itemExtent: 32,
                                onSelectedItemChanged: (int value) {
                                  setState(() {
                                    _selectedDuration = Duration(
                                      hours: value,
                                      minutes: _selectedDuration.inMinutes % 60,
                                    );
                                  });
                                },
                                children: List<Widget>.generate(7, (int index) {
                                  return Center(
                                    child: Text(
                                      '$index',
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const Text(
                              'hours',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 20),
                            // Minutes picker
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: _minuteController,
                                itemExtent: 32,
                                onSelectedItemChanged: (int value) {
                                  setState(() {
                                    _selectedDuration = Duration(
                                      hours: _selectedDuration.inHours,
                                      minutes: value,
                                    );
                                  });
                                },
                                children: List<Widget>.generate(60, (int index) {
                                  return Center(
                                    child: Text(
                                      '$index',
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const Text(
                              'min',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Preset buttons - Material Design 3 style
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Text(
                          'Quick presets',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: presetMinutes.map((minutes) {
                            bool isSelected = _selectedDuration.inMinutes == minutes;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => setPresetMinutes(minutes),
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? const Color(0xFFFFD12A)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFFFD12A)
                                            : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected ? [
                                        BoxShadow(
                                          color: const Color(0xFFFFD12A).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ] : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${minutes} min',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected 
                                            ? Colors.white 
                                            : Colors.grey[800],
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.1,
                                      ),
                                    ),
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
                onTap: () async {
                  if (_selectedDuration.inMinutes == 0) return;
                  
                  // Wait for gesture to complete
                  await Future.delayed(const Duration(milliseconds: 100));
                  if (!mounted) return;
                  
                  // Use GoRouter push for navigation
                  context.push(
                    '${AppRoutes.focusTimer}?duration=${_selectedDuration.inMinutes}',
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD12A),
                    borderRadius: BorderRadius.circular(30), // Matching AgeScreen rounded style
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Start Focus Session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




