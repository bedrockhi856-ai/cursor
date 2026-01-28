import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for interacting with Supabase Storage
/// Used for fetching story images from the CDN
class SupabaseStorageService {
  static final _storage = Supabase.instance.client.storage;
  
  /// Default bucket for story images
  static const String _storyBucket = 'studybuddy';
  
  /// Get URLs for jhon story images (6 frames)
  static List<String> getJhonStoryImages() {
    final urls = List.generate(6, (index) {
      final frameNumber = index + 1;
      return getImageUrl('jhon_web/jhon_${frameNumber}_result.webp');
    });
    
    // Debug: Print URLs to verify they're correct
    if (kDebugMode) {
      debugPrint('📸 Story image URLs:');
      for (final url in urls) {
        debugPrint('  → $url');
      }
    }
    
    return urls;
  }
  
  /// Get public URL for an image (includes CDN)
  /// [path] - The path to the image in the bucket (e.g., 'story_001/frame_01.jpg')
  static String getImageUrl(String path) {
    return _storage.from(_storyBucket).getPublicUrl(path);
  }
  
  /// Get all images in a story folder
  /// Returns a list of public URLs for all images in the story
  static Future<List<String>> getStoryImages(String storyId) async {
    try {
      final files = await _storage
          .from(_storyBucket)
          .list(path: storyId);
      
      // Sort files by name to ensure correct order
      files.sort((a, b) => a.name.compareTo(b.name));
      
      return files
          .where((file) => _isImageFile(file.name))
          .map((file) => getImageUrl('$storyId/${file.name}'))
          .toList();
    } catch (e) {
      throw StorageException('Failed to fetch story images: $e');
    }
  }
  
  /// Get a list of all available stories
  static Future<List<String>> getAvailableStories() async {
    try {
      final folders = await _storage
          .from(_storyBucket)
          .list();
      
      // Filter to only include folders (stories)
      return folders
          .where((item) => item.id == null) // Folders don't have an id
          .map((folder) => folder.name)
          .toList();
    } catch (e) {
      throw StorageException('Failed to fetch stories: $e');
    }
  }
  
  /// Check if a file is an image based on extension
  static bool _isImageFile(String fileName) {
    final extensions = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
    final lowerName = fileName.toLowerCase();
    return extensions.any((ext) => lowerName.endsWith(ext));
  }
}

/// Custom exception for storage errors
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}
