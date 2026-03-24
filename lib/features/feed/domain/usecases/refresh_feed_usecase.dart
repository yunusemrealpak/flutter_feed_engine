import 'package:flutter_feed_engine/features/feed/domain/repositories/feed_repository.dart';

/// Pull-to-refresh senaryosu için feed'i yenileyen use case.
///
/// Cache'i temizler ve network'ten taze veri çeker.
class RefreshFeedUseCase {
  final FeedRepository _repository;

  RefreshFeedUseCase(this._repository);

  Future<FeedResult> call() {
    return _repository.refreshFeed();
  }
}
