import 'package:flutter/material.dart';

class AppTheme {
  // App Bar Colors
  static const Color appBarBackground = Colors.black;
  static const Color appBarForeground = Colors.white;

  // Screen Background
  static const Color screenBackground = Colors.white;

  // Bottom Navigation Colors
  static const Color bottomNavBackground = Colors.black;
  static const Color bottomNavSelectedItem = Colors.yellow;
  static const Color bottomNavUnselectedItem = Colors.white70;

  // Logo
  static const String logoAssetPath = 'assets/images/dark_yajid_logo.png';
  static const double logoSize = 120.0; // Standard size for app bar logo

  // Common Paddings
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);

  // Common Sizes
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;

  // Icon Theme
  static const IconThemeData appBarIconTheme = IconThemeData(
    color: appBarForeground,
  );

  // Standard AppBar
  static AppBar buildAppBar({
    Widget? leading,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: leading,
      title: title,
      backgroundColor: appBarBackground,
      foregroundColor: appBarForeground,
      iconTheme: appBarIconTheme,
      elevation: 1,
      actions: actions,
      bottom: bottom,
    );
  }

  // Standard Logo Widget
  static Widget buildLogo({
    double? size,
    VoidCallback? onTap,
  }) {
    final logoWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        logoAssetPath,
        width: size ?? logoSize,
        height: size ?? logoSize,
        fit: BoxFit.contain,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: logoWidget,
      );
    }

    return logoWidget;
  }
}