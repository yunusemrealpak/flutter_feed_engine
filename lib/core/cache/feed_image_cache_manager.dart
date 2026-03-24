import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_feed_engine/core/constants/cache_constants.dart';

/// Feed görselleri için özelleştirilmiş disk cache yöneticisi.
///
/// Singleton pattern ile tek instance çalışır.
/// 14 gün stale period, max 500 obje tutar.
class FeedImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = CacheConstants.diskCacheKey;

  static final FeedImageCacheManager _instance = FeedImageCacheManager._();
  factory FeedImageCacheManager() => _instance;

  FeedImageCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: CacheConstants.diskCacheStalePeriod,
            maxNrOfCacheObjects: CacheConstants.diskCacheMaxObjects,
          ),
        );
}

/// Profil avatar'ları için ayrı disk cache yöneticisi.
///
/// Avatar'lar daha sık değiştiği için stale period 1 gün,
/// max 200 obje tutulur.
class AvatarCacheManager extends CacheManager with ImageCacheManager {
  static const key = CacheConstants.avatarCacheKey;

  static final AvatarCacheManager _instance = AvatarCacheManager._();
  factory AvatarCacheManager() => _instance;

  AvatarCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: CacheConstants.avatarCacheStalePeriod,
            maxNrOfCacheObjects: CacheConstants.avatarCacheMaxObjects,
          ),
        );
}
