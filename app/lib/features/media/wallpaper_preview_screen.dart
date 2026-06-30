import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// Full-screen wallpaper preview with a real "Set Wallpaper" action
/// (home / lock / both) via a native WallpaperManager channel.
class WallpaperPreviewScreen extends StatefulWidget {
  const WallpaperPreviewScreen({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  State<WallpaperPreviewScreen> createState() => _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState extends State<WallpaperPreviewScreen> {
  bool _busy = false;

  Future<void> _set(int location) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final bool ok = await _setDeviceWallpaper(widget.imageUrl, location);
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Wallpaper set!' : 'Could not set wallpaper'),
      ),
    );
  }

  void _chooseTarget() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home screen'),
              onTap: () {
                Navigator.pop(ctx);
                _set(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Lock screen'),
              onTap: () {
                Navigator.pop(ctx);
                _set(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('Both screens'),
              onTap: () {
                Navigator.pop(ctx);
                _set(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            widget.imageUrl,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _chooseTarget,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.wallpaper),
                    label: Text(_busy ? 'Setting…' : 'Set Wallpaper'),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: AppColors.white,
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
