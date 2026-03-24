import 'package:flutter/foundation.dart';
import 'package:flutter_feed_engine/core/constants/cache_constants.dart';
import 'package:video_player/video_player.dart';

/// Max N video player instance yöneten havuz.
///
/// Aynı anda en fazla [CacheConstants.maxVideoPlayerInstances] controller tutar.
/// Havuz dolduğunda aktif olmayan en eski controller dispose edilir (LRU eviction).
/// Tüm videolar loop modunda oynar.
class VideoPlayerPool {
  final Map<String, _VideoPlayerEntry> _pool = {};
  String? _activePostId;

  /// Şu an aktif (oynayan) post'un ID'si.
  String? get activePostId => _activePostId;

  /// Havuzdaki toplam controller sayısı.
  int get poolSize => _pool.length;

  /// Video controller'ı hazırlar, initialize eder, sesiz bekletir.
  ///
  /// Havuz doluysa aktif olmayan en eskiyi dispose eder.
  /// Initialize hatası olursa sessizce geçer — widget thumbnail gösterir.
  Future<void> prepareVideo(String postId, String videoUrl) async {
    // Zaten havuzda varsa tekrar oluşturma
    if (_pool.containsKey(postId)) {
      debugPrint('[VideoPlayerPool] $postId already in pool, skipping');
      return;
    }

    // Havuz doluysa yer aç
    if (_pool.length >= CacheConstants.maxVideoPlayerInstances) {
      _evictOldest();
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0); // Sessiz beklet

      _pool[postId] = _VideoPlayerEntry(
        controller: controller,
        createdAt: DateTime.now(),
      );

      debugPrint(
        '[VideoPlayerPool] Prepared $postId '
        '(pool size: ${_pool.length}/${CacheConstants.maxVideoPlayerInstances})',
      );
    } catch (e) {
      // Initialize hatası — sessizce geç, widget thumbnail gösterir
      debugPrint('[VideoPlayerPool] Failed to prepare $postId: $e');
    }
  }

  /// Belirtilen video'yu aktif yapar: öncekini pause + sessiz, yeniyi play + sesli.
  void setActive(String postId) {
    // Önceki aktifi durdur
    if (_activePostId != null && _activePostId != postId) {
      final prev = _pool[_activePostId];
      if (prev != null) {
        prev.controller.pause();
        prev.controller.setVolume(0);
      }
    }

    // Yeni aktifi başlat
    final entry = _pool[postId];
    if (entry != null) {
      entry.controller.play();
      entry.controller.setVolume(1);
      _activePostId = postId;
      debugPrint('[VideoPlayerPool] Active: $postId');
    }
  }

  /// Tüm controller'ları pause eder (app arka plana geçtiğinde).
  void pauseAll() {
    for (final entry in _pool.values) {
      entry.controller.pause();
    }
    _activePostId = null;
    debugPrint('[VideoPlayerPool] All paused');
  }

  /// Tek bir controller'ı dispose eder.
  void disposeVideo(String postId) {
    final entry = _pool.remove(postId);
    if (entry != null) {
      entry.controller.dispose();
      if (_activePostId == postId) {
        _activePostId = null;
      }
      debugPrint('[VideoPlayerPool] Disposed $postId');
    }
  }

  /// Tüm havuzu temizler.
  void disposeAll() {
    for (final entry in _pool.values) {
      entry.controller.dispose();
    }
    _pool.clear();
    _activePostId = null;
    debugPrint('[VideoPlayerPool] All disposed');
  }

  /// Widget'ın video göstermesi için controller döner.
  VideoPlayerController? getController(String postId) {
    return _pool[postId]?.controller;
  }

  /// Controller initialize olmuş ve kullanılabilir mi?
  bool isReady(String postId) {
    final entry = _pool[postId];
    return entry != null && entry.controller.value.isInitialized;
  }

  /// Memory pressure durumunda havuzu daraltır.
  /// Sadece aktif controller kalır, diğerleri dispose edilir.
  void evictNonActive() {
    final keysToRemove = <String>[];
    for (final key in _pool.keys) {
      if (key != _activePostId) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _pool[key]?.controller.dispose();
      _pool.remove(key);
    }
    debugPrint(
      '[VideoPlayerPool] Evicted non-active. '
      'Remaining: ${_pool.length}',
    );
  }

  /// Aktif olmayan en eski entry'yi dispose eder (LRU eviction).
  void _evictOldest() {
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _pool.entries) {
      // Aktif video'yu evict etme
      if (entry.key == _activePostId) continue;

      if (oldestTime == null || entry.value.createdAt.isBefore(oldestTime)) {
        oldestTime = entry.value.createdAt;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      disposeVideo(oldestKey);
      debugPrint('[VideoPlayerPool] Evicted oldest: $oldestKey');
    }
  }
}

/// Havuzdaki bir video player entry'si.
class _VideoPlayerEntry {
  final VideoPlayerController controller;
  final DateTime createdAt;

  _VideoPlayerEntry({required this.controller, required this.createdAt});
}
