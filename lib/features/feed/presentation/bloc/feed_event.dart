import 'package:equatable/equatable.dart';
import 'package:flutter_feed_engine/core/network/connectivity_manager.dart';

/// Feed BLoC'una gönderilen tüm event'ler.
sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

/// İlk feed yüklemesi.
class FeedLoadRequested extends FeedEvent {
  const FeedLoadRequested();
}

/// Infinite scroll ile sonraki sayfa.
class FeedLoadMoreRequested extends FeedEvent {
  const FeedLoadMoreRequested();
}

/// Pull-to-refresh.
class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}

/// Scroll pozisyonu değişti — prefetch ve load-more tetikleyicisi.
class FeedScrollPositionChanged extends FeedEvent {
  final int firstVisibleIndex;
  final int lastVisibleIndex;

  const FeedScrollPositionChanged({
    required this.firstVisibleIndex,
    required this.lastVisibleIndex,
  });

  @override
  List<Object?> get props => [firstVisibleIndex, lastVisibleIndex];
}

/// Video görünürlüğü değişti — otomatik play/pause için.
class FeedVideoVisibilityChanged extends FeedEvent {
  final String postId;
  final double visibilityFraction;

  const FeedVideoVisibilityChanged({
    required this.postId,
    required this.visibilityFraction,
  });

  @override
  List<Object?> get props => [postId, visibilityFraction];
}

/// Uygulama lifecycle değişti (foreground/background).
class FeedAppLifecycleChanged extends FeedEvent {
  final bool isInForeground;

  const FeedAppLifecycleChanged({required this.isInForeground});

  @override
  List<Object?> get props => [isInForeground];
}

/// Ağ bağlantı durumu değişti.
class FeedConnectivityChanged extends FeedEvent {
  final ConnectivityStatus connectivity;

  const FeedConnectivityChanged({required this.connectivity});

  @override
  List<Object?> get props => [connectivity];
}

/// Like/unlike toggle (optimistic update).
class FeedLikeToggled extends FeedEvent {
  final String postId;

  const FeedLikeToggled({required this.postId});

  @override
  List<Object?> get props => [postId];
}
