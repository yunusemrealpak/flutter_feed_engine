import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feed_engine/core/constants/cache_constants.dart';
import 'package:flutter_feed_engine/core/network/connectivity_manager.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';
import 'package:flutter_feed_engine/features/feed/domain/usecases/get_feed_usecase.dart';
import 'package:flutter_feed_engine/features/feed/domain/usecases/refresh_feed_usecase.dart';
import 'package:flutter_feed_engine/features/feed/domain/usecases/toggle_like_usecase.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_event.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_state.dart';
import 'package:stream_transform/stream_transform.dart';

/// Feed akışını koordine eden merkezi BLoC.
///
/// Sorumlulukları:
/// - Feed yükleme/pagination/refresh
/// - Scroll pozisyonuna göre prefetch tetikleme
/// - Video visibility takibi ve otomatik play/pause
/// - Optimistic like update
/// - App lifecycle ve connectivity yönetimi
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedUseCase _getFeed;
  final RefreshFeedUseCase _refreshFeed;
  final ToggleLikeUseCase _toggleLike;
  final ConnectivityManager _connectivityManager;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  /// Optimistic update geri alma için önceki like state'leri.
  final Map<String, _LikeState> _previousLikeStates = {};

  /// Her video'nun görünürlük oranını takip eder.
  final Map<String, double> _videoVisibilities = {};

  FeedBloc({
    required GetFeedUseCase getFeed,
    required RefreshFeedUseCase refreshFeed,
    required ToggleLikeUseCase toggleLike,
    required ConnectivityManager connectivityManager,
  })  : _getFeed = getFeed,
        _refreshFeed = refreshFeed,
        _toggleLike = toggleLike,
        _connectivityManager = connectivityManager,
        super(const FeedInitial()) {
    // Event handler kayıtları
    on<FeedLoadRequested>(_onLoadRequested);
    on<FeedLoadMoreRequested>(_onLoadMoreRequested);
    on<FeedRefreshRequested>(_onRefreshRequested);
    on<FeedScrollPositionChanged>(
      _onScrollPositionChanged,
      // Scroll event'leri debounce edilir — her pixel'de tetiklenmesin
      transformer: (events, mapper) =>
          events.debounce(CacheConstants.scrollDebounce).switchMap(mapper),
    );
    on<FeedVideoVisibilityChanged>(_onVideoVisibilityChanged);
    on<FeedAppLifecycleChanged>(_onAppLifecycleChanged);
    on<FeedConnectivityChanged>(_onConnectivityChanged);
    on<FeedLikeToggled>(_onLikeToggled);

    // Connectivity stream'ine subscribe ol
    _connectivitySubscription =
        _connectivityManager.statusStream.listen((status) {
      add(FeedConnectivityChanged(connectivity: status));
    });
  }

  // ---------------------------------------------------------------------------
  // Event Handlers
  // ---------------------------------------------------------------------------

  /// İlk yükleme: cache-first strateji, stream'den birden fazla emit gelebilir.
  Future<void> _onLoadRequested(
    FeedLoadRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(const FeedLoading());

    await emit.forEach<dynamic>(
      _getFeed.call(),
      onData: (result) {
        final feedResult = result;
        return FeedLoaded(
          posts: feedResult.posts,
          cursor: feedResult.cursor,
          connectivity: _connectivityManager.currentStatus,
        );
      },
      onError: (error, _) {
        debugPrint('[FeedBloc] Load error: $error');
        return FeedError(message: error.toString());
      },
    );
  }

  /// Sonraki sayfa yükleme (infinite scroll).
  Future<void> _onLoadMoreRequested(
    FeedLoadMoreRequested event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    // Zaten yüklüyorsa veya daha fazla yoksa çık
    if (currentState.isLoadingMore || !currentState.cursor.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      await emit.forEach<dynamic>(
        _getFeed.call(cursor: currentState.cursor),
        onData: (result) {
          final feedResult = result;
          final updated = currentState.copyWith(
            posts: [...currentState.posts, ...feedResult.posts],
            cursor: feedResult.cursor,
            isLoadingMore: false,
          );
          return updated;
        },
        onError: (error, _) {
          debugPrint('[FeedBloc] Load more error: $error');
          return currentState.copyWith(isLoadingMore: false);
        },
      );
    } catch (e) {
      debugPrint('[FeedBloc] Load more exception: $e');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Pull-to-refresh: cache'i temizleyip yeni veri çek.
  Future<void> _onRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {
      final result = await _refreshFeed.call();
      emit(FeedLoaded(
        posts: result.posts,
        cursor: result.cursor,
        connectivity: _connectivityManager.currentStatus,
      ));
    } catch (e) {
      debugPrint('[FeedBloc] Refresh error: $e');
      if (currentState is FeedLoaded) {
        emit(currentState.copyWith(isRefreshing: false));
      } else {
        emit(FeedError(message: e.toString()));
      }
    }
  }

  /// Scroll pozisyonu değiştiğinde:
  /// 1. Son N post'a yaklaşıldıysa load more tetikle
  /// 2. Prefetch manager için bilgi güncelle (UI tarafında yapılır)
  void _onScrollPositionChanged(
    FeedScrollPositionChanged event,
    Emitter<FeedState> emit,
  ) {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    // Son 3 post'a yaklaşıldıysa otomatik load more
    final threshold = currentState.posts.length - CacheConstants.loadMoreThreshold;
    if (event.lastVisibleIndex >= threshold &&
        !currentState.isLoadingMore &&
        currentState.cursor.hasMore) {
      add(const FeedLoadMoreRequested());
    }
  }

  /// Video görünürlük değiştiğinde en görünür video'yu aktif yap.
  void _onVideoVisibilityChanged(
    FeedVideoVisibilityChanged event,
    Emitter<FeedState> emit,
  ) {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    // Visibility map'ini güncelle
    if (event.visibilityFraction > 0) {
      _videoVisibilities[event.postId] = event.visibilityFraction;
    } else {
      _videoVisibilities.remove(event.postId);
    }

    // En yüksek visibility'ye sahip video'yu bul
    String? mostVisiblePostId;
    double maxVisibility = 0;

    for (final entry in _videoVisibilities.entries) {
      if (entry.value > maxVisibility) {
        maxVisibility = entry.value;
        mostVisiblePostId = entry.key;
      }
    }

    // Threshold üzerindeyse aktif yap
    final newActiveId = maxVisibility >= CacheConstants.videoVisibilityThreshold
        ? mostVisiblePostId
        : null;

    if (newActiveId != currentState.activeVideoPostId) {
      emit(currentState.copyWith(
        activeVideoPostId: () => newActiveId,
      ));
    }
  }

  /// App lifecycle: arka plana geçişte videoları durdur, öne gelişte devam ettir.
  void _onAppLifecycleChanged(
    FeedAppLifecycleChanged event,
    Emitter<FeedState> emit,
  ) {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    if (!event.isInForeground) {
      // Arka plana geçiş — aktif video'yu null yap (pause için)
      emit(currentState.copyWith(activeVideoPostId: () => null));
    } else {
      // Öne geliş — en görünür video'yu tekrar aktif yap
      String? mostVisiblePostId;
      double maxVisibility = 0;
      for (final entry in _videoVisibilities.entries) {
        if (entry.value > maxVisibility) {
          maxVisibility = entry.value;
          mostVisiblePostId = entry.key;
        }
      }
      if (maxVisibility >= CacheConstants.videoVisibilityThreshold) {
        emit(currentState.copyWith(
          activeVideoPostId: () => mostVisiblePostId,
        ));
      }
    }
  }

  /// Ağ durumu değiştiğinde state'i güncelle.
  void _onConnectivityChanged(
    FeedConnectivityChanged event,
    Emitter<FeedState> emit,
  ) {
    final currentState = state;
    if (currentState is FeedLoaded) {
      emit(currentState.copyWith(connectivity: event.connectivity));
    }
  }

  /// Optimistic like update:
  /// 1. Hemen UI'ı güncelle
  /// 2. API'ye gönder
  /// 3. Hata gelirse geri al
  Future<void> _onLikeToggled(
    FeedLikeToggled event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    // Önceki state'i kaydet (geri alma için)
    final postIndex =
        currentState.posts.indexWhere((p) => p.id == event.postId);
    if (postIndex == -1) return;

    final originalPost = currentState.posts[postIndex];
    _previousLikeStates[event.postId] = _LikeState(
      likeCount: originalPost.likeCount,
      isLikedByMe: originalPost.isLikedByMe,
    );

    // 1. Optimistic update — hemen UI'ı güncelle
    final updatedPosts = List<FeedPost>.from(currentState.posts);
    updatedPosts[postIndex] = originalPost.toggleLike();
    emit(currentState.copyWith(posts: updatedPosts));

    // 2. API'ye gönder
    final success = await _toggleLike.call(event.postId);

    if (!success) {
      // 3. Hata — geri al
      final rollbackState = state;
      if (rollbackState is FeedLoaded) {
        final rollbackPosts = List<FeedPost>.from(rollbackState.posts);
        final rollbackIndex =
            rollbackPosts.indexWhere((p) => p.id == event.postId);
        if (rollbackIndex != -1) {
          final prev = _previousLikeStates[event.postId];
          if (prev != null) {
            final post = rollbackPosts[rollbackIndex];
            rollbackPosts[rollbackIndex] = FeedPost(
              id: post.id,
              userId: post.userId,
              userName: post.userName,
              caption: post.caption,
              mediaType: post.mediaType,
              mediaUrl: post.mediaUrl,
              thumbnailUrl: post.thumbnailUrl,
              likeCount: prev.likeCount,
              isLikedByMe: prev.isLikedByMe,
              createdAt: post.createdAt,
            );
          }
        }
        emit(rollbackState.copyWith(posts: rollbackPosts));
      }
      debugPrint('[FeedBloc] Like toggle failed for ${event.postId}, rolled back');
    }

    _previousLikeStates.remove(event.postId);
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}

/// Optimistic update geri alma için like state tutucusu.
class _LikeState {
  final int likeCount;
  final bool isLikedByMe;

  const _LikeState({required this.likeCount, required this.isLikedByMe});
}
