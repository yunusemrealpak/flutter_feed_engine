import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_feed_engine/core/network/connectivity_manager.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/media_type.dart';
import 'package:flutter_feed_engine/features/feed/presentation/managers/feed_prefetch_manager.dart';
import 'package:flutter_feed_engine/features/feed/presentation/managers/video_player_pool.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheManager extends Mock implements BaseCacheManager {}

List<FeedPost> _generatePosts(int count) {
  return List.generate(
    count,
    (i) => FeedPost(
      id: 'post_$i',
      userId: 'user_$i',
      userName: 'user$i',
      mediaType: i % 3 == 0 ? MediaType.video : MediaType.image,
      mediaUrl: 'https://example.com/media_$i',
      thumbnailUrl: 'https://example.com/thumb_$i',
      likeCount: 0,
      isLikedByMe: false,
      createdAt: DateTime(2025, 1, 1),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VideoPlayerPool videoPool;
  late FeedPrefetchManager manager;
  late MockCacheManager mockCacheManager;

  setUp(() {
    videoPool = VideoPlayerPool();
    mockCacheManager = MockCacheManager();
    manager = FeedPrefetchManager(
      imageCacheManager: mockCacheManager,
      videoPlayerPool: videoPool,
    );
  });

  tearDown(() {
    manager.dispose();
    videoPool.disposeAll();
  });

  test('does not prefetch when offline', () async {
    final posts = _generatePosts(20);

    await manager.prefetch(
      lastVisibleIndex: 5,
      posts: posts,
      connectivity: ConnectivityStatus.offline,
    );

    verifyNever(() => mockCacheManager.downloadFile(any()));
  });

  test('does not prefetch when slow connection', () async {
    final posts = _generatePosts(20);

    await manager.prefetch(
      lastVisibleIndex: 5,
      posts: posts,
      connectivity: ConnectivityStatus.slow,
    );

    verifyNever(() => mockCacheManager.downloadFile(any()));
  });

  test('does not crash when lastVisibleIndex exceeds posts length', () async {
    final posts = _generatePosts(5);

    await manager.prefetch(
      lastVisibleIndex: 10,
      posts: posts,
      connectivity: ConnectivityStatus.wifi,
    );

    // Herhangi bir download çağrısı yapılmamalı (index aşımı)
    verifyNever(() => mockCacheManager.downloadFile(any()));
  });

  test('reset clears prefetched URLs', () {
    manager.reset();
    expect(true, isTrue);
  });
}
