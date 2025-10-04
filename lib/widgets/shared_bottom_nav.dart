import 'package:flutter/material.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/theme/app_theme.dart';
import 'package:yajid/screens/main_navigation_screen.dart';

class SharedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const SharedBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  void _defaultOnTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // Default navigation behavior - navigate to MainNavigationScreen with the selected index
    // This ensures all main screens are accessed through the IndexedStack
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.bottomNavBackground,
      selectedItemColor: AppTheme.bottomNavSelectedItem,
      unselectedItemColor: AppTheme.bottomNavUnselectedItem,
      currentIndex: currentIndex,
      onTap: (index) => _defaultOnTap(context, index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: AppLocalizations.of(context)!.discover,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.add_circle_outline),
          label: AppLocalizations.of(context)!.add,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined),
          label: AppLocalizations.of(context)!.calendar,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: AppLocalizations.of(context)!.profile,
        ),
      ],
    );
  }
}