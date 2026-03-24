import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_feed_engine/core/constants/cache_constants.dart';

/// Scroll pozisyonundan visible index range hesaplayan yönetici.
///
/// ScrollController'ı dinleyerek hangi post'ların ekranda olduğunu hesaplar.
/// Debounce ile gereksiz event spam'ini engeller.
class FeedScrollManager {
  final ScrollController scrollController = ScrollController();

  /// Her post'un tahmini yüksekliği (piksel).
  /// Gerçek değer post içeriğine göre değişebilir, bu yaklaşık bir değer.
  final double estimatedItemHeight;

  Timer? _debounceTimer;

  /// Scroll değişikliği callback'i.
  final void Function(int firstVisible, int lastVisible)? onVisibleRangeChanged;

  FeedScrollManager({
    this.estimatedItemHeight = 500.0,
    this.onVisibleRangeChanged,
  }) {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(CacheConstants.scrollDebounce, () {
      _calculateVisibleRange();
    });
  }

  void _calculateVisibleRange() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    final viewportHeight = position.viewportDimension;
    final scrollOffset = position.pixels;

    final firstVisible = (scrollOffset / estimatedItemHeight).floor();
    final lastVisible =
        ((scrollOffset + viewportHeight) / estimatedItemHeight).ceil() - 1;

    final safeFirst = firstVisible.clamp(0, firstVisible);
    final safeLast = lastVisible.clamp(0, lastVisible);

    onVisibleRangeChanged?.call(safeFirst, safeLast);
  }

  void dispose() {
    _debounceTimer?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
  }
}
