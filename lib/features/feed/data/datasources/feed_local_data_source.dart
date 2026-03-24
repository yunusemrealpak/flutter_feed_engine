import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:flutter_feed_engine/features/feed/data/models/feed_post_dto.dart';

part 'feed_local_data_source.g.dart';

/// Drift tablo tanımı: cached feed post'ları SQLite'ta saklar.
class CachedFeedPosts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get userName => text()();
  TextColumn get caption => text().nullable()();
  TextColumn get mediaType => text()();
  TextColumn get mediaUrl => text()();
  TextColumn get thumbnailUrl => text()();
  IntColumn get likeCount => integer()();
  BoolColumn get isLikedByMe => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get cacheOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// SQLite tabanlı lokal cache veritabanı.
///
/// Feed post'larını cache'leyerek offline erişim ve hızlı ilk yükleme sağlar.
/// `cache_order` kolonu feed sıralamasını korur.
@DriftDatabase(tables: [CachedFeedPosts])
class FeedLocalDatabase extends _$FeedLocalDatabase {
  FeedLocalDatabase() : super(_openConnection());

  /// Test için custom executor kabul eden constructor.
  FeedLocalDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  /// Mevcut cache'i temizleyip yeni listeyi yazar (pull-to-refresh).
  Future<void> replaceFeed(List<FeedPostDto> posts) async {
    await transaction(() async {
      await delete(cachedFeedPosts).go();
      for (var i = 0; i < posts.length; i++) {
        await into(cachedFeedPosts).insert(
          _dtoToCompanion(posts[i], i),
        );
      }
    });
    debugPrint('[FeedLocalDatabase] replaceFeed: ${posts.length} posts cached');
  }

  /// Mevcut listeye ekler (pagination senaryosu).
  Future<void> appendToFeed(List<FeedPostDto> posts, int startOrder) async {
    await batch((b) {
      for (var i = 0; i < posts.length; i++) {
        b.insert(
          cachedFeedPosts,
          _dtoToCompanion(posts[i], startOrder + i),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    debugPrint(
      '[FeedLocalDatabase] appendToFeed: ${posts.length} posts appended '
      'starting at order $startOrder',
    );
  }

  /// Cache_order'a göre sıralı tüm post'ları getirir.
  Future<List<FeedPostDto>> getCachedFeed() async {
    final rows = await (select(cachedFeedPosts)
          ..orderBy([(t) => OrderingTerm.asc(t.cacheOrder)]))
        .get();

    return rows.map(_rowToDto).toList();
  }

  /// Tüm cache'i temizler.
  Future<void> clearAll() async {
    await delete(cachedFeedPosts).go();
    debugPrint('[FeedLocalDatabase] Cache cleared');
  }

  // ---------------------------------------------------------------------------
  // Dönüşüm yardımcıları
  // ---------------------------------------------------------------------------

  CachedFeedPostsCompanion _dtoToCompanion(FeedPostDto dto, int order) {
    return CachedFeedPostsCompanion.insert(
      id: dto.id,
      userId: dto.userId,
      userName: dto.userName,
      caption: Value(dto.caption),
      mediaType: dto.mediaType,
      mediaUrl: dto.mediaUrl,
      thumbnailUrl: dto.thumbnailUrl,
      likeCount: dto.likeCount,
      isLikedByMe: dto.isLikedByMe,
      createdAt: dto.createdAt,
      cacheOrder: order,
    );
  }

  FeedPostDto _rowToDto(CachedFeedPost row) {
    return FeedPostDto(
      id: row.id,
      userId: row.userId,
      userName: row.userName,
      caption: row.caption,
      mediaType: row.mediaType,
      mediaUrl: row.mediaUrl,
      thumbnailUrl: row.thumbnailUrl,
      likeCount: row.likeCount,
      isLikedByMe: row.isLikedByMe,
      createdAt: row.createdAt,
    );
  }
}

/// Veritabanı dosyasını açar.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'feed_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
