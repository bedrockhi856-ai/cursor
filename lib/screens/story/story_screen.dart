import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/supabase_storage_service.dart';
import '../../core/router/app_router.dart';

/// Story narration texts for each frame
const List<String> _storyTexts = [
  'As a Teenager, I saw my father cleaning floors of the station. I really want to give him better life. I hated being poor.',
  'To give my parents a good life I started studying hard to pursue my dream of becoming a lawyer.',
  'I soon found myself procrastinating, bored, and frustrated—wasting time and almost failing my exams.',
  'After years of failing I finally found the lessons hard way.',
  'I went from an undisciplined, inconsistent, and distracted kid to a Laser-Focused, Disciplined Unstoppable man.',
  'The smile on their faces was worth the grind. I can teach you my years of failures in few minutes.',
];

/// Full-screen story viewer with tap-to-advance navigation
class StoryScreen extends StatefulWidget {
  /// If true, navigates to mentor chat after story ends
  final bool isOnboarding;
  
  const StoryScreen({super.key, this.isOnboarding = false});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late List<String> _imageUrls;
  int _currentPage = 0;
  bool _imagesPrefetched = false; // Guard flag
  bool _isTransitioning = false; // Prevent rapid taps

  @override
  void initState() {
    super.initState();
    _imageUrls = SupabaseStorageService.getJhonStoryImages();
    
    // Prefetch all images after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_imagesPrefetched && mounted) {
        _prefetchImages();
        _imagesPrefetched = true;
      }
    });
  }
  
  /// Prefetch all story images to cache
  void _prefetchImages() {
    for (final url in _imageUrls) {
      precacheImage(
        CachedNetworkImageProvider(url),
        context,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _nextPage() {
    if (_isTransitioning) return;
    
    if (_currentPage < _imageUrls.length - 1) {
      setState(() {
        _isTransitioning = true;
        _currentPage++;
      });
      
      // Reset transition flag after animation completes
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) {
          setState(() {
            _isTransitioning = false;
          });
        }
      });
    } else {
      // Story finished
      _onStoryComplete();
    }
  }
  
  void _onStoryComplete() {
    if (widget.isOnboarding) {
      // Navigate to home after onboarding story
      context.go(AppRoutes.home);
    } else {
      // Just go back
      Navigator.of(context).pop();
    }
  }

  void _previousPage() {
    if (_isTransitioning) return;
    
    if (_currentPage > 0) {
      setState(() {
        _isTransitioning = true;
        _currentPage--;
      });
      
      // Reset transition flag after animation completes
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) {
          setState(() {
            _isTransitioning = false;
          });
        }
      });
    }
  }

  void _onTapLeft() {
    HapticFeedback.lightImpact();
    _previousPage();
  }

  void _onTapRight() {
    HapticFeedback.lightImpact();
    _nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image with fade animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Stack(
              key: ValueKey<int>(_currentPage),
              children: [
                _StoryImage(imageUrl: _imageUrls[_currentPage]),
                // Text overlay
                _StoryTextOverlay(text: _storyTexts[_currentPage]),
              ],
            ),
          ),
          
          // Tap zones for navigation
          Positioned.fill(
            child: Row(
              children: [
                // Left tap zone - go back
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _onTapLeft,
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Right tap zone - go forward
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _onTapRight,
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single story image with loading and error states
class _StoryImage extends StatelessWidget {
  final String imageUrl;

  const _StoryImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,  // Cover full screen (9:16)
      width: double.infinity,
      height: double.infinity,
      // Optimize memory by limiting cached image size
      memCacheWidth: 1080,
      fadeInDuration: Duration.zero, // No fade since prefetched
      fadeOutDuration: Duration.zero,
      placeholder: (context, url) => Container(
        color: Colors.black, // Just black screen, no spinner
      ),
      errorWidget: (context, url, error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text overlay with rounded container
class _StoryTextOverlay extends StatelessWidget {
  final String text;
  
  const _StoryTextOverlay({required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
