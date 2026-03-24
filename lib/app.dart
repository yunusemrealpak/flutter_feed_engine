import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:flutter_feed_engine/features/feed/presentation/pages/feed_page.dart';
import 'package:get_it/get_it.dart';

/// Uygulamanın kök widget'ı.
///
/// BlocProvider ile FeedBloc'u widget ağacına sağlar.
class FeedApp extends StatelessWidget {
  const FeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feed Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      home: BlocProvider<FeedBloc>(
        create: (_) => GetIt.I<FeedBloc>(),
        child: const FeedPage(),
      ),
    );
  }
}
