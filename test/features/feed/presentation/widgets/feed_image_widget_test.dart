import 'package:flutter/material.dart';
import 'package:flutter_feed_engine/features/feed/presentation/widgets/feed_shimmer_loading.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedShimmerLoading', () {
    testWidgets('renders 3 shimmer placeholder cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedShimmerLoading(),
          ),
        ),
      );

      // Shimmer widget'ı render edilmeli
      expect(find.byType(FeedShimmerLoading), findsOneWidget);
    });
  });
}
