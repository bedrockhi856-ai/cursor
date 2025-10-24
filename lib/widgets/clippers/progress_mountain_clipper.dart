import 'package:flutter/material.dart';

/// Custom clipper for progressive mountain color reveal
/// Creates an organic mountain-like curve that reveals color from bottom to top
class ProgressMountainClipper extends CustomClipper<Path> {
  final double progress;
  
  ProgressMountainClipper(this.progress);
  
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Calculate clip height from bottom based on progress (0.0 to 1.0)
    final clipHeight = size.height * progress;
    
    // Start from bottom-left corner
    path.moveTo(0, size.height);
    
    // Draw bottom edge
    path.lineTo(size.width, size.height);
    
    // Draw right edge up to clip line
    path.lineTo(size.width, size.height - clipHeight);
    
    // Create organic mountain-like curve for the clip line
    const controlPointOffset = 0.1;
    
    // Add curves to make the clip line look more natural/organic
    for (int i = 4; i >= 0; i--) {
      final x = size.width * (i / 4.0);
      var y = size.height - clipHeight;
      
      // Add some variation to make it look more natural
      final variation = (i % 2 == 0 ? 10.0 : -10.0) * (1 - progress);
      y += variation;
      
      if (i == 4) {
        // Starting point already set above
        continue;
      } else if (i == 0) {
        // End point
        path.lineTo(x, y);
      } else {
        // Control points for smooth curve
        final prevX = size.width * ((i + 1) / 4.0);
        final prevY = size.height - clipHeight + ((i + 1) % 2 == 0 ? 10.0 : -10.0) * (1 - progress);
        
        path.quadraticBezierTo(
          (prevX + x) / 2, 
          (prevY + y) / 2 + variation * 0.5, 
          x, 
          y
        );
      }
    }
    
    // Connect back to bottom-left corner
    path.lineTo(0, size.height);
    
    // Close the path
    path.close();
    
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper is ProgressMountainClipper && oldClipper.progress != progress;
  }
}
