import 'package:equatable/equatable.dart';

/// Cursor-based pagination için sayfa bilgisi.
///
/// [nextCursor] bir sonraki sayfa için kullanılacak opaque token,
/// [hasMore] daha fazla sayfa olup olmadığını belirtir.
class FeedCursor extends Equatable {
  final String? nextCursor;
  final bool hasMore;

  const FeedCursor({
    this.nextCursor,
    this.hasMore = true,
  });

  /// İlk sayfa isteği için boş cursor.
  static const initial = FeedCursor(nextCursor: null, hasMore: true);

  @override
  List<Object?> get props => [nextCursor, hasMore];
}
