import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/media_type.dart';

/// API response'undan gelen ham veriyi temsil eden DTO.
///
/// Domain entity'ye dönüşüm [toDomain] metodu ile yapılır.
/// Cache'ten okuma/yazma için [toMap]/[fromMap] dönüşümleri sağlar.
class FeedPostDto {
  final String id;
  final String userId;
  final String userName;
  final String? caption;
  final String mediaType;
  final String mediaUrl;
  final String thumbnailUrl;
  final int likeCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  const FeedPostDto({
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

  /// JSON map'ten DTO oluşturur.
  factory FeedPostDto.fromMap(Map<String, dynamic> map) {
    return FeedPostDto(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      caption: map['caption'] as String?,
      mediaType: map['mediaType'] as String,
      mediaUrl: map['mediaUrl'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      likeCount: map['likeCount'] as int,
      isLikedByMe: map['isLikedByMe'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// DTO'yu JSON map'e çevirir.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'caption': caption,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'likeCount': likeCount,
      'isLikedByMe': isLikedByMe,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// DTO'yu domain entity'ye dönüştürür.
  FeedPost toDomain() {
    return FeedPost(
      id: id,
      userId: userId,
      userName: userName,
      caption: caption,
      mediaType: MediaType.fromString(mediaType),
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      likeCount: likeCount,
      isLikedByMe: isLikedByMe,
      createdAt: createdAt,
    );
  }

  /// Domain entity'den DTO oluşturur.
  factory FeedPostDto.fromDomain(FeedPost post) {
    return FeedPostDto(
      id: post.id,
      userId: post.userId,
      userName: post.userName,
      caption: post.caption,
      mediaType: post.mediaType.name,
      mediaUrl: post.mediaUrl,
      thumbnailUrl: post.thumbnailUrl,
      likeCount: post.likeCount,
      isLikedByMe: post.isLikedByMe,
      createdAt: post.createdAt,
    );
  }
}
