import 'package:flutter/material.dart';
import 'onboarding_screens.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache all background images to prevent loading jank
    _precacheImages();
  }

  void _precacheImages() {
    // Precache all background images used in the app
    precacheImage(const AssetImage('assets/background/darkphone.jpg'), context);
    precacheImage(const AssetImage('assets/background/sunset2.jpg'), context);
    precacheImage(const AssetImage('assets/background/no_color.jpg'), context);
    precacheImage(const AssetImage('assets/background/color.jpg'), context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const AgeScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            viewPadding: EdgeInsets.zero,
          ),
          child: child!,
        );
      },
    );
  }
}
