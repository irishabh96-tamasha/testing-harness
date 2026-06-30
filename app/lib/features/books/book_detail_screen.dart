import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/books/book_cover.dart';
import 'package:mobile_app/features/books/book_reader_screen.dart';
import 'package:mobile_app/features/books/books_controller.dart';
import 'package:mobile_app/features/books/books_models.dart';

/// Book contents (Figma 639:3947): cover, "Start Reading", and the sections
/// (Kandas) with chapter counts.
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({required this.bookId, super.key});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BookDetail> detail = ref.watch(bookDetailProvider(bookId));
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(bookDetailProvider(bookId)),
            child: const Text('Could not load book — Retry'),
          ),
        ),
        data: (BookDetail d) => _Contents(detail: d),
      ),
    );
  }
}

class _Contents extends StatelessWidget {
  const _Contents({required this.detail});

  final BookDetail detail;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    // Group chapters by section, preserving order.
    final List<MapEntry<String, List<Chapter>>> sections =
        <MapEntry<String, List<Chapter>>>[];
    for (final Chapter c in detail.chapters) {
      if (sections.isEmpty || sections.last.key != c.section) {
        sections.add(MapEntry<String, List<Chapter>>(c.section, <Chapter>[c]));
      } else {
        sections.last.value.add(c);
      }
    }

    void openReaderAt(int index) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BookReaderScreen(
            chapters: detail.chapters,
            startIndex: index,
          ),
        ),
      );
    }

    int runningIndex = 0;
    final List<Widget> sectionTiles = <Widget>[];
    for (int i = 0; i < sections.length; i++) {
      final MapEntry<String, List<Chapter>> s = sections[i];
      final int startIndex = runningIndex;
      runningIndex += s.value.length;
      sectionTiles.add(
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          title: Text('${i + 1}. ${s.key}', style: text.bodyLarge),
          trailing: Text(
            '${s.value.length} chapters',
            style: text.labelMedium?.copyWith(color: AppColors.grey400),
          ),
          onTap: () => openReaderAt(startIndex),
        ),
      );
    }

    return ListView(
      children: <Widget>[
        const SizedBox(height: AppSpacing.sm),
        Center(child: BookCover(book: detail.book, width: 132, height: 188)),
        const SizedBox(height: AppSpacing.md),
        Center(child: Text(detail.book.title, style: text.titleMedium)),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(
            detail.book.author,
            style: text.labelMedium?.copyWith(color: AppColors.grey400),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: FilledButton(
            onPressed: detail.chapters.isEmpty ? null : () => openReaderAt(0),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm + 2,
              ),
            ),
            child: const Text('Start Reading'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Divider(height: 1),
        ...sectionTiles,
      ],
    );
  }
}
