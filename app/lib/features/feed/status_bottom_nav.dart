import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// Bottom navigation for the main shell (Figma node 302:4652).
class StatusBottomNav extends StatelessWidget {
  const StatusBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<(IconData, String)> items = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.track_changes, 'Status'),
    (Icons.account_balance, 'Mandir'),
    (Icons.auto_awesome_outlined, 'Horoscope'),
    (Icons.menu_book_outlined, 'Books'),
  ];

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadowXs,
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                _NavItem(
                  icon: items[i].$1,
                  label: items[i].$2,
                  color: i == currentIndex ? primary : AppColors.grey400,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 22, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
