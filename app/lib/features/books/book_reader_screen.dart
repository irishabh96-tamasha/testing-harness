import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/audio/audio_controller.dart';
import 'package:mobile_app/features/books/books_models.dart';

/// Reader (Figma 620:3904): chapter text with Listen Audio, Previous/Next,
/// font-size toggle, and a table-of-contents drawer.
class BookReaderScreen extends ConsumerStatefulWidget {
  const BookReaderScreen({
    required this.chapters,
    required this.startIndex,
    super.key,
  });

  final List<Chapter> chapters;
  final int startIndex;

  @override
  ConsumerState<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends ConsumerState<BookReaderScreen> {
  late int _index = widget.startIndex;
  double _fontScale = 1.0;

  static const List<double> _scales = <double>[1.0, 1.2, 1.4];

  void _cycleFont() {
    setState(() {
      final int next = (_scales.indexOf(_fontScale) + 1) % _scales.length;
      _fontScale = _scales[next];
    });
  }

  void _go(int delta) => setState(() => _index = _index + delta);

  @override
  Widget build(BuildContext context) {
    final Chapter chapter = widget.chapters[_index];
    final AudioState audio = ref.watch(audioControllerProvider);
    final bool playingThis = audio.mediaId == chapter.id && audio.playing;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.brand100,
      endDrawer: _TocDrawer(
        chapters: widget.chapters,
        currentIndex: _index,
        onSelect: (int i) {
          Navigator.of(context).pop();
          setState(() => _index = i);
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.brand100,
        surfaceTintColor: AppColors.brand100,
        title: Text(chapter.section, style: text.titleMedium),
        actions: <Widget>[
          IconButton(
            tooltip: 'Text size',
            onPressed: _cycleFont,
            icon: const Icon(Icons.text_fields),
          ),
          Builder(
            builder: (BuildContext context) => IconButton(
              tooltip: 'Contents',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.list),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: <Widget>[
                Text(
                  chapter.title,
                  textAlign: TextAlign.center,
                  style: text.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: FilledButton.icon(
                    onPressed: () => ref
                        .read(audioControllerProvider.notifier)
                        .toggle(chapter.id, chapter.audioUrl),
                    icon: Icon(playingThis ? Icons.pause : Icons.play_arrow),
                    label: Text(playingThis ? 'Pause' : 'Listen Audio'),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  chapter.body,
                  style: text.bodyLarge?.copyWith(
                    height: 1.6,
                    fontSize: (text.bodyLarge?.fontSize ?? 16) * _fontScale,
                  ),
                ),
              ],
            ),
          ),
          _ReaderNav(
            onPrev: _index > 0 ? () => _go(-1) : null,
            onNext: _index < widget.chapters.length - 1 ? () => _go(1) : null,
          ),
        ],
      ),
    );
  }
}

class _ReaderNav extends StatelessWidget {
  const _ReaderNav({required this.onPrev, required this.onNext});

  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    ButtonStyle style(bool enabled) => FilledButton.styleFrom(
          backgroundColor: enabled ? primary : AppColors.grey300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Previous'),
                style: style(onPrev != null),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right, size: 18),
                label: const Text('Next'),
                style: style(onNext != null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TocDrawer extends StatelessWidget {
  const _TocDrawer({
    required this.chapters,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<Chapter> chapters;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Contents',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (BuildContext context, int i) {
                  final bool active = i == currentIndex;
                  return ListTile(
                    title: Text(chapters[i].title),
                    subtitle: Text(chapters[i].section),
                    selected: active,
                    selectedTileColor: AppColors.brand100,
                    leading: Icon(
                      Icons.menu_book,
                      color: active ? primary : AppColors.grey400,
                    ),
                    onTap: () => onSelect(i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
