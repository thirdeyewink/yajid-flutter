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
import 'package:yajid/services/jailbreak_detection_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  final JailbreakDetectionService _jailbreakService = JailbreakDetectionService();
  bool _isLoggingOut = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricSupported = false;
  bool _isLoadingBiometricInfo = true;
  String _biometricDescription = '';

  // Device security state
  bool _isLoadingDeviceSecurity = true;
  DeviceSecurityStatus? _deviceSecurityStatus;

  @override
  void initState() {
    super.initState();
    _loadBiometricInfo();
    _loadDeviceSecurityInfo();
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

  Future<void> _loadDeviceSecurityInfo() async {
    try {
      final status = await _jailbreakService.checkDeviceSecurity();

      if (mounted) {
        setState(() {
          _deviceSecurityStatus = status;
          _isLoadingDeviceSecurity = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDeviceSecurity = false;
        });
      }
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

  void _showDeviceSecurityDetails() {
    if (_deviceSecurityStatus == null) {
      return;
    }

    final status = _deviceSecurityStatus!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              status.isCompromised
                  ? Icons.warning_amber_rounded
                  : Icons.verified_user,
              color: status.isCompromised ? Colors.orange : Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Device Security'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status
              Text(
                'Status: ${status.type.displayName}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: status.isCompromised ? Colors.orange : Colors.green,
                    ),
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                status.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Recommendation
              if (status.recommendation.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Recommendation',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  status.recommendation,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
              ],

              // Security implications
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Security Implications',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: status.isCompromised
                      ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.3)
                      : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          status.isCompromised ? Icons.block : Icons.check_circle,
                          size: 16,
                          color: status.isCompromised ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            status.isCompromised
                                ? 'Payment operations may be restricted'
                                : 'All operations are permitted',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          status.allowAppUsage ? Icons.check_circle : Icons.block,
                          size: 16,
                          color: status.allowAppUsage ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            status.allowAppUsage
                                ? 'App usage is permitted'
                                : 'App usage is blocked',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
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
            const SizedBox(height: 8),

            // Device Security Status
            Card(
              child: _isLoadingDeviceSecurity
                  ? const ListTile(
                      leading: Icon(Icons.security),
                      title: Text('Device Security'),
                      trailing: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ListTile(
                      leading: Icon(
                        _deviceSecurityStatus?.isCompromised == true
                            ? Icons.warning_amber_rounded
                            : Icons.verified_user,
                        color: _deviceSecurityStatus?.isCompromised == true
                            ? Colors.orange
                            : Colors.green,
                        size: 28,
                      ),
                      title: const Text('Device Security'),
                      subtitle: Text(
                        _deviceSecurityStatus?.message ?? 'Unable to check device security',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showDeviceSecurityDetails(),
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
