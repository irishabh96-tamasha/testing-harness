import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a zodiac glyph from the Figma-exported SVGs in assets/zodiac/.
/// Pass [color] to recolor the (single-tone) glyph; omit to keep brand orange.
class ZodiacIcon extends StatelessWidget {
  const ZodiacIcon({
    required this.signId,
    this.size = 42,
    this.color,
    super.key,
  });

  final String signId;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/zodiac/$signId.svg',
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
