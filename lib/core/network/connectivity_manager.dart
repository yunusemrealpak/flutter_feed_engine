import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Ağ bağlantı durumunu temsil eden enum.
enum ConnectivityStatus {
  wifi,
  cellular,
  slow,
  offline,
}

/// Ağ durumunu izleyen ve stream olarak dışarıya açan yönetici sınıf.
///
/// `connectivity_plus` paketini sarmalayarak domain'e bağımlılık oluşturmaz.
/// BLoC bu sınıfın stream'ine subscribe olarak ağ değişikliklerini takip eder.
class ConnectivityManager {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _controller = StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.offline;

  ConnectivityManager({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Mevcut bağlantı durumu.
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Bağlantı değişikliklerini dinleyen stream.
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  /// Dinlemeyi başlatır. App başlangıcında çağrılmalıdır.
  Future<void> initialize() async {
    // Mevcut durumu al
    final results = await _connectivity.checkConnectivity();
    _currentStatus = _mapResults(results);
    _controller.add(_currentStatus);

    // Değişiklikleri dinle
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final newStatus = _mapResults(results);
      if (newStatus != _currentStatus) {
        _currentStatus = newStatus;
        _controller.add(newStatus);
        debugPrint('[ConnectivityManager] Status changed: $newStatus');
      }
    });
  }

  /// [ConnectivityResult] listesini [ConnectivityStatus]'a çevirir.
  ConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityStatus.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityStatus.cellular;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityStatus.wifi; // ethernet ≈ wifi performansı
    }
    return ConnectivityStatus.offline;
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
