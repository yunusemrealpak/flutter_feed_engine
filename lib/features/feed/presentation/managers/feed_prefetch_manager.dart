import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_feed_engine/core/cache/feed_image_cache_manager.dart';
import 'package:flutter_feed_engine/core/constants/cache_constants.dart';
import 'package:flutter_feed_engine/core/network/connectivity_manager.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/media_type.dart';
import 'package:flutter_feed_engine/features/feed/presentation/managers/video_player_pool.dart';

/// Görsel ve video prefetch koordinasyonunu sağlayan yönetici.
///
/// Ağ durumuna göre strateji belirler:
/// - WiFi: 5 post ileri, full boyut görseller, video initialize
/// - Cellular: 2 post ileri, thumbnail boyut görseller
/// - Offline/Slow: prefetch yapma
class FeedPrefetchManager {
  final BaseCacheManager _imageCacheManager;
  final VideoPlayerPool _videoPlayerPool;

  /// Hali hazırda indirilen/indirme kuyruğundaki URL'ler (duplicate engelleme).
  final Set<String> _prefetchedUrls = {};

  /// Hızlı scroll'da eski prefetch'leri iptal etmek için flag.
  bool _cancelled = false;

  FeedPrefetchManager({
    BaseCacheManager? imageCacheManager,
    required VideoPlayerPool videoPlayerPool,
  })  : _imageCacheManager = imageCacheManager ?? FeedImageCacheManager(),
        _videoPlayerPool = videoPlayerPool;

  /// Scroll pozisyonuna göre prefetch başlatır.
  ///
  /// [lastVisibleIndex]: ekrandaki son görünen post'un index'i.
  /// [posts]: tüm feed post listesi.
  /// [connectivity]: mevcut ağ durumu.
  Future<void> prefetch({
    required int lastVisibleIndex,
    required List<FeedPost> posts,
    required ConnectivityStatus connectivity,
  }) async {
    // Offline veya yavaş bağlantıda prefetch yapma
    if (connectivity == ConnectivityStatus.offline ||
        connectivity == ConnectivityStatus.slow) {
      return;
    }

    // Önceki prefetch'leri iptal et (hızlı scroll senaryosu)
    _cancelled = true;
    await Future.delayed(Duration.zero); // microtask yield
    _cancelled = false;

    final prefetchCount = connectivity == ConnectivityStatus.wifi
        ? CacheConstants.wifiPrefetchAhead
        : CacheConstants.cellularPrefetchAhead;

    final startIndex = lastVisibleIndex + 1;
    final endIndex = (startIndex + prefetchCount).clamp(0, posts.length);

    if (startIndex >= posts.length) return;

    final postsToPrefetch = posts.sublist(startIndex, endIndex);

    debugPrint(
      '[FeedPrefetchManager] Prefetching $startIndex..$endIndex '
      '(${postsToPrefetch.length} posts, $connectivity)',
    );

    // Max concurrent download'ı semaphore tarzı kontrol et
    var activeDownloads = 0;

    for (final post in postsToPrefetch) {
      if (_cancelled) {
        debugPrint('[FeedPrefetchManager] Cancelled');
        return;
      }

      if (post.mediaType == MediaType.image) {
        await _prefetchImage(
          post.mediaUrl,
          () => activeDownloads,
          () => activeDownloads++,
          () => activeDownloads--,
        );
      } else if (post.mediaType == MediaType.video) {
        // Thumbnail her zaman prefetch et
        await _prefetchImage(
          post.thumbnailUrl,
          () => activeDownloads,
          () => activeDownloads++,
          () => activeDownloads--,
        );

        // Video initialize sadece WiFi'da
        if (connectivity == ConnectivityStatus.wifi) {
          await _prefetchVideo(post.id, post.mediaUrl);
        }
      }
    }
  }

  /// Tekli görsel prefetch — duplicate ve concurrency kontrolü ile.
  Future<void> _prefetchImage(
    String url,
    int Function() getActive,
    void Function() increment,
    void Function() decrement,
  ) async {
    if (_prefetchedUrls.contains(url)) return;

    // Max concurrent download bekleme
    while (getActive() >= CacheConstants.maxConcurrentImageDownloads) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_cancelled) return;
    }

    _prefetchedUrls.add(url);
    increment();

    try {
      await _imageCacheManager.downloadFile(url);
    } catch (e) {
      debugPrint('[FeedPrefetchManager] Image prefetch failed: $url — $e');
      _prefetchedUrls.remove(url); // Tekrar denenebilsin
    } finally {
      decrement();
    }
  }

  /// Video prefetch — VideoPlayerPool aracılığıyla.
  Future<void> _prefetchVideo(String postId, String videoUrl) async {
    if (_videoPlayerPool.isReady(postId)) return;

    try {
      await _videoPlayerPool.prepareVideo(postId, videoUrl);
    } catch (e) {
      debugPrint('[FeedPrefetchManager] Video prefetch failed: $postId — $e');
    }
  }

  /// Tüm prefetch state'ini sıfırlar.
  void reset() {
    _cancelled = true;
    _prefetchedUrls.clear();
  }

  void dispose() {
    _cancelled = true;
    _prefetchedUrls.clear();
  }
}
