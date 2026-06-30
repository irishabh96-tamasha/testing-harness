import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The "All Gods" deity-selector avatar: the Prabhuji temple mark (Figma logo
/// 285:3485, a white circular badge with an orange temple + ring) rendered as a
/// vector. Shared by the Status, Wallpapers and Ringtones deity selectors so it
/// stays consistent instead of a stand-in Material icon.
class AllGodsAvatar extends StatelessWidget {
  const AllGodsAvatar({required this.radius, super.key});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/home/temple_logo.svg',
      width: radius * 2,
      height: radius * 2,
    );
  }
}
