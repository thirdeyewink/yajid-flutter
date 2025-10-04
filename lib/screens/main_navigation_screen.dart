import 'package:flutter/material.dart';
import 'package:yajid/home_screen.dart';
import 'package:yajid/screens/discover_screen.dart';
import 'package:yajid/screens/add_content_screen.dart';
import 'package:yajid/screens/calendar_screen.dart';
import 'package:yajid/profile_screen.dart';
import 'package:yajid/widgets/shared_bottom_nav.dart';

/// Main navigation screen using IndexedStack to preserve state across tabs
/// This prevents screens from being recreated when switching tabs
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  // List of screens to display in the navigation
  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    AddContentScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all screens in memory and switches visibility
      // This preserves state when switching between tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SharedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
