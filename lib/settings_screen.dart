import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/locale_provider.dart';
import 'package:yajid/theme_provider.dart';
import 'package:yajid/onboarding_provider.dart';
import 'package:yajid/auth_screen.dart';
import 'package:yajid/screens/admin_seed_screen.dart';
import 'package:yajid/services/biometric_auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isLoggingOut = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricSupported = false;
  bool _isLoadingBiometricInfo = true;
  String _biometricDescription = '';

  @override
  void initState() {
    super.initState();
    _loadBiometricInfo();
  }

  Future<void> _loadBiometricInfo() async {
    final isSupported = await _biometricService.isDeviceSupported();
    final isEnabled = await _biometricService.isBiometricEnabled();
    final description = await _biometricService.getBiometricDescription();

    if (mounted) {
      setState(() {
        _isBiometricSupported = isSupported;
        _isBiometricEnabled = isEnabled;
        _biometricDescription = description;
        _isLoadingBiometricInfo = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_isBiometricSupported) {
      _showBiometricNotSupportedDialog();
      return;
    }

    // If enabling, authenticate first to verify biometrics work
    if (value) {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Enable biometric authentication for sensitive operations',
      );

      if (!authenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(child: Text('Biometric authentication failed')),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    final success = await _biometricService.setBiometricEnabled(value);

    if (success && mounted) {
      setState(() {
        _isBiometricEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              value
                  ? 'Biometric authentication enabled'
                  : 'Biometric authentication disabled',
            ),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Failed to update biometric settings')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBiometricNotSupportedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Not Available'),
        content: const Text(
          'Your device does not support biometric authentication or no biometrics are enrolled.\n\n'
          'Please set up Face ID, Touch ID, or Fingerprint in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: RadioGroup<Locale>(
            groupValue: Provider.of<LocaleProvider>(context).locale,
            onChanged: (Locale? value) {
              if (value != null) {
                localeProvider.setLocale(value);
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<Locale>(
                  title: const Text('English'),
                  value: const Locale('en'),
                ),
                RadioListTile<Locale>(
                  title: const Text('Español'),
                  value: const Locale('es'),
                ),
                RadioListTile<Locale>(
                  title: const Text('Français'),
                  value: const Locale('fr'),
                ),
                RadioListTile<Locale>(
                  title: const Text('العربية'),
                  value: const Locale('ar'),
                ),
                RadioListTile<Locale>(
                  title: const Text('Português'),
                  value: const Locale('pt'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.selectLanguage),
                subtitle: Text(_getLanguageName(localeProvider.locale)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLanguageDialog(context),
              ),
            ),
            const SizedBox(height: 16),

            // Theme Section
            Card(
              child: SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                title: Text(AppLocalizations.of(context)!.darkMode),
                subtitle: Text(
                  themeProvider.isDarkMode
                      ? 'Dark theme enabled'
                      : 'Light theme enabled',
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
            const SizedBox(height: 16),

            // Security Section
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: _isLoadingBiometricInfo
                  ? const ListTile(
                      leading: Icon(Icons.fingerprint),
                      title: Text('Biometric Authentication'),
                      trailing: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : SwitchListTile(
                      secondary: Icon(
                        _isBiometricSupported
                            ? Icons.fingerprint
                            : Icons.fingerprint_outlined,
                        color: _isBiometricSupported ? Colors.green : Colors.grey,
                      ),
                      title: const Text('Biometric Authentication'),
                      subtitle: Text(
                        _isBiometricSupported
                            ? _isBiometricEnabled
                                ? 'Enabled · $_biometricDescription'
                                : 'Disabled · $_biometricDescription'
                            : 'Not available on this device',
                      ),
                      value: _isBiometricEnabled && _isBiometricSupported,
                      onChanged: _isBiometricSupported ? _toggleBiometric : null,
                    ),
            ),
            const SizedBox(height: 16),

            // Developer Section
            const Text(
              'Developer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_upload, color: Colors.blue),
                title: const Text('Seed Recommendations Data'),
                subtitle: const Text('Add initial sample data to Firestore'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminSeedScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Account Section
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    subtitle: Text(FirebaseAuth.instance.currentUser?.email ?? 'Not logged in'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: _isLoggingOut ? Colors.grey : Colors.red,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.logout,
                      style: TextStyle(
                        color: _isLoggingOut ? Colors.grey : Colors.red,
                      ),
                    ),
                    enabled: !_isLoggingOut,
                    onTap: _isLoggingOut ? null : () => _logout(context),
                    trailing: _isLoggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  void _logout(BuildContext context) async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      // Reset onboarding state
      if (context.mounted) {
        Provider.of<OnboardingProvider>(context, listen: false).resetOnboarding();

        // Navigate to auth screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text('Logout failed: $e'),
            ),
            backgroundColor: Colors.red,
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
}
