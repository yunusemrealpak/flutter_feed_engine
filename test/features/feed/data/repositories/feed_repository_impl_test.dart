import 'package:flutter_feed_engine/features/feed/data/datasources/feed_local_data_source.dart';
import 'package:flutter_feed_engine/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:flutter_feed_engine/features/feed/data/models/feed_post_dto.dart';
import 'package:flutter_feed_engine/features/feed/data/models/feed_response_dto.dart';
import 'package:flutter_feed_engine/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_cursor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockFeedRemoteDataSource extends Mock implements FeedRemoteDataSource {}

class MockFeedLocalDatabase extends Mock implements FeedLocalDatabase {}

// ---------------------------------------------------------------------------
// Test Data
// ---------------------------------------------------------------------------
final _testDtos = List.generate(
  10,
  (i) => FeedPostDto(
    id: 'post_$i',
    userId: 'user_$i',
    userName: 'user$i',
    caption: 'Caption $i',
    mediaType: 'image',
    mediaUrl: 'https://example.com/media_$i',
    thumbnailUrl: 'https://example.com/thumb_$i',
    likeCount: i * 10,
    isLikedByMe: i.isEven,
    createdAt: DateTime(2025, 1, 1),
  ),
);

final _testResponse = FeedResponseDto(
  posts: _testDtos,
  nextCursor: '10',
  hasMore: true,
);

void main() {
  late MockFeedRemoteDataSource mockRemote;
  late MockFeedLocalDatabase mockLocal;
  late FeedRepositoryImpl repository;

  setUp(() {
    mockRemote = MockFeedRemoteDataSource();
    mockLocal = MockFeedLocalDatabase();
    repository = FeedRepositoryImpl(
      remoteDataSource: mockRemote,
      localDatabase: mockLocal,
    );
  });

  group('getFeed - initial load (cursor == null)', () {
    test('returns cache first, then network data', () async {
      // Cache'te veri var
      when(() => mockLocal.getCachedFeed()).thenAnswer((_) async => _testDtos);
      // Network'ten taze veri
      when(() => mockRemote.getFeed()).thenAnswer((_) async => _testResponse);
      when(() => mockLocal.replaceFeed(any())).thenAnswer((_) async {});

      final results = await repository.getFeed().toList();

      // İlk emit: cache
      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.first.posts.length, 10);

      // Cache ve network çağrıları yapılmış olmalı
      verify(() => mockLocal.getCachedFeed()).called(1);
      verify(() => mockRemote.getFeed()).called(1);
    });

    test('skips cache when empty, returns only network data', () async {
      // Cache boş
      when(() => mockLocal.getCachedFeed()).thenAnswer((_) async => []);
      when(() => mockRemote.getFeed()).thenAnswer((_) async => _testResponse);
      when(() => mockLocal.replaceFeed(any())).thenAnswer((_) async {});

      final results = await repository.getFeed().toList();

      // Sadece network sonucu
      expect(results.length, 1);
      expect(results.first.posts.length, 10);
    });
  });

  group('getFeed - pagination (cursor != null)', () {
    test('fetches next page and appends to cache', () async {
      final cursor =
          const FeedCursor(nextCursor: '10', hasMore: true);

      when(() => mockRemote.getFeed(cursor: '10'))
          .thenAnswer((_) async => _testResponse);
      when(() => mockLocal.getCachedFeed()).thenAnswer((_) async => _testDtos);
      when(() => mockLocal.appendToFeed(any(), any()))
          .thenAnswer((_) async {});

      final results = await repository.getFeed(cursor: cursor).toList();

      expect(results.length, 1);
      expect(results.first.posts.length, 10);
      verify(() => mockLocal.appendToFeed(any(), 10)).called(1);
    });
  });

  group('refreshFeed', () {
    test('fetches fresh data and replaces cache', () async {
      when(() => mockRemote.getFeed()).thenAnswer((_) async => _testResponse);
      when(() => mockLocal.replaceFeed(any())).thenAnswer((_) async {});

      final result = await repository.refreshFeed();

      expect(result.posts.length, 10);
      expect(result.cursor.hasMore, true);
      verify(() => mockLocal.replaceFeed(any())).called(1);
    });
  });

  group('toggleLike', () {
    test('delegates to remote data source', () async {
      when(() => mockRemote.toggleLike('post_0'))
          .thenAnswer((_) async => true);

      final result = await repository.toggleLike('post_0');

      expect(result, true);
      verify(() => mockRemote.toggleLike('post_0')).called(1);
    });

    test('returns false on failure', () async {
      when(() => mockRemote.toggleLike('post_0'))
          .thenAnswer((_) async => false);

      final result = await repository.toggleLike('post_0');

      expect(result, false);
    });
  });
}
