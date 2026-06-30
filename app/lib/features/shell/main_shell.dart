import 'package:flutter/material.dart';
import 'package:mobile_app/features/feed/feed_screen.dart';
import 'package:mobile_app/features/feed/status_bottom_nav.dart';
import 'package:mobile_app/features/books/books_screen.dart';
import 'package:mobile_app/features/home/home_screen.dart';
import 'package:mobile_app/features/horoscope/horoscope_screen.dart';

/// App shell: an IndexedStack of the five bottom-nav tabs. Opens on Status
/// (index 1) to match the design. Non-built sections show a placeholder.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 1; // Status

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      const HomeScreen(),
      const FeedScreen(),
      const _ComingSoon('Mandir'),
      const HoroscopeScreen(),
      const BooksScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: StatusBottomNav(
        currentIndex: _index,
        onTap: (int i) => setState(() => _index = i),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title — coming soon',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
