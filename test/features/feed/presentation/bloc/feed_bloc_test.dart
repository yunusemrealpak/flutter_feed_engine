import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_feed_engine/core/network/connectivity_manager.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_cursor.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/media_type.dart';
import 'package:flutter_feed_engine/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_feed_engine/features/feed/domain/usecases/get_feed_usecase.dart';
import 'package:flutter_feed_engine/features/feed/domain/usecases/refresh_feed_usecase.dart';
import 'package:flutter_feed_engine/features/feed/domain/usecases/toggle_like_usecase.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_event.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

class MockRefreshFeedUseCase extends Mock implements RefreshFeedUseCase {}

class MockToggleLikeUseCase extends Mock implements ToggleLikeUseCase {}

class MockConnectivityManager extends Mock implements ConnectivityManager {}

// ---------------------------------------------------------------------------
// Test Fixtures
// ---------------------------------------------------------------------------
final _testPosts = List.generate(
  10,
  (i) => FeedPost(
    id: 'post_$i',
    userId: 'user_$i',
    userName: 'user$i',
    caption: 'Caption $i',
    mediaType: i % 3 == 0 ? MediaType.video : MediaType.image,
    mediaUrl: 'https://example.com/media_$i',
    thumbnailUrl: 'https://example.com/thumb_$i',
    likeCount: i * 10,
    isLikedByMe: i.isEven,
    createdAt: DateTime(2025, 1, 1).add(Duration(hours: i)),
  ),
);

final _testCursor = const FeedCursor(nextCursor: '10', hasMore: true);
final _testResult = FeedResult(posts: _testPosts, cursor: _testCursor);

final _page2Posts = List.generate(
  5,
  (i) => FeedPost(
    id: 'post_${10 + i}',
    userId: 'user_${10 + i}',
    userName: 'user${10 + i}',
    mediaType: MediaType.image,
    mediaUrl: 'https://example.com/media_${10 + i}',
    thumbnailUrl: 'https://example.com/thumb_${10 + i}',
    likeCount: 0,
    isLikedByMe: false,
    createdAt: DateTime(2025, 1, 2),
  ),
);

