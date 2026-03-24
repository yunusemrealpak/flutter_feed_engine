// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_local_data_source.dart';

// ignore_for_file: type=lint
class $CachedFeedPostsTable extends CachedFeedPosts
    with TableInfo<$CachedFeedPostsTable, CachedFeedPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFeedPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaUrlMeta = const VerificationMeta(
    'mediaUrl',
  );
  @override
  late final GeneratedColumn<String> mediaUrl = GeneratedColumn<String>(
    'media_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLikedByMeMeta = const VerificationMeta(
    'isLikedByMe',
  );
  @override
  late final GeneratedColumn<bool> isLikedByMe = GeneratedColumn<bool>(
    'is_liked_by_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liked_by_me" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cacheOrderMeta = const VerificationMeta(
    'cacheOrder',
  );
  @override
  late final GeneratedColumn<int> cacheOrder = GeneratedColumn<int>(
    'cache_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
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
    cacheOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_feed_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFeedPost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('media_url')) {
      context.handle(
        _mediaUrlMeta,
        mediaUrl.isAcceptableOrUnknown(data['media_url']!, _mediaUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaUrlMeta);
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thumbnailUrlMeta);
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    } else if (isInserting) {
      context.missing(_likeCountMeta);
    }
    if (data.containsKey('is_liked_by_me')) {
      context.handle(
        _isLikedByMeMeta,
        isLikedByMe.isAcceptableOrUnknown(
          data['is_liked_by_me']!,
          _isLikedByMeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isLikedByMeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('cache_order')) {
      context.handle(
        _cacheOrderMeta,
        cacheOrder.isAcceptableOrUnknown(data['cache_order']!, _cacheOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFeedPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFeedPost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      mediaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_url'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      )!,
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      )!,
      isLikedByMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liked_by_me'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      cacheOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cache_order'],
      )!,
    );
  }

  @override
  $CachedFeedPostsTable createAlias(String alias) {
    return $CachedFeedPostsTable(attachedDatabase, alias);
  }
}

