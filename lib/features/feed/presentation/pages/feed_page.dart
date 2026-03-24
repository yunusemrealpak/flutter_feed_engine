import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feed_engine/core/network/connectivity_manager.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_event.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_state.dart';
import 'package:flutter_feed_engine/features/feed/presentation/managers/feed_prefetch_manager.dart';
import 'package:flutter_feed_engine/features/feed/presentation/managers/feed_scroll_manager.dart';
import 'package:flutter_feed_engine/features/feed/presentation/managers/video_player_pool.dart';
import 'package:flutter_feed_engine/features/feed/presentation/widgets/feed_error_widget.dart';
import 'package:flutter_feed_engine/features/feed/presentation/widgets/feed_post_card.dart';
import 'package:flutter_feed_engine/features/feed/presentation/widgets/feed_shimmer_loading.dart';
import 'package:get_it/get_it.dart';

/// Ana feed sayfası.
///
/// WidgetsBindingObserver ile app lifecycle ve memory pressure yakalar.
/// RefreshIndicator ile pull-to-refresh, ListView.builder ile lazy rendering sağlar.
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with WidgetsBindingObserver {
  late final VideoPlayerPool _videoPlayerPool;
  late final FeedPrefetchManager _prefetchManager;
  late final FeedScrollManager _scrollManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _videoPlayerPool = GetIt.I<VideoPlayerPool>();
    _prefetchManager = FeedPrefetchManager(
      videoPlayerPool: _videoPlayerPool,
    );
    _scrollManager = FeedScrollManager(
      onVisibleRangeChanged: _onVisibleRangeChanged,
    );

    // İlk feed yüklemesini tetikle
    context.read<FeedBloc>().add(const FeedLoadRequested());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _prefetchManager.dispose();
    _scrollManager.dispose();
    _videoPlayerPool.disposeAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isInForeground = state == AppLifecycleState.resumed;

    context.read<FeedBloc>().add(
          FeedAppLifecycleChanged(isInForeground: isInForeground),
        );

    if (!isInForeground) {
      _videoPlayerPool.pauseAll();
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();

    // 1. Memory image cache temizle
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // 2. Video pool'u daralt — sadece aktif controller kalsın
    _videoPlayerPool.evictNonActive();

    debugPrint('[FeedPage] Memory pressure handled');
  }

  void _onVisibleRangeChanged(int firstVisible, int lastVisible) {
    context.read<FeedBloc>().add(
          FeedScrollPositionChanged(
            firstVisibleIndex: firstVisible,
            lastVisibleIndex: lastVisible,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listenWhen: (prev, curr) {
          // Like hatası durumunda SnackBar göster
          if (prev is FeedLoaded && curr is FeedLoaded) {
            // Post listesi değiştiyse ve geri alma yapıldıysa bilgilendir
            // (Basit bir yaklaşım: BLoC'tan gelen hata mesajını dinleriz)
          }
          return false;
        },
        listener: (context, state) {},
        builder: (context, state) {
          return switch (state) {
            FeedInitial() || FeedLoading() => const FeedShimmerLoading(),
            FeedError(:final message, :final posts) => posts.isEmpty
                ? FeedErrorWidget(
                    message: message,
                    onRetry: () => context
                        .read<FeedBloc>()
                        .add(const FeedLoadRequested()),
                  )
                : _buildFeedList(context, posts, null, ConnectivityStatus.wifi,
                    false),
            FeedLoaded(
              :final posts,
              :final activeVideoPostId,
              :final connectivity,
              :final isLoadingMore,
            ) =>
              _buildFeedList(
                  context, posts, activeVideoPostId, connectivity, isLoadingMore),
          };
        },
      ),
    );
  }

  Widget _buildFeedList(
    BuildContext context,
    List<FeedPost> posts,
    String? activeVideoPostId,
    ConnectivityStatus connectivity,
    bool isLoadingMore,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FeedBloc>().add(const FeedRefreshRequested());
        // BLoC state değişene kadar bekle
        await context
            .read<FeedBloc>()
            .stream
            .firstWhere((s) => s is FeedLoaded && !s.isRefreshing);
      },
      child: ListView.builder(
        controller: _scrollManager.scrollController,
        itemCount: posts.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Son item loading indicator
          if (index >= posts.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final post = posts[index];

          // Prefetch tetikle
          _triggerPrefetch(index, posts, connectivity);

          return FeedPostCard(
            post: post,
            isVideoActive: post.id == activeVideoPostId,
            videoPlayerPool: _videoPlayerPool,
          );
        },
      ),
    );
  }

  void _triggerPrefetch(
    int currentIndex,
    List<FeedPost> posts,
    ConnectivityStatus connectivity,
  ) {
    _prefetchManager.prefetch(
      lastVisibleIndex: currentIndex,
      posts: posts,
      connectivity: connectivity,
    );
  }
}
