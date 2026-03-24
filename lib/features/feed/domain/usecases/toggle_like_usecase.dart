import 'package:flutter_feed_engine/features/feed/domain/repositories/feed_repository.dart';

/// Post'un like durumunu toggle eden use case.
///
/// Optimistic update BLoC tarafında yapılır. Bu use case sadece
/// API çağrısının başarılı olup olmadığını döner.
class ToggleLikeUseCase {
  final FeedRepository _repository;

  ToggleLikeUseCase(this._repository);

  /// Başarılıysa `true`, hata oluştuysa `false` döner.
  Future<bool> call(String postId) {
    return _repository.toggleLike(postId);
  }
}
