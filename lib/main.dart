import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/sources/local/hive_service.dart';
import 'core/router/app_router.dart';

void main() async {
  debugPrint('===== APP STARTING =====');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  debugPrint('About to initialize Hive...');
  await HiveService.init();
  debugPrint('Hive initialization returned');
  
  // Debug: Check if user exists
  final userBox = HiveService.userBox;
  final existingUser = userBox.get('current_user');
  debugPrint('🔍 Existing user on startup: $existingUser');
  debugPrint('🔍 Onboarding complete: ${existingUser?.onboardingCompleted}');
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache all background images to prevent loading jank
    if (!_imagesPrecached) {
      _precacheImages();
      _imagesPrecached = true;
    }
  }

  void _precacheImages() {
    // Precache all background images used in the app
    precacheImage(const AssetImage('assets/background/darkphone.jpg'), context);
    precacheImage(const AssetImage('assets/background/sunset2.jpg'), context);
    precacheImage(const AssetImage('assets/background/color.jpg'), context);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      routerConfig: router,
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
