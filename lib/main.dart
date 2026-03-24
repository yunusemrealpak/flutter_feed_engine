import 'package:flutter/material.dart';
import 'package:flutter_feed_engine/app.dart';
import 'package:flutter_feed_engine/core/cache/memory_cache_config.dart';
import 'package:flutter_feed_engine/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memory image cache limitlerini ayarla
  MemoryCacheConfig.init();

  // Dependency injection kurulumu
  await configureDependencies();

  runApp(const FeedApp());
}
