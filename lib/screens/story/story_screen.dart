import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/supabase_storage_service.dart';
import '../../core/router/app_router.dart';

/// Full-screen story viewer with tap-to-advance navigation
class StoryScreen extends StatefulWidget {
  /// If true, navigates to mentor chat after story ends
  final bool isOnboarding;
  
  const StoryScreen({super.key, this.isOnboarding = false});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late List<String> _imageUrls;
  int _currentPage = 0;
  
  // Progress animation
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _imageUrls = SupabaseStorageService.getJhonStoryImages();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Auto-advance after 5 seconds
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextPage();
      }
    });
    
    _startProgress();
    
    // Prefetch all images for faster loading
    _prefetchImages();
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
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward();
  }

  void _nextPage() {
    if (_currentPage < _imageUrls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Story finished
      _onStoryComplete();
    }
  }
  
  void _onStoryComplete() {
    if (widget.isOnboarding) {
      // Navigate to mentor chat
      context.go(AppRoutes.onboardingMentor);
    } else {
      // Just go back
      Navigator.of(context).pop();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _startProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _imageUrls.length,
            itemBuilder: (context, index) {
              return _StoryImage(imageUrl: _imageUrls[index]);
            },
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
          
          // Progress indicators at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: List.generate(_imageUrls.length, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: _buildProgressBar(index),
                    ),
                  ),
                );
              }),
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

  Widget _buildProgressBar(int index) {
    if (index < _currentPage) {
      // Completed - full
      return Container(color: Colors.white);
    } else if (index == _currentPage) {
      // Current - animated
      return AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _progressController.value,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          );
        },
      );
    } else {
      // Upcoming - empty
      return Container(color: Colors.white.withOpacity(0.3));
    }
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
      placeholder: (context, url) => Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
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