final _page2Cursor = const FeedCursor(nextCursor: null, hasMore: false);
final _page2Result = FeedResult(posts: _page2Posts, cursor: _page2Cursor);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  late MockGetFeedUseCase mockGetFeed;
  late MockRefreshFeedUseCase mockRefreshFeed;
  late MockToggleLikeUseCase mockToggleLike;
  late MockConnectivityManager mockConnectivity;

  setUp(() {
    mockGetFeed = MockGetFeedUseCase();
    mockRefreshFeed = MockRefreshFeedUseCase();
    mockToggleLike = MockToggleLikeUseCase();
    mockConnectivity = MockConnectivityManager();

    when(() => mockConnectivity.currentStatus)
        .thenReturn(ConnectivityStatus.wifi);
    when(() => mockConnectivity.statusStream)
        .thenAnswer((_) => const Stream.empty());
  });

  FeedBloc buildBloc() => FeedBloc(
        getFeed: mockGetFeed,
        refreshFeed: mockRefreshFeed,
        toggleLike: mockToggleLike,
        connectivityManager: mockConnectivity,
      );

  group('FeedLoadRequested', () {
    blocTest<FeedBloc, FeedState>(
      'emits [FeedLoading, FeedLoaded] on successful load',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.value(_testResult));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const FeedLoadRequested()),
      expect: () => [
        const FeedLoading(),
        isA<FeedLoaded>()
            .having((s) => s.posts.length, 'posts.length', 10)
            .having((s) => s.cursor, 'cursor', _testCursor),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'emits [FeedLoading, FeedError] on failure',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.error(Exception('Network error')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const FeedLoadRequested()),
      expect: () => [
        const FeedLoading(),
        isA<FeedError>(),
      ],
    );
  });

  group('FeedLoadMoreRequested', () {
    blocTest<FeedBloc, FeedState>(
      'appends new posts to existing list and updates cursor',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.value(_testResult));
        when(() => mockGetFeed.call(cursor: _testCursor))
            .thenAnswer((_) => Stream.value(_page2Result));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedLoadRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const FeedLoadMoreRequested());
      },
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const FeedLoading(),
        isA<FeedLoaded>().having((s) => s.posts.length, 'initial', 10),
        // isLoadingMore = true
        isA<FeedLoaded>().having((s) => s.isLoadingMore, 'loading', true),
        // Posts appended
        isA<FeedLoaded>()
            .having((s) => s.posts.length, 'appended', 15)
            .having((s) => s.cursor.hasMore, 'hasMore', false)
            .having((s) => s.isLoadingMore, 'loading', false),
      ],
    );
  });

  group('FeedRefreshRequested', () {
    blocTest<FeedBloc, FeedState>(
      'emits new feed data and resets cursor',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.value(_testResult));
        when(() => mockRefreshFeed.call())
            .thenAnswer((_) async => _testResult);
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedLoadRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const FeedRefreshRequested());
      },
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const FeedLoading(),
        isA<FeedLoaded>(),
        // isRefreshing = true
        isA<FeedLoaded>().having((s) => s.isRefreshing, 'refreshing', true),
        // Refreshed
        isA<FeedLoaded>().having((s) => s.isRefreshing, 'refreshing', false),
      ],
    );
  });

  group('FeedLikeToggled', () {
    blocTest<FeedBloc, FeedState>(
      'performs optimistic update — success path',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.value(_testResult));
        when(() => mockToggleLike.call('post_0'))
            .thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedLoadRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const FeedLikeToggled(postId: 'post_0'));
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        final state = bloc.state as FeedLoaded;
        final post = state.posts.firstWhere((p) => p.id == 'post_0');
        // post_0 was isLikedByMe=true (even index), toggled → false
        expect(post.isLikedByMe, false);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'rolls back on API failure',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.value(_testResult));
        when(() => mockToggleLike.call('post_0'))
            .thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedLoadRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const FeedLikeToggled(postId: 'post_0'));
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        final state = bloc.state as FeedLoaded;
        final post = state.posts.firstWhere((p) => p.id == 'post_0');
        // Rolled back to original
        expect(post.isLikedByMe, true);
        expect(post.likeCount, 0); // index 0 * 10 = 0
      },
    );
  });

  group('FeedVideoVisibilityChanged', () {
    blocTest<FeedBloc, FeedState>(
      'sets most visible video as active when above threshold',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.value(_testResult));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedLoadRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const FeedVideoVisibilityChanged(
          postId: 'post_0',
          visibilityFraction: 0.8,
        ));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as FeedLoaded;
        expect(state.activeVideoPostId, 'post_0');
      },
    );

    blocTest<FeedBloc, FeedState>(
      'clears active video when below threshold',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.value(_testResult));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedLoadRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const FeedVideoVisibilityChanged(
          postId: 'post_0',
          visibilityFraction: 0.8,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const FeedVideoVisibilityChanged(
          postId: 'post_0',
          visibilityFraction: 0.2,
        ));
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        final state = bloc.state as FeedLoaded;
        expect(state.activeVideoPostId, isNull);
      },
    );
  });

  group('FeedAppLifecycleChanged', () {
    blocTest<FeedBloc, FeedState>(
      'clears activeVideoPostId when going to background',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.value(_testResult));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedLoadRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        // Önce bir video'yu aktif yap
        bloc.add(const FeedVideoVisibilityChanged(
          postId: 'post_0',
          visibilityFraction: 0.9,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        // Arka plana geç
        bloc.add(const FeedAppLifecycleChanged(isInForeground: false));
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        final state = bloc.state as FeedLoaded;
        expect(state.activeVideoPostId, isNull);
      },
    );
  });

  group('FeedConnectivityChanged', () {
    blocTest<FeedBloc, FeedState>(
      'updates connectivity status in state',
      build: () {
        when(() => mockGetFeed.call())
            .thenAnswer((_) => Stream.value(_testResult));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const FeedLoadRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const FeedConnectivityChanged(
          connectivity: ConnectivityStatus.cellular,
        ));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as FeedLoaded;
        expect(state.connectivity, ConnectivityStatus.cellular);
      },
    );
  });
}
