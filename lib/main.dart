import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/sources/local/hive_service.dart';
import 'core/router/app_router.dart';
import 'core/errors/error_boundary.dart';
import 'core/theme/theme.dart';
import 'core/config/app_config.dart';

void main() async {
  if (kDebugMode) debugPrint('===== APP STARTING =====');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  if (kDebugMode) debugPrint('About to initialize Hive...');
  await HiveService.init();
  if (kDebugMode) debugPrint('Hive initialization returned');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  if (kDebugMode) debugPrint('✅ Supabase initialized');
  
  // Debug: Check if user exists
  if (kDebugMode) {
    final userBox = HiveService.userBox;
    final existingUser = userBox.get('current_user');
    debugPrint('🔍 Existing user on startup: $existingUser');
    debugPrint('🔍 goalSpeedMonths (onboarding data): ${existingUser?.goalSpeedMonths}');
    debugPrint('🔍 Note: onboarding always shown on fresh start (in-memory flag)');
  }
  
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
    // Precache all background images with size limits to reduce memory
    precacheImage(
      const ResizeImage(AssetImage('assets/background/darkphone.jpg'), width: 1080),
      context,
    );
    precacheImage(
      const ResizeImage(AssetImage('assets/background/sunset2.jpg'), width: 1080),
      context,
    );
    precacheImage(
      const ResizeImage(AssetImage('assets/background/color.jpg'), width: 1080),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    return ErrorBoundary(
      onError: (error, stackTrace) {
        // Log errors to analytics or crash reporting service
        debugPrint('🔴 App Error: $error');
        debugPrint('Stack trace: $stackTrace');
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              viewPadding: EdgeInsets.zero,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
