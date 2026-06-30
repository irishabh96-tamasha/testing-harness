import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/books/books_models.dart';

/// A book cover: bundled Figma art when available, else the network cover.
class BookCover extends StatelessWidget {
  const BookCover({
    required this.book,
    this.width = 120,
    this.height = 176,
    super.key,
  });

  final Book book;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String? asset = book.coverAsset;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadowXs,
            blurRadius: 16,
            offset: Offset(-4, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: asset != null
          ? Image.asset(asset, fit: BoxFit.cover)
          : Image.network(
              book.coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: AppColors.grey200),
            ),
    );
  }
}
