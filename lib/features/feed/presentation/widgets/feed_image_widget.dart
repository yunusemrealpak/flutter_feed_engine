import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feed_engine/core/cache/feed_image_cache_manager.dart';
import 'package:shimmer/shimmer.dart';

/// CachedNetworkImage wrapper — feed görselleri için.
///
/// [FeedImageCacheManager] kullanarak disk cache ile çalışır.
/// Yüklenirken shimmer, hata durumunda retry butonu gösterir.
class FeedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FeedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: FeedImageCacheManager(),
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _ShimmerPlaceholder(
        width: width,
        height: height,
      ),
      errorWidget: (context, url, error) => _ErrorPlaceholder(
        width: width,
        height: height,
        onRetry: () {
          // CachedNetworkImage cache'den kaldırıp tekrar dene
          FeedImageCacheManager().removeFile(url);
        },
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;

  const _ShimmerPlaceholder({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height ?? 350,
        color: Colors.white,
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final VoidCallback onRetry;

  const _ErrorPlaceholder({
    this.width,
    this.height,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 350,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
