import 'package:flutter_feed_engine/features/feed/data/models/feed_post_dto.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_cursor.dart';

/// Mock API'den dönen sayfalanmış feed response'u.
class FeedResponseDto {
  final List<FeedPostDto> posts;
  final String? nextCursor;
  final bool hasMore;

  const FeedResponseDto({
    required this.posts,
    this.nextCursor,
    required this.hasMore,
  });

  /// Cursor bilgisini domain entity'ye çevirir.
  FeedCursor toCursor() {
    return FeedCursor(
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }
}
