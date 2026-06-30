import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/books/book_cover.dart';
import 'package:mobile_app/features/books/book_detail_screen.dart';
import 'package:mobile_app/features/books/books_controller.dart';
import 'package:mobile_app/features/books/books_models.dart';

/// Books tab (Figma 534:5061): book carousels + a "Browse Categories" grid.
class BooksScreen extends ConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Book>> books = ref.watch(booksProvider(null));
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: books.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(booksProvider(null)),
              child: const Text('Could not load books — Retry'),
            ),
          ),
          data: (List<Book> list) => ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Books',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              const _SectionHeader(title: 'Books', showAll: true),
              _BookCarousel(books: list),
              const _SectionHeader(title: 'Browse Categories'),
              const _CategoryGrid(),
              const _SectionHeader(title: 'Newly Added Books'),
              _BookCarousel(books: list.reversed.toList()),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.showAll = false});

  final String title;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (showAll)
            Text(
              'Show all',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.grey400),
            ),
        ],
      ),
    );
  }
}

class _BookCarousel extends StatelessWidget {
  const _BookCarousel({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (BuildContext context, int i) {
          final Book book = books[i];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BookDetailScreen(bookId: book.id),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BookCover(book: book),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: 120,
                  child: Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  static const List<(String, Color)> _cats = <(String, Color)>[
    ('Chalisa', Color(0xFF2B2622)),
    ('Aarti', Color(0xFFD89200)),
    ('Kavach', Color(0xFF4F5A1E)),
    ('Stotram', Color(0xFFC4451E)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 2.2,
        children: <Widget>[
          for (final (String label, Color color) in _cats)
            _CategoryTile(label: label, color: color),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CategoryBooksScreen(category: label),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Books filtered by a category (opened from a category tile).
class CategoryBooksScreen extends ConsumerWidget {
  const CategoryBooksScreen({required this.category, super.key});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Book>> books = ref.watch(booksProvider(category));
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: Text(category)),
      body: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(booksProvider(category)),
            child: const Text('Retry'),
          ),
        ),
        data: (List<Book> list) => list.isEmpty
            ? Center(
                child: Text(
                  'No books in $category yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(AppSpacing.md),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.55,
                children: <Widget>[
                  for (final Book book in list)
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BookDetailScreen(bookId: book.id),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          BookCover(book: book, width: 100, height: 150),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            book.title,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
