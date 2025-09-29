import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/locale_provider.dart';
import 'package:yajid/theme_provider.dart';
import 'package:yajid/onboarding_provider.dart';
import 'package:yajid/auth_screen.dart';
import 'package:yajid/home_screen.dart';
import 'package:yajid/screens/chat_list_screen.dart';
import 'package:yajid/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  bool _isLoggingOut = false;
  int _currentIndex = 4; // Settings tab is index 4
  bool _isFabMenuOpen = false;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                leading: Radio<Locale>(
                  value: const Locale('en'),
                ),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Español'),
                leading: Radio<Locale>(
                  value: const Locale('es'),
                ),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(const Locale('es'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Français'),
                leading: Radio<Locale>(
                  value: const Locale('fr'),
                ),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(const Locale('fr'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('العربية'),
                leading: Radio<Locale>(
                  value: const Locale('ar'),
                ),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(const Locale('ar'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Português'),
                leading: Radio<Locale>(
                  value: const Locale('pt'),
                ),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(const Locale('pt'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
    });
    if (_isFabMenuOpen) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on tab
    switch (index) {
      case 0:
        // Recommendations - navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        // Messages - navigate to chat list screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ChatListScreen()),
        );
        break;
      case 2:
        // Add - navigate to add screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(AppLocalizations.of(context)!.addFeatureComingSoon)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 3:
        // Calendar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(AppLocalizations.of(context)!.calendarFeatureComingSoon)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 4:
        // Settings - already on settings screen
        break;
    }
  }

  void _onProfileTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _onFriendsTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(AppLocalizations.of(context)!.friendsFeatureComingSoon)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: _toggleFabMenu,
            ),
            IconButton(
              icon: const Icon(Icons.people_outline),
              onPressed: _onFriendsTap,
            ),
          ],
        ),
        leadingWidth: 120,
        title: Image.asset(
          'assets/images/logo.jpg',
          height: 64, // 80% of 80 = 64
          width: 64,  // 80% of 80 = 64
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // Notifications badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(child: Text(AppLocalizations.of(context)!.notificationsFeatureComingSoon)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Messages badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(child: Text(AppLocalizations.of(context)!.messagesFeatureComingSoon)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '7',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.appearance,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      title: Text(
                        themeProvider.isDarkMode
                            ? AppLocalizations.of(context)!.darkMode
                            : AppLocalizations.of(context)!.lightMode,
                      ),
                      subtitle: Text(
                        themeProvider.isDarkMode
                            ? AppLocalizations.of(context)!.switchToLightTheme
                            : AppLocalizations.of(context)!.switchToDarkTheme,
                      ),
                      trailing: Switch.adaptive(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.setDarkMode(value);
                        },
                        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Icon(Icons.dark_mode, color: Colors.black);
                          }
                          return const Icon(Icons.light_mode, color: Colors.black);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(AppLocalizations.of(context)!.selectLanguage),
                      subtitle: Text(_getLanguageName(localeProvider.locale)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showLanguageDialog(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.account,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: _isLoggingOut
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          )
                        : const Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                      title: Text(
                        _isLoggingOut ? AppLocalizations.of(context)!.loggingOut : AppLocalizations.of(context)!.logout,
                        style: TextStyle(
                          color: _isLoggingOut ? Colors.grey : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        _isLoggingOut
                          ? AppLocalizations.of(context)!.pleaseWait
                          : AppLocalizations.of(context)!.signOutOfYourAccount,
                        style: TextStyle(
                          color: _isLoggingOut ? Colors.grey : null,
                        ),
                      ),
                      trailing: _isLoggingOut
                        ? null
                        : const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.red,
                          ),
                      onTap: _isLoggingOut ? null : _showLogoutConfirmation,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isFabMenuOpen ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "friends",
            backgroundColor: Colors.blue,
            child: const Icon(Icons.people_outline, color: Colors.white),
            onPressed: _onFriendsTap,
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "profile",
            backgroundColor: Colors.green,
            child: const Icon(Icons.person, color: Colors.white),
            onPressed: _onProfileTap,
          ),
          const SizedBox(height: 10),
        ],
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.logoutDialogTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(AppLocalizations.of(context)!.logoutDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: Text(
                AppLocalizations.of(context)!.logout,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Reset onboarding status when logging out
      await Provider.of<OnboardingProvider>(context, listen: false).resetOnboarding();
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Show success feedback and navigate to auth screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('Successfully logged out')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to auth screen by removing all routes
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Error logging out: ${e.toString()}')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      case 'pt':
        return 'Português';
      default:
        return 'English';
    }
  }
}