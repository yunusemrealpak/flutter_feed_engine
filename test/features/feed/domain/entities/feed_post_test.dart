import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/media_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final post = FeedPost(
    id: 'post_1',
    userId: 'user_1',
    userName: 'test_user',
    caption: 'Test caption',
    mediaType: MediaType.image,
    mediaUrl: 'https://example.com/image.jpg',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    likeCount: 42,
    isLikedByMe: false,
    createdAt: DateTime(2025, 1, 1),
  );

  group('FeedPost', () {
    test('toggleLike increments count and sets isLikedByMe', () {
      final toggled = post.toggleLike();
      expect(toggled.isLikedByMe, true);
      expect(toggled.likeCount, 43);
    });

    test('toggleLike on already liked post decrements count', () {
      final liked = post.toggleLike();
      final unliked = liked.toggleLike();
      expect(unliked.isLikedByMe, false);
      expect(unliked.likeCount, 42);
    });

    test('toggleLike preserves other fields', () {
      final toggled = post.toggleLike();
      expect(toggled.id, post.id);
      expect(toggled.userId, post.userId);
      expect(toggled.userName, post.userName);
      expect(toggled.caption, post.caption);
      expect(toggled.mediaType, post.mediaType);
      expect(toggled.mediaUrl, post.mediaUrl);
      expect(toggled.thumbnailUrl, post.thumbnailUrl);
      expect(toggled.createdAt, post.createdAt);
    });

    test('equatable: same props are equal', () {
      final copy = FeedPost(
        id: 'post_1',
        userId: 'user_1',
        userName: 'test_user',
        caption: 'Test caption',
        mediaType: MediaType.image,
        mediaUrl: 'https://example.com/image.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        likeCount: 42,
        isLikedByMe: false,
        createdAt: DateTime(2025, 1, 1),
      );
      expect(post, equals(copy));
    });
  });

  group('MediaType', () {
    test('fromString parses valid values', () {
      expect(MediaType.fromString('image'), MediaType.image);
      expect(MediaType.fromString('video'), MediaType.video);
    });

    test('fromString defaults to image for unknown values', () {
      expect(MediaType.fromString('unknown'), MediaType.image);
    });
  });
}
