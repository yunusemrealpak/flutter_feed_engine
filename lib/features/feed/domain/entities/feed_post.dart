import 'package:equatable/equatable.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/media_type.dart';

/// Feed akışındaki tekil bir post'u temsil eden domain entity.
///
/// Data layer'daki DTO'lardan bağımsızdır. BLoC ve UI bu sınıfı kullanır.
class FeedPost extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? caption;
  final MediaType mediaType;
  final String mediaUrl;
  final String thumbnailUrl;
  final int likeCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  const FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.caption,
    required this.mediaType,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.likeCount,
    required this.isLikedByMe,
    required this.createdAt,
  });

  /// Like durumunu toggle edip yeni bir kopya döner (immutable update).
  FeedPost toggleLike() {
    final wasLiked = isLikedByMe;
    return FeedPost(
      id: id,
      userId: userId,
      userName: userName,
      caption: caption,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      likeCount: wasLiked ? likeCount - 1 : likeCount + 1,
      isLikedByMe: !wasLiked,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        caption,
        mediaType,
        mediaUrl,
        thumbnailUrl,
        likeCount,
        isLikedByMe,
        createdAt,
      ];
}
