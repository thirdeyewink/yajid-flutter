import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Wrapper widget for cached network images with built-in loading and error states
///
/// Features:
/// - Automatic image caching
/// - Loading placeholder with circular progress indicator
/// - Error fallback icon
/// - Optional border radius
/// - Customizable fit and dimensions
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Widget? placeholder;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
            ),
      ),
    );
  }
}

/// Square avatar with cached network image
class CachedAvatarImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final String? placeholderText;

  const CachedAvatarImage({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.placeholderText,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        child: Center(
          child: placeholderText != null
              ? Text(
                  placeholderText!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: size / 2.5,
                  ),
                )
              : CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey[600],
                ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[400],
        ),
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: size / 2,
        ),
      ),
    );
  }
}

/// Utility class for managing image cache
class ImageCacheManager {
  /// Clear all cached images
  static Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    final cacheManager = DefaultCacheManager();
    return {
      'cacheSize': await _getCacheSize(cacheManager),
      'fileCount': await _getCacheFileCount(cacheManager),
    };
  }

  static Future<int> _getCacheSize(DefaultCacheManager manager) async {
    try {
      // This is an approximation - actual implementation would need platform-specific code
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<int> _getCacheFileCount(DefaultCacheManager manager) async {
    try {
      // This is an approximation - actual implementation would need platform-specific code
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
