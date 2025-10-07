import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:yajid/core/utils/secure_storage.dart';

/// Biometric authentication service using local_auth
///
/// Supports:
/// - iOS: Face ID, Touch ID
/// - Android: Fingerprint, Face unlock
/// - Secure fallback to device credentials (PIN/Pattern/Password)
class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final SecureStorageService _secureStorage = SecureStorageService();
  static final Logger _logger = Logger();

  factory BiometricAuthService() => _instance;

  BiometricAuthService._internal();

  /// Check if biometric authentication is available on this device
  Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      _logger.d('BiometricAuth: Device can check biometrics: $canCheck');
      return canCheck;
    } on PlatformException catch (e) {
      _logger.e('BiometricAuth: Error checking biometric capability', error: e);
      return false;
    }
  }

  /// Check if device has biometrics OR device credentials (PIN/Pattern)
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      _logger.d('BiometricAuth: Device is supported: $isSupported');
      return isSupported;
    } on PlatformException catch (e) {
      _logger.e('BiometricAuth: Error checking device support', error: e);
      return false;
    }
  }

  /// Get list of available biometric types
  /// Returns: [BiometricType.face, BiometricType.fingerprint, etc.]
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      _logger.d('BiometricAuth: Available biometrics: $availableBiometrics');
      return availableBiometrics;
    } on PlatformException catch (e) {
      _logger.e('BiometricAuth: Error getting available biometrics', error: e);
      return [];
    }
  }

  /// Check if user has enabled biometric authentication in app settings
  Future<bool> isBiometricEnabled() async {
    return await _secureStorage.isBiometricEnabled();
  }

  /// Enable/disable biometric authentication in app settings
  Future<bool> setBiometricEnabled(bool enabled) async {
    final success = await _secureStorage.setBiometricEnabled(enabled);
    if (success) {
      _logger.d('BiometricAuth: Biometric auth ${enabled ? 'enabled' : 'disabled'}');
    }
    return success;
  }

  /// Authenticate user with biometrics
  ///
  /// Parameters:
  /// - [localizedReason]: Message shown to user (required by iOS)
  /// - [useErrorDialogs]: Show error dialogs (default: true)
  /// - [stickyAuth]: Keep auth session alive (default: true)
  /// - [biometricOnly]: Don't allow fallback to PIN/Password (default: false)
  ///
  /// Returns: true if authentication successful, false otherwise
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    try {
      // Check if device supports biometric auth
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        _logger.w('BiometricAuth: Device does not support biometric authentication');
        return false;
      }

      // Check if biometric is enabled in app settings
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        _logger.i('BiometricAuth: Biometric auth is disabled in settings');
        return false;
      }

      // Authenticate
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      if (didAuthenticate) {
        _logger.d('BiometricAuth: Authentication successful');
      } else {
        _logger.w('BiometricAuth: Authentication failed');
      }

      return didAuthenticate;
    } on PlatformException catch (e) {
      return _handleAuthenticationError(e);
    } catch (e) {
      _logger.e('BiometricAuth: Unexpected error during authentication', error: e);
      return false;
    }
  }

  /// Authenticate with biometric ONLY (no PIN/Password fallback)
  ///
  /// Use this for highly sensitive operations where device credential
  /// fallback is not acceptable (e.g., viewing private keys)
  Future<bool> authenticateBiometricOnly({
    required String localizedReason,
  }) async {
    return authenticate(
      localizedReason: localizedReason,
      biometricOnly: true,
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  /// Authenticate with biometric OR device credentials (PIN/Password)
  ///
  /// Use this for general sensitive operations where fallback to
  /// device credentials is acceptable (e.g., payments, profile edits)
  Future<bool> authenticateWithFallback({
    required String localizedReason,
  }) async {
    return authenticate(
      localizedReason: localizedReason,
      biometricOnly: false,
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  /// Stop authentication (cancel ongoing authentication)
  Future<bool> stopAuthentication() async {
    try {
      final stopped = await _localAuth.stopAuthentication();
      _logger.d('BiometricAuth: Authentication stopped: $stopped');
      return stopped;
    } on PlatformException catch (e) {
      _logger.e('BiometricAuth: Error stopping authentication', error: e);
      return false;
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Get user-friendly description of available biometrics
  Future<String> getBiometricDescription() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.isEmpty) {
      return 'No biometrics available';
    }

    if (biometrics.length == 1) {
      return getBiometricTypeName(biometrics.first);
    }

    final names = biometrics.map((b) => getBiometricTypeName(b)).toList();
    return '${names.sublist(0, names.length - 1).join(', ')} or ${names.last}';
  }

  /// Handle authentication errors
  bool _handleAuthenticationError(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        _logger.w('BiometricAuth: Biometric authentication not available');
        break;
      case auth_error.notEnrolled:
        _logger.w('BiometricAuth: No biometrics enrolled on device');
        break;
      case auth_error.lockedOut:
        _logger.w('BiometricAuth: Authentication locked out (too many failed attempts)');
        break;
      case auth_error.permanentlyLockedOut:
        _logger.e('BiometricAuth: Authentication permanently locked out');
        break;
      case auth_error.passcodeNotSet:
        _logger.w('BiometricAuth: Device passcode not set');
        break;
      case auth_error.biometricOnlyNotSupported:
        _logger.w('BiometricAuth: Biometric-only auth not supported');
        break;
      default:
        _logger.e('BiometricAuth: Platform exception: ${e.code} - ${e.message}', error: e);
    }
    return false;
  }

  /// Prompt user to set up biometrics (navigate to settings)
  /// This is informational only - actual navigation handled by UI
  Future<Map<String, dynamic>> getBiometricSetupInfo() async {
    final canCheck = await canCheckBiometrics();
    final isSupported = await isDeviceSupported();
    final availableBiometrics = await getAvailableBiometrics();
    final isEnabled = await isBiometricEnabled();

    return {
      'canCheckBiometrics': canCheck,
      'isDeviceSupported': isSupported,
      'availableBiometrics': availableBiometrics,
      'isBiometricEnabled': isEnabled,
      'hasEnrolledBiometrics': availableBiometrics.isNotEmpty,
      'biometricDescription': await getBiometricDescription(),
    };
  }
}
