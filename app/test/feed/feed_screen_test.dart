import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/feed/feed_controller.dart';
import 'package:mobile_app/features/feed/feed_models.dart';
import 'package:mobile_app/features/feed/feed_screen.dart';

const List<Deity> _deities = <Deity>[
  Deity(id: 'all', name: 'All Gods', imageUrl: 'https://e.com/all.png'),
  Deity(id: 'ram', name: 'Ram ji', imageUrl: 'https://e.com/ram.png'),
];

StatusPost _sp(String id, String author, int likes, {String deityId = 'all'}) =>
    StatusPost(
      id: id,
      deityId: deityId,
      imageUrl: 'https://e.com/$id.png',
      authorName: author,
      authorSubtitle: 'sub',
      tagline: 'tag',
      authorAvatarUrl: 'https://e.com/$id-a.png',
      likes: likes,
      views: 1000,
    );

/// No-op engagement actions so like/view taps never touch the network.
class _FakeActions implements StatusActions {
  @override
  Future<void> setLike({
    required String id,
    required String deityId,
    required bool liked,
  }) async {}

  @override
  Future<void> recordView(String id) async {}
}

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: <Override>[
        statusActionsProvider.overrideWithValue(_FakeActions()),
        ...overrides,
      ],
      child: const MaterialApp(home: FeedScreen()),
    );

// statuses differ per deity so we can prove the content is data-driven.
Override _statusOverride() =>
    statusListProvider.overrideWith((ref, String id) async {
      if (id == 'ram') {
        return <StatusPost>[_sp('r1', 'Ram Author', 5, deityId: 'ram')];
      }
      return <StatusPost>[
        _sp('a1', 'Author One', 24000),
        _sp('a2', 'Author Two', 8000),
      ];
    });

void main() {
  testWidgets('shows the first deity\'s first status', (tester) async {
    await tester.pumpWidget(
      _wrap(<Override>[
        feedProvider.overrideWith((ref) async => _deities),
        _statusOverride(),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('All Gods'), findsOneWidget);
    expect(find.text('Author One'), findsOneWidget);
  });

  testWidgets('Next cycles to the next status', (tester) async {
    await tester.pumpWidget(
      _wrap(<Override>[
        feedProvider.overrideWith((ref) async => _deities),
        _statusOverride(),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Author Two'), findsOneWidget);
  });

  testWidgets('selecting a deity loads that deity\'s status', (tester) async {
    await tester.pumpWidget(
      _wrap(<Override>[
        feedProvider.overrideWith((ref) async => _deities),
        _statusOverride(),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ram ji'));
    await tester.pumpAndSettle();
    expect(find.text('Ram Author'), findsOneWidget);
  });

  testWidgets('tapping the heart toggles the like', (tester) async {
    await tester.pumpWidget(
      _wrap(<Override>[
        feedProvider.overrideWith((ref) async => _deities),
        _statusOverride(),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('shows retry when the deity feed errors', (tester) async {
    await tester.pumpWidget(
      _wrap(<Override>[
        feedProvider.overrideWith((ref) async => throw Exception('boom')),
        _statusOverride(),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });
}
