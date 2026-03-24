import 'package:get_it/get_it.dart';
import 'package:flutter_feed_engine/core/network/connectivity_manager.dart';
import 'package:flutter_feed_engine/features/feed/data/datasources/feed_local_data_source.dart';
import 'package:flutter_feed_engine/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:flutter_feed_engine/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:flutter_feed_engine/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_feed_engine/features/feed/domain/usecases/get_feed_usecase.dart';
import 'package:flutter_feed_engine/features/feed/domain/usecases/refresh_feed_usecase.dart';
import 'package:flutter_feed_engine/features/feed/domain/usecases/toggle_like_usecase.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:flutter_feed_engine/features/feed/presentation/managers/video_player_pool.dart';

/// GetIt ile dependency injection kurulumu.
///
/// Manuel registration: injectable code generation yerine doğrudan kayıt.
/// Katmanlı kayıt sırası: Core → Data → Domain → Presentation.
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ---------------------------------------------------------------------------
  // Core
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<ConnectivityManager>(
    () => ConnectivityManager(),
  );

  // ---------------------------------------------------------------------------
  // Data Sources
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSource(),
  );

  getIt.registerLazySingleton<FeedLocalDatabase>(
    () => FeedLocalDatabase(),
  );

  // ---------------------------------------------------------------------------
  // Repositories
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(
      remoteDataSource: getIt<FeedRemoteDataSource>(),
      localDatabase: getIt<FeedLocalDatabase>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Use Cases
  // ---------------------------------------------------------------------------
  getIt.registerFactory<GetFeedUseCase>(
    () => GetFeedUseCase(getIt<FeedRepository>()),
  );

  getIt.registerFactory<RefreshFeedUseCase>(
    () => RefreshFeedUseCase(getIt<FeedRepository>()),
  );

  getIt.registerFactory<ToggleLikeUseCase>(
    () => ToggleLikeUseCase(getIt<FeedRepository>()),
  );

  // ---------------------------------------------------------------------------
  // Presentation
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<VideoPlayerPool>(
    () => VideoPlayerPool(),
  );

  getIt.registerFactory<FeedBloc>(
    () => FeedBloc(
      getFeed: getIt<GetFeedUseCase>(),
      refreshFeed: getIt<RefreshFeedUseCase>(),
      toggleLike: getIt<ToggleLikeUseCase>(),
      connectivityManager: getIt<ConnectivityManager>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------
  await getIt<ConnectivityManager>().initialize();
}
