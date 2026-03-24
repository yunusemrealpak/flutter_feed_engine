import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_feed_engine/core/constants/cache_constants.dart';
import 'package:flutter_feed_engine/features/feed/data/models/feed_post_dto.dart';
import 'package:flutter_feed_engine/features/feed/data/models/feed_response_dto.dart';

/// Mock API client. Backend olmadığı için fake data üretir.
///
/// Gerçekçi network simülasyonu için her çağrıda 500-1500ms arası delay ekler.
/// 50 adet mock post üretir: %70 image, %30 video.
class FeedRemoteDataSource {
  final _random = Random();

  // -------------------------------------------------------------------------
  // Mock data sabitleri
  // -------------------------------------------------------------------------
  static const _mockUsers = [
    'ahmet_dev',
    'elif.photo',
    'can_travels',
    'zeynep.art',
    'burak_eats',
  ];

  static const _mockCaptions = [
    'Bugün harika bir gün ☀️',
    'Yeni proje üzerinde çalışıyorum 💻',
    null,
    'Kahve zamanı ☕',
    null,
    'Bu manzaraya bayıldım 🏔️',
    'Yemek denedim, tavsiye ederim 🍕',
    null,
    'Kod yazarken müzik şart 🎵',
    'Hafta sonu planları yapıyorum 🗓️',
  ];

  static const _mockVideoUrls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  ];

  /// Önceden üretilmiş 50 adet mock post.
  late final List<FeedPostDto> _allPosts = _generatePosts();

  /// Cursor-based pagination ile feed sayfası getirir.
  ///
  /// [cursor] null ise ilk sayfa döner. Her sayfa [CacheConstants.pageSize] post içerir.
  /// 5 sayfa (50 post) sonra `hasMore: false`.
  Future<FeedResponseDto> getFeed({String? cursor}) async {
    // Gerçekçi network delay
    await _simulateNetworkDelay();

    final startIndex = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final endIndex = (startIndex + CacheConstants.pageSize)
        .clamp(0, CacheConstants.totalMockPosts);

    final pagePosts = _allPosts.sublist(startIndex, endIndex);

    final hasMore = endIndex < CacheConstants.totalMockPosts;
    final nextCursor = hasMore ? endIndex.toString() : null;

    debugPrint(
      '[FeedRemoteDataSource] getFeed cursor=$cursor → '
      '${pagePosts.length} posts, hasMore=$hasMore',
    );

    return FeedResponseDto(
      posts: pagePosts,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }

  /// Like toggle API çağrısı simülasyonu.
  ///
  /// %5 ihtimalle hata döner.
  Future<bool> toggleLike(String postId) async {
    await Future.delayed(CacheConstants.likeApiDelay);

    // %5 hata oranı
    if (_random.nextDouble() < CacheConstants.likeErrorRate) {
      debugPrint('[FeedRemoteDataSource] toggleLike FAILED for $postId');
      return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  List<FeedPostDto> _generatePosts() {
    return List.generate(CacheConstants.totalMockPosts, (index) {
      final postId = 'post_$index';
      final isVideo = index % 10 >= 7; // %30 video
      final userIndex = index % _mockUsers.length;
      final captionIndex = index % _mockCaptions.length;

      final mediaUrl = isVideo
          ? _mockVideoUrls[index % _mockVideoUrls.length]
          : 'https://picsum.photos/seed/$postId/600/600';

      final thumbnailUrl = isVideo
          ? 'https://picsum.photos/seed/${postId}_thumb/600/600'
          : mediaUrl;

      return FeedPostDto(
        id: postId,
        userId: 'user_$userIndex',
        userName: _mockUsers[userIndex],
        caption: _mockCaptions[captionIndex],
        mediaType: isVideo ? 'video' : 'image',
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        likeCount: _random.nextInt(10001),
        isLikedByMe: _random.nextBool(),
        createdAt: DateTime.now().subtract(Duration(hours: index * 3)),
      );
    });
  }

  Future<void> _simulateNetworkDelay() async {
    final delayMs = CacheConstants.minApiDelay.inMilliseconds +
        _random.nextInt(
          CacheConstants.maxApiDelay.inMilliseconds -
              CacheConstants.minApiDelay.inMilliseconds,
        );
    await Future.delayed(Duration(milliseconds: delayMs));
  }
}
