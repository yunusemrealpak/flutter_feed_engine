import 'package:flutter_feed_engine/features/feed/domain/entities/feed_cursor.dart';
import 'package:flutter_feed_engine/features/feed/domain/repositories/feed_repository.dart';

/// İlk yükleme ve pagination için feed verisi çeken use case.
///
/// Cache-first stratejiyi repository'ye devreder. BLoC bu use case'i kullanır.
class GetFeedUseCase {
  final FeedRepository _repository;

  GetFeedUseCase(this._repository);

  /// [cursor] null ise ilk sayfa, doluysa sonraki sayfa.
  Stream<FeedResult> call({FeedCursor? cursor}) {
    return _repository.getFeed(cursor: cursor);
  }
}
