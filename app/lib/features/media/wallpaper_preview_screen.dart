import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/format/count_format.dart';
import 'package:mobile_app/features/media/media_controller.dart';
import 'package:mobile_app/features/media/media_models.dart';
import 'package:share_plus/share_plus.dart';

/// Native wallpaper channel (see MainActivity.kt). Locations: 1=home, 2=lock,
/// 3=both. Returns true on success.
const MethodChannel _wallpaperChannel = MethodChannel('tamasha/wallpaper');

Future<bool> _setDeviceWallpaper(String url, int location) async {
  try {
    final bool? ok = await _wallpaperChannel.invokeMethod<bool>(
      'setWallpaper',
      <String, dynamic>{'url': url, 'location': location},
    );
    return ok ?? false;
  } catch (_) {
    return false;
  }
}

/// Full-screen wallpaper preview (Figma Static 282:2812 / Live 712:6622):
/// like + share overlay, "WALLPAPER SET N TIMES" caption, and Set Wallpaper /
/// Set Lockscreen actions via a native WallpaperManager channel.
class WallpaperPreviewScreen extends ConsumerStatefulWidget {
  const WallpaperPreviewScreen({required this.wallpaper, super.key});

  final Wallpaper wallpaper;

  @override
  ConsumerState<WallpaperPreviewScreen> createState() =>
      _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState
    extends ConsumerState<WallpaperPreviewScreen> {
  late int _likes = widget.wallpaper.likes;
  late int _shares = widget.wallpaper.shares;
  late int _setCount = widget.wallpaper.setCount;
  int _busy = 0; // 0 = idle, else the location being applied

  void _toggleLike() {
    final Set<String> liked = ref.read(likedWallpaperProvider);
    final bool nowLiked = !liked.contains(widget.wallpaper.id);
    final Set<String> next = <String>{...liked};
    if (nowLiked) {
      next.add(widget.wallpaper.id);
    } else {
      next.remove(widget.wallpaper.id);
    }
    ref.read(likedWallpaperProvider.notifier).state = next;
    setState(() => _likes += nowLiked ? 1 : -1);
    ref
        .read(mediaActionsProvider)
        .likeWallpaper(id: widget.wallpaper.id, liked: nowLiked);
  }

  void _share() {
    setState(() => _shares += 1);
    ref.read(mediaActionsProvider).shareWallpaper(widget.wallpaper.id);
    Share.share('Divine wallpaper from Prabhuji 🙏');
  }

  Future<void> _set(int location) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = location);
    final bool ok =
        await _setDeviceWallpaper(widget.wallpaper.imageUrl, location);
    if (!mounted) return;
    setState(() {
      _busy = 0;
      if (ok) _setCount += 1;
    });
    if (ok) {
      ref.read(mediaActionsProvider).countWallpaperSet(widget.wallpaper.id);
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Wallpaper set!' : 'Could not set wallpaper'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool liked =
        ref.watch(likedWallpaperProvider).contains(widget.wallpaper.id);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            widget.wallpaper.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: AppColors.grey500),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: Icon(Icons.arrow_back, color: AppColors.white),
                ),
              ),
            ),
          ),
          // Right-side like + share overlay.
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _OverlayAction(
                    icon: liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? AppColors.brand400 : AppColors.white,
                    label: formatCount(_likes),
                    onTap: _toggleLike,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _OverlayAction(
                    icon: Icons.share,
                    color: AppColors.white,
                    label: formatCount(_shares),
                    onTap: _share,
                  ),
                ],
              ),
            ),
          ),
          // Bottom caption + set actions.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'WALLPAPER SET ${formatCount(_setCount)} TIMES',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (widget.wallpaper.isLive)
                      _SetButton(
                        label: 'Set Wallpaper',
                        busy: _busy == 3,
                        onTap: _busy == 0 ? () => _set(3) : null,
                      )
                    else
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _SetButton(
                              label: 'Set Wallpaper',
                              busy: _busy == 1,
                              onTap: _busy == 0 ? () => _set(1) : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _SetButton(
                              label: 'Set Lockscreen',
                              busy: _busy == 2,
                              onTap: _busy == 0 ? () => _set(2) : null,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayAction extends StatelessWidget {
  const _OverlayAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.black38,
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(color: AppColors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SetButton extends StatelessWidget {
  const _SetButton({required this.label, required this.busy, this.onTap});

  final String label;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.brand400,
          shape: const StadiumBorder(),
        ),
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brand400,
                ),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
