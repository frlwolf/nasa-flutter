import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/apod_item.dart';

class ApodImage extends StatelessWidget {
  final ApodItem item;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool showVideoIndicator;
  final bool showCopyright;

  const ApodImage({
    super.key,
    required this.item,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showVideoIndicator = true,
    this.showCopyright = true,
  });

  @override
  Widget build(BuildContext context) {
    // Handle video content
    if (item.mediaType == 'video') {
      return _buildVideoPlaceholder(context);
    }

    // Handle image content
    return _buildImageWidget(context);
  }

  Widget _buildImageWidget(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: item.url,
              fit: fit,
              placeholder: (context, url) => _buildLoadingPlaceholder(context),
              errorWidget: (context, url, error) => _buildErrorPlaceholder(context),
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 300),
            ),
            
            // Copyright overlay
            if (showCopyright && item.copyright != null)
              _buildCopyrightOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_filled,
                  size: 64,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 8),
                Text(
                  'Video Content',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Copyright overlay for videos
          if (showCopyright && item.copyright != null)
            _buildCopyrightOverlay(context),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading image...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.grey[300],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyrightOverlay(BuildContext context) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '© ${item.copyright}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// High-resolution image widget for detail screens
class ApodImageHD extends StatelessWidget {
  final ApodItem item;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ApodImageHD({
    super.key,
    required this.item,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Use HD URL if available, otherwise fall back to regular URL
    final imageUrl = item.hdurl ?? item.url;
    
    if (item.mediaType == 'video') {
      return ApodImage(
        item: item,
        height: height,
        width: width,
        fit: fit,
        borderRadius: borderRadius,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: height,
        width: width,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(height: 12),
                  Text(
                    'Loading HD image...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: Colors.grey[300],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'HD image not available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          fadeInDuration: const Duration(milliseconds: 500),
          fadeOutDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}