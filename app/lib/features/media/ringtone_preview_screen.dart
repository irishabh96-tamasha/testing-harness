import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/audio/audio_controller.dart';
import 'package:mobile_app/core/format/count_format.dart';
import 'package:mobile_app/features/media/media_controller.dart';
import 'package:mobile_app/features/media/media_models.dart';
import 'package:share_plus/share_plus.dart';

/// Native ringtone channel (see MainActivity.kt). Returns "ok",
/// "needs_permission" (WRITE_SETTINGS not granted — system screen opened), or
/// "failed".
const MethodChannel _ringtoneChannel = MethodChannel('tamasha/ringtone');

Future<String> _setDeviceRingtone(String url, String title) async {
  try {
    final String? r = await _ringtoneChannel.invokeMethod<String>(
      'setRingtone',
      <String, dynamic>{'url': url, 'title': title},
    );
    return r ?? 'failed';
  } catch (_) {
    return 'failed';
  }
}

/// Ringtone preview + "Set Ringtone" (Figma Ringtone-PREVIEW 683:4775 / share
/// sheet 683:5084): cover, stats, play/pause, set-as-ringtone, share.
class RingtonePreviewScreen extends ConsumerStatefulWidget {
  const RingtonePreviewScreen({required this.ringtone, super.key});

  final Ringtone ringtone;

  @override
  ConsumerState<RingtonePreviewScreen> createState() =>
      _RingtonePreviewScreenState();
}

class _RingtonePreviewScreenState extends ConsumerState<RingtonePreviewScreen> {
  late int _likes = widget.ringtone.likes;
  late int _shares = widget.ringtone.shares;
  late int _setCount = widget.ringtone.setCount;
  bool _played = false;
  bool _settingRingtone = false;

  void _toggleLike() {
    final Set<String> liked = ref.read(likedRingtoneProvider);
    final bool nowLiked = !liked.contains(widget.ringtone.id);
    final Set<String> next = <String>{...liked};
    if (nowLiked) {
      next.add(widget.ringtone.id);
    } else {
      next.remove(widget.ringtone.id);
    }
    ref.read(likedRingtoneProvider.notifier).state = next;
    setState(() => _likes += nowLiked ? 1 : -1);
    ref
        .read(mediaActionsProvider)
        .likeRingtone(id: widget.ringtone.id, liked: nowLiked);
  }

  void _togglePlay() {
    ref
        .read(audioControllerProvider.notifier)
        .toggle(widget.ringtone.id, widget.ringtone.audioUrl);
    if (!_played) {
      _played = true;
      ref.read(mediaActionsProvider).countRingtonePlay(widget.ringtone.id);
    }
  }

  void _share() {
    setState(() => _shares += 1);
    ref.read(mediaActionsProvider).shareRingtone(widget.ringtone.id);
    Share.share('Listen to "${widget.ringtone.title}" on Prabhuji 🙏');
  }

  Future<void> _setRingtone() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _settingRingtone = true);
    final String r = await _setDeviceRingtone(
      widget.ringtone.audioUrl,
      widget.ringtone.title,
    );
    if (!mounted) return;
    setState(() {
      _settingRingtone = false;
      if (r == 'ok') _setCount += 1;
    });
    if (r == 'ok') {
      ref.read(mediaActionsProvider).countRingtoneSet(widget.ringtone.id);
    }
    final String msg = switch (r) {
      'ok' => 'Ringtone set!',
      'needs_permission' =>
        'Allow "Modify system settings", then tap Set Ringtone again',
      _ => 'Could not set ringtone',
    };
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AudioState audio = ref.watch(audioControllerProvider);
    final bool isPlaying = audio.mediaId == widget.ringtone.id && audio.playing;
    final bool liked =
        ref.watch(likedRingtoneProvider).contains(widget.ringtone.id);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: <Widget>[
              const SizedBox(height: AppSpacing.sm),
              // Cover.
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    widget.ringtone.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AppColors.grey200),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                widget.ringtone.title,
                style: text.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.phone_in_talk,
                    size: 16,
                    color: AppColors.brand400,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${formatCount(_setCount)} ringtone set',
                    style: text.labelMedium?.copyWith(color: AppColors.grey400),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Stats.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _Stat(
                    icon: liked ? Icons.favorite : Icons.favorite_border,
                    iconColor: liked ? AppColors.brand400 : AppColors.grey500,
                    value: formatCount(_likes),
                    label: 'likes',
                    onTap: _toggleLike,
                  ),
                  _Stat(
                    icon: Icons.headphones,
                    value: formatCount(widget.ringtone.plays),
                    label: 'plays',
                  ),
                  _Stat(
                    icon: Icons.share_outlined,
                    value: formatCount(_shares),
                    label: 'shares',
                    onTap: _share,
                  ),
                ],
              ),
              const Spacer(),
              // Play / pause.
              GestureDetector(
                onTap: _togglePlay,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.brand100,
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.brand400,
                    size: 36,
                  ),
                ),
              ),
              const Spacer(),
              // Set Ringtone.
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _settingRingtone ? null : _setRingtone,
                  icon: _settingRingtone
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.phone_in_talk),
                  label: Text(_settingRingtone ? 'Setting…' : 'Set Ringtone'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand400,
                    foregroundColor: AppColors.white,
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color? iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Icon(icon, color: iconColor ?? AppColors.grey500, size: 22),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: text.titleMedium),
          Text(
            label,
            style: text.labelSmall?.copyWith(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}