class CachedFeedPost extends DataClass implements Insertable<CachedFeedPost> {
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
  final int cacheOrder;
  const CachedFeedPost({
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
    required this.cacheOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['user_name'] = Variable<String>(userName);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['media_type'] = Variable<String>(mediaType);
    map['media_url'] = Variable<String>(mediaUrl);
    map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    map['like_count'] = Variable<int>(likeCount);
    map['is_liked_by_me'] = Variable<bool>(isLikedByMe);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cache_order'] = Variable<int>(cacheOrder);
    return map;
  }

  CachedFeedPostsCompanion toCompanion(bool nullToAbsent) {
    return CachedFeedPostsCompanion(
      id: Value(id),
      userId: Value(userId),
      userName: Value(userName),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      mediaType: Value(mediaType),
      mediaUrl: Value(mediaUrl),
      thumbnailUrl: Value(thumbnailUrl),
      likeCount: Value(likeCount),
      isLikedByMe: Value(isLikedByMe),
      createdAt: Value(createdAt),
      cacheOrder: Value(cacheOrder),
    );
  }

  factory CachedFeedPost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFeedPost(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      userName: serializer.fromJson<String>(json['userName']),
      caption: serializer.fromJson<String?>(json['caption']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      mediaUrl: serializer.fromJson<String>(json['mediaUrl']),
      thumbnailUrl: serializer.fromJson<String>(json['thumbnailUrl']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      isLikedByMe: serializer.fromJson<bool>(json['isLikedByMe']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cacheOrder: serializer.fromJson<int>(json['cacheOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'userName': serializer.toJson<String>(userName),
      'caption': serializer.toJson<String?>(caption),
      'mediaType': serializer.toJson<String>(mediaType),
      'mediaUrl': serializer.toJson<String>(mediaUrl),
      'thumbnailUrl': serializer.toJson<String>(thumbnailUrl),
      'likeCount': serializer.toJson<int>(likeCount),
      'isLikedByMe': serializer.toJson<bool>(isLikedByMe),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cacheOrder': serializer.toJson<int>(cacheOrder),
    };
  }

  CachedFeedPost copyWith({
    String? id,
    String? userId,
    String? userName,
    Value<String?> caption = const Value.absent(),
    String? mediaType,
    String? mediaUrl,
    String? thumbnailUrl,
    int? likeCount,
    bool? isLikedByMe,
    DateTime? createdAt,
    int? cacheOrder,
  }) => CachedFeedPost(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    caption: caption.present ? caption.value : this.caption,
    mediaType: mediaType ?? this.mediaType,
    mediaUrl: mediaUrl ?? this.mediaUrl,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    likeCount: likeCount ?? this.likeCount,
    isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    createdAt: createdAt ?? this.createdAt,
    cacheOrder: cacheOrder ?? this.cacheOrder,
  );
  CachedFeedPost copyWithCompanion(CachedFeedPostsCompanion data) {
    return CachedFeedPost(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      userName: data.userName.present ? data.userName.value : this.userName,
      caption: data.caption.present ? data.caption.value : this.caption,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      mediaUrl: data.mediaUrl.present ? data.mediaUrl.value : this.mediaUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      isLikedByMe: data.isLikedByMe.present
          ? data.isLikedByMe.value
          : this.isLikedByMe,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cacheOrder: data.cacheOrder.present
          ? data.cacheOrder.value
          : this.cacheOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFeedPost(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('caption: $caption, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('likeCount: $likeCount, ')
          ..write('isLikedByMe: $isLikedByMe, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheOrder: $cacheOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
    cacheOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFeedPost &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.userName == this.userName &&
          other.caption == this.caption &&
          other.mediaType == this.mediaType &&
          other.mediaUrl == this.mediaUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.likeCount == this.likeCount &&
          other.isLikedByMe == this.isLikedByMe &&
          other.createdAt == this.createdAt &&
          other.cacheOrder == this.cacheOrder);
}

class CachedFeedPostsCompanion extends UpdateCompanion<CachedFeedPost> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> userName;
  final Value<String?> caption;
  final Value<String> mediaType;
  final Value<String> mediaUrl;
  final Value<String> thumbnailUrl;
  final Value<int> likeCount;
  final Value<bool> isLikedByMe;
  final Value<DateTime> createdAt;
  final Value<int> cacheOrder;
  final Value<int> rowid;
  const CachedFeedPostsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    this.caption = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.isLikedByMe = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cacheOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedFeedPostsCompanion.insert({
    required String id,
    required String userId,
    required String userName,
    this.caption = const Value.absent(),
    required String mediaType,
    required String mediaUrl,
    required String thumbnailUrl,
    required int likeCount,
    required bool isLikedByMe,
    required DateTime createdAt,
    required int cacheOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       userName = Value(userName),
       mediaType = Value(mediaType),
       mediaUrl = Value(mediaUrl),
       thumbnailUrl = Value(thumbnailUrl),
       likeCount = Value(likeCount),
       isLikedByMe = Value(isLikedByMe),
       createdAt = Value(createdAt),
       cacheOrder = Value(cacheOrder);
  static Insertable<CachedFeedPost> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? userName,
    Expression<String>? caption,
    Expression<String>? mediaType,
    Expression<String>? mediaUrl,
    Expression<String>? thumbnailUrl,
    Expression<int>? likeCount,
    Expression<bool>? isLikedByMe,
    Expression<DateTime>? createdAt,
    Expression<int>? cacheOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (userName != null) 'user_name': userName,
      if (caption != null) 'caption': caption,
      if (mediaType != null) 'media_type': mediaType,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (likeCount != null) 'like_count': likeCount,
      if (isLikedByMe != null) 'is_liked_by_me': isLikedByMe,
      if (createdAt != null) 'created_at': createdAt,
      if (cacheOrder != null) 'cache_order': cacheOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedFeedPostsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? userName,
    Value<String?>? caption,
    Value<String>? mediaType,
    Value<String>? mediaUrl,
    Value<String>? thumbnailUrl,
    Value<int>? likeCount,
    Value<bool>? isLikedByMe,
    Value<DateTime>? createdAt,
    Value<int>? cacheOrder,
    Value<int>? rowid,
  }) {
    return CachedFeedPostsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      caption: caption ?? this.caption,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
      cacheOrder: cacheOrder ?? this.cacheOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (isLikedByMe.present) {
      map['is_liked_by_me'] = Variable<bool>(isLikedByMe.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cacheOrder.present) {
      map['cache_order'] = Variable<int>(cacheOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFeedPostsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('caption: $caption, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('likeCount: $likeCount, ')
          ..write('isLikedByMe: $isLikedByMe, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheOrder: $cacheOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FeedLocalDatabase extends GeneratedDatabase {
  _$FeedLocalDatabase(QueryExecutor e) : super(e);
  $FeedLocalDatabaseManager get managers => $FeedLocalDatabaseManager(this);
  late final $CachedFeedPostsTable cachedFeedPosts = $CachedFeedPostsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cachedFeedPosts];
}

typedef $$CachedFeedPostsTableCreateCompanionBuilder =
    CachedFeedPostsCompanion Function({
      required String id,
      required String userId,
      required String userName,
      Value<String?> caption,
      required String mediaType,
      required String mediaUrl,
      required String thumbnailUrl,
      required int likeCount,
      required bool isLikedByMe,
      required DateTime createdAt,
      required int cacheOrder,
      Value<int> rowid,
    });
typedef $$CachedFeedPostsTableUpdateCompanionBuilder =
    CachedFeedPostsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> userName,
      Value<String?> caption,
      Value<String> mediaType,
      Value<String> mediaUrl,
      Value<String> thumbnailUrl,
      Value<int> likeCount,
      Value<bool> isLikedByMe,
      Value<DateTime> createdAt,
      Value<int> cacheOrder,
      Value<int> rowid,
    });

class $$CachedFeedPostsTableFilterComposer
    extends Composer<_$FeedLocalDatabase, $CachedFeedPostsTable> {
  $$CachedFeedPostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLikedByMe => $composableBuilder(
    column: $table.isLikedByMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cacheOrder => $composableBuilder(
    column: $table.cacheOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedFeedPostsTableOrderingComposer
    extends Composer<_$FeedLocalDatabase, $CachedFeedPostsTable> {
  $$CachedFeedPostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLikedByMe => $composableBuilder(
    column: $table.isLikedByMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cacheOrder => $composableBuilder(
    column: $table.cacheOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedFeedPostsTableAnnotationComposer
    extends Composer<_$FeedLocalDatabase, $CachedFeedPostsTable> {
  $$CachedFeedPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get mediaUrl =>
      $composableBuilder(column: $table.mediaUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<bool> get isLikedByMe => $composableBuilder(
    column: $table.isLikedByMe,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get cacheOrder => $composableBuilder(
    column: $table.cacheOrder,
    builder: (column) => column,
  );
}

class $$CachedFeedPostsTableTableManager
    extends
        RootTableManager<
          _$FeedLocalDatabase,
          $CachedFeedPostsTable,
          CachedFeedPost,
          $$CachedFeedPostsTableFilterComposer,
          $$CachedFeedPostsTableOrderingComposer,
          $$CachedFeedPostsTableAnnotationComposer,
          $$CachedFeedPostsTableCreateCompanionBuilder,
          $$CachedFeedPostsTableUpdateCompanionBuilder,
          (
            CachedFeedPost,
            BaseReferences<
              _$FeedLocalDatabase,
              $CachedFeedPostsTable,
              CachedFeedPost
            >,
          ),
          CachedFeedPost,
          PrefetchHooks Function()
        > {
  $$CachedFeedPostsTableTableManager(
    _$FeedLocalDatabase db,
    $CachedFeedPostsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedFeedPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedFeedPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedFeedPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> mediaUrl = const Value.absent(),
                Value<String> thumbnailUrl = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<bool> isLikedByMe = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> cacheOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedFeedPostsCompanion(
                id: id,
                userId: userId,
                userName: userName,
                caption: caption,
                mediaType: mediaType,
                mediaUrl: mediaUrl,
                thumbnailUrl: thumbnailUrl,
                likeCount: likeCount,
                isLikedByMe: isLikedByMe,
                createdAt: createdAt,
                cacheOrder: cacheOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String userName,
                Value<String?> caption = const Value.absent(),
                required String mediaType,
                required String mediaUrl,
                required String thumbnailUrl,
                required int likeCount,
                required bool isLikedByMe,
                required DateTime createdAt,
                required int cacheOrder,
                Value<int> rowid = const Value.absent(),
              }) => CachedFeedPostsCompanion.insert(
                id: id,
                userId: userId,
                userName: userName,
                caption: caption,
                mediaType: mediaType,
                mediaUrl: mediaUrl,
                thumbnailUrl: thumbnailUrl,
                likeCount: likeCount,
                isLikedByMe: isLikedByMe,
                createdAt: createdAt,
                cacheOrder: cacheOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedFeedPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$FeedLocalDatabase,
      $CachedFeedPostsTable,
      CachedFeedPost,
      $$CachedFeedPostsTableFilterComposer,
      $$CachedFeedPostsTableOrderingComposer,
      $$CachedFeedPostsTableAnnotationComposer,
      $$CachedFeedPostsTableCreateCompanionBuilder,
      $$CachedFeedPostsTableUpdateCompanionBuilder,
      (
        CachedFeedPost,
        BaseReferences<
          _$FeedLocalDatabase,
          $CachedFeedPostsTable,
          CachedFeedPost
        >,
      ),
      CachedFeedPost,
      PrefetchHooks Function()
    >;

class $FeedLocalDatabaseManager {
  final _$FeedLocalDatabase _db;
  $FeedLocalDatabaseManager(this._db);
  $$CachedFeedPostsTableTableManager get cachedFeedPosts =>
      $$CachedFeedPostsTableTableManager(_db, _db.cachedFeedPosts);
}
