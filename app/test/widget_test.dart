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
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          homeFeedProvider.overrideWith(
            (ref) async => <StatusPost>[
              const StatusPost(
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
