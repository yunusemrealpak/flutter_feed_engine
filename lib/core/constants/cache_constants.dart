/// Uygulama genelinde kullanılan cache, timeout ve threshold sabitleri.
///
/// Magic number kullanımını engellemek için tüm sabit değerler bu dosyada toplanır.
class CacheConstants {
  CacheConstants._();

  // ---------------------------------------------------------------------------
  // Memory Image Cache
  // ---------------------------------------------------------------------------
  static const int memoryCacheMaxImages = 100;
  static const int memoryCacheMaxSizeBytes = 80 * 1024 * 1024; // 80 MB

  // ---------------------------------------------------------------------------
  // Disk Image Cache
  // ---------------------------------------------------------------------------
  static const Duration diskCacheStalePeriod = Duration(days: 14);
  static const int diskCacheMaxObjects = 500;
  static const String diskCacheKey = 'feedImageCache';

  // ---------------------------------------------------------------------------
  // Avatar Cache
  // ---------------------------------------------------------------------------
  static const Duration avatarCacheStalePeriod = Duration(days: 1);
  static const int avatarCacheMaxObjects = 200;
  static const String avatarCacheKey = 'avatarCache';

  // ---------------------------------------------------------------------------
  // Video Player Pool
  // ---------------------------------------------------------------------------
  static const int maxVideoPlayerInstances = 3;
  static const double videoVisibilityThreshold = 0.50; // %50

  // ---------------------------------------------------------------------------
  // Prefetch
  // ---------------------------------------------------------------------------
  static const int wifiPrefetchAhead = 5;
  static const int cellularPrefetchAhead = 2;
  static const int maxConcurrentImageDownloads = 3;

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------
  static const int pageSize = 10;
  static const int totalMockPosts = 50;
  static const int loadMoreThreshold = 3; // son N post'a yaklaşınca yükle

  // ---------------------------------------------------------------------------
  // Network Simulation
  // ---------------------------------------------------------------------------
  static const Duration minApiDelay = Duration(milliseconds: 500);
  static const Duration maxApiDelay = Duration(milliseconds: 1500);
  static const Duration likeApiDelay = Duration(milliseconds: 200);
  static const double likeErrorRate = 0.05; // %5

  // ---------------------------------------------------------------------------
  // Scroll Debounce
  // ---------------------------------------------------------------------------
  static const Duration scrollDebounce = Duration(milliseconds: 100);
}
