import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/feed/feed_models.dart';
import 'package:mobile_app/features/home/home_controller.dart';
import 'package:mobile_app/features/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders brand header and trending feed', (
    WidgetTester tester,
  ) async {
    // Use a phone-sized surface so the scrollable home content (header, search,
    // feature grid, then the "Trending" feed) lays out as it would on device.
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          homeBannersProvider.overrideWith((ref) async => <String>[]),
          homeFeedProvider.overrideWith(
            (ref) async => <HomeFeedItem>[
              const StatusFeedItem(
                StatusPost(
                  id: 'all-1',
                  deityId: 'all',
                  imageUrl: 'https://e.com/x.png',
                  authorName: 'Aditya Nath',
                  authorSubtitle: 'sub',
                  tagline: 'tag',
                  authorAvatarUrl: 'https://e.com/a.png',
                  likes: 24000,
                  views: 140000,
                ),
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prabhuji'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Aditya Nath'), findsOneWidget);
  });
}
