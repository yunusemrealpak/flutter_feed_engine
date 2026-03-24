import 'package:flutter/painting.dart';
import 'package:flutter_feed_engine/core/constants/cache_constants.dart';

/// Flutter'ın dahili [ImageCache] ayarlarını yapılandırır.
///
/// `main.dart` içinde `WidgetsFlutterBinding.ensureInitialized()` sonrasında
/// çağrılmalıdır. Memory cache limitlerini artırarak feed deneyimini iyileştirir.
class MemoryCacheConfig {
  MemoryCacheConfig._();

  static void init() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = CacheConstants.memoryCacheMaxImages;
    imageCache.maximumSizeBytes = CacheConstants.memoryCacheMaxSizeBytes;
  }
}
