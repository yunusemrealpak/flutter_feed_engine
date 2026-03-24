import 'package:flutter_feed_engine/features/feed/domain/entities/feed_cursor.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';

/// Feed verisine erişim için soyut repository arayüzü.
///
/// Domain layer bu arayüzü tanımlar; data layer implement eder.
/// Bu sayede domain katmanı data katmanına bağımlı olmaz (Dependency Inversion).
abstract class FeedRepository {
  /// Feed post'larını getirir.
  ///
  /// [cursor] null ise ilk sayfa yüklenir (cache-first stratejisi).
  /// [cursor] doluysa pagination ile sonraki sayfa çekilir.
  /// Stream döner: cache-first senaryoda önce cache, sonra network verisi gelir.
  Stream<FeedResult> getFeed({FeedCursor? cursor});

  /// Feed'i yeniler (pull-to-refresh). Cache'i temizleyip network'ten çeker.
  Future<FeedResult> refreshFeed();

  /// Post'un like durumunu toggle eder.
  ///
  /// Başarılıysa `true`, hata oluştuysa `false` döner.
  Future<bool> toggleLike(String postId);
}

/// Repository'den dönen feed sonucu.
class FeedResult {
  final List<FeedPost> posts;
  final FeedCursor cursor;

  const FeedResult({
    required this.posts,
    required this.cursor,
  });
}
