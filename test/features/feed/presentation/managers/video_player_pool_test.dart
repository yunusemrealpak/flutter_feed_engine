import 'package:flutter_feed_engine/features/feed/presentation/managers/video_player_pool.dart';
import 'package:flutter_test/flutter_test.dart';

/// VideoPlayerPool unit testleri.
///
/// Not: Gerçek VideoPlayerController initialize etmek test ortamında
/// zor olduğundan (network, platform channel gerektirir), bu testler
/// pool'un genel mantığını doğrular. Controller-seviyesi testler
/// integration test'lerde yapılır.
void main() {
  late VideoPlayerPool pool;

  setUp(() {
    pool = VideoPlayerPool();
  });

  tearDown(() {
    pool.disposeAll();
  });

  test('initial pool is empty', () {
    expect(pool.poolSize, 0);
    expect(pool.activePostId, isNull);
  });

  test('getController returns null for non-existent postId', () {
    expect(pool.getController('non_existent'), isNull);
  });

  test('isReady returns false for non-existent postId', () {
    expect(pool.isReady('non_existent'), false);
  });

  test('pauseAll sets activePostId to null', () {
    pool.pauseAll();
    expect(pool.activePostId, isNull);
  });

  test('disposeAll clears pool', () {
    pool.disposeAll();
    expect(pool.poolSize, 0);
    expect(pool.activePostId, isNull);
  });

  test('evictNonActive on empty pool does not throw', () {
    expect(() => pool.evictNonActive(), returnsNormally);
  });
}
