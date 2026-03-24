import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_feed_engine/features/feed/data/datasources/feed_local_data_source.dart';
import 'package:flutter_feed_engine/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_cursor.dart';
import 'package:flutter_feed_engine/features/feed/domain/repositories/feed_repository.dart';

/// Cache-first, network-refresh stratejisi uygulayan repository.
///
/// İlk yükleme:
///   1. SQLite'tan cached feed'i al → hemen dön
///   2. Arka planda API'den refresh başlat → stream'e ikinci emit
///
/// Pagination:
///   1. API'den sonraki sayfayı çek
///   2. SQLite'a append et
///   3. Dön
class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _remoteDataSource;
  final FeedLocalDatabase _localDatabase;

  FeedRepositoryImpl({
    required FeedRemoteDataSource remoteDataSource,
    required FeedLocalDatabase localDatabase,
  })  : _remoteDataSource = remoteDataSource,
        _localDatabase = localDatabase;

  @override
  Stream<FeedResult> getFeed({FeedCursor? cursor}) async* {
    if (cursor == null) {
      // === İlk yükleme: cache-first ===
      try {
        final cachedDtos = await _localDatabase.getCachedFeed();
        if (cachedDtos.isNotEmpty) {
          // Cache varsa hemen dön
          final cachedPosts = cachedDtos.map((dto) => dto.toDomain()).toList();
          yield FeedResult(
            posts: cachedPosts,
            cursor: const FeedCursor(hasMore: true),
          );
          debugPrint(
            '[FeedRepositoryImpl] Cache hit: ${cachedPosts.length} posts',
          );
        }
      } catch (e) {
        debugPrint('[FeedRepositoryImpl] Cache read error: $e');
      }

      // Arka planda network'ten taze veri çek
      try {
        final response = await _remoteDataSource.getFeed();
        final posts = response.posts.map((dto) => dto.toDomain()).toList();

        // Cache'i güncelle
        await _localDatabase.replaceFeed(response.posts);

        yield FeedResult(
          posts: posts,
          cursor: response.toCursor(),
        );
      } catch (e) {
        debugPrint('[FeedRepositoryImpl] Network error on initial load: $e');
        // Cache zaten yield edildiyse kullanıcı bir şey görüyor, hata sessiz kalabilir
      }
    } else {
      // === Pagination: sonraki sayfa ===
      try {
        final response = await _remoteDataSource.getFeed(
          cursor: cursor.nextCursor,
        );
        final posts = response.posts.map((dto) => dto.toDomain()).toList();

        // Mevcut cache'e append et
        final existingCount =
            (await _localDatabase.getCachedFeed()).length;
        await _localDatabase.appendToFeed(response.posts, existingCount);

        yield FeedResult(
          posts: posts,
          cursor: response.toCursor(),
        );
      } catch (e) {
        debugPrint('[FeedRepositoryImpl] Pagination error: $e');
        rethrow;
      }
    }
  }

  @override
  Future<FeedResult> refreshFeed() async {
    final response = await _remoteDataSource.getFeed();
    final posts = response.posts.map((dto) => dto.toDomain()).toList();

    // Cache'i yeni verilerle değiştir
    await _localDatabase.replaceFeed(response.posts);

    return FeedResult(
      posts: posts,
      cursor: response.toCursor(),
    );
  }

  @override
  Future<bool> toggleLike(String postId) {
    return _remoteDataSource.toggleLike(postId);
  }
}
