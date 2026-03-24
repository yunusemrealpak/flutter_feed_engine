import 'package:equatable/equatable.dart';
import 'package:flutter_feed_engine/core/network/connectivity_manager.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_cursor.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';

/// Feed BLoC state'leri.
sealed class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

/// Başlangıç state'i — henüz yükleme yapılmadı.
class FeedInitial extends FeedState {
  const FeedInitial();
}

/// İlk yükleme devam ediyor.
class FeedLoading extends FeedState {
  const FeedLoading();
}

/// Feed yüklendi — ana state.
class FeedLoaded extends FeedState {
  final List<FeedPost> posts;
  final FeedCursor cursor;
  final String? activeVideoPostId;
  final ConnectivityStatus connectivity;
  final bool isLoadingMore;
  final bool isRefreshing;

  const FeedLoaded({
    required this.posts,
    required this.cursor,
    this.activeVideoPostId,
    this.connectivity = ConnectivityStatus.wifi,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  /// Immutable kopyalama.
  FeedLoaded copyWith({
    List<FeedPost>? posts,
    FeedCursor? cursor,
    String? Function()? activeVideoPostId,
    ConnectivityStatus? connectivity,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      cursor: cursor ?? this.cursor,
      activeVideoPostId: activeVideoPostId != null
          ? activeVideoPostId()
          : this.activeVideoPostId,
      connectivity: connectivity ?? this.connectivity,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        posts,
        cursor,
        activeVideoPostId,
        connectivity,
        isLoadingMore,
        isRefreshing,
      ];
}

/// Hata state'i — mevcut post listesini korur.
class FeedError extends FeedState {
  final String message;
  final List<FeedPost> posts;

  const FeedError({
    required this.message,
    this.posts = const [],
  });

  @override
  List<Object?> get props => [message, posts];
}
