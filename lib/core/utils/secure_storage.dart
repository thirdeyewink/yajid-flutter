import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Secure storage service for sensitive data
///
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences (AES256)
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final Logger _logger = Logger();

  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  // Android-specific options
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  // iOS-specific options
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  /// Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyDeviceId = 'device_id';

  /// Write secure data
  Future<bool> write(String key, String value) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      _logger.d('SecureStorage: Written key: $key');
      return true;
    } catch (e) {
      _logger.e('SecureStorage: Failed to write key: $key', error: e);
      return false;
    }
  }

  /// Read secure data
  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      _logger.d('SecureStorage: Read key: $key (exists: ${value != null})');
      return value;
    } catch (e) {
      _logger.e('SecureStorage: Failed to read key: $key', error: e);
      return null;
    }
  }

  /// Delete secure data
  Future<bool> delete(String key) async {
    try {
      await _storage.delete(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      _logger.d('SecureStorage: Deleted key: $key');
      return true;
    } catch (e) {
      _logger.e('SecureStorage: Failed to delete key: $key', error: e);
      return false;
    }
  }

  /// Delete all secure data
  Future<bool> deleteAll() async {
    try {
      await _storage.deleteAll(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      _logger.d('SecureStorage: Deleted all keys');
      return true;
    } catch (e) {
      _logger.e('SecureStorage: Failed to delete all keys', error: e);
      return false;
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.containsKey(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      return value;
    } catch (e) {
      _logger.e('SecureStorage: Failed to check key: $key', error: e);
      return false;
    }
  }

  /// Get all keys
  Future<Map<String, String>> readAll() async {
    try {
      final all = await _storage.readAll(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      return all;
    } catch (e) {
      _logger.e('SecureStorage: Failed to read all', error: e);
      return {};
    }
  }

  // Convenience methods for common operations

  /// Save authentication tokens
  Future<bool> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await write(keyAuthToken, accessToken);
      await write(keyRefreshToken, refreshToken);
      return true;
    } catch (e) {
      _logger.e('SecureStorage: Failed to save auth tokens', error: e);
      return false;
    }
  }

  /// Get authentication token
  Future<String?> getAuthToken() => read(keyAuthToken);

  /// Get refresh token
  Future<String?> getRefreshToken() => read(keyRefreshToken);

  /// Clear authentication data
  Future<bool> clearAuthData() async {
    try {
      await delete(keyAuthToken);
      await delete(keyRefreshToken);
      await delete(keyUserId);
      await delete(keyUserEmail);
      return true;
    } catch (e) {
      _logger.e('SecureStorage: Failed to clear auth data', error: e);
      return false;
    }
  }

  /// Save user credentials
  Future<bool> saveUserCredentials({
    required String userId,
    required String email,
  }) async {
    try {
      await write(keyUserId, userId);
      await write(keyUserEmail, email);
      return true;
    } catch (e) {
      _logger.e('SecureStorage: Failed to save user credentials', error: e);
      return false;
    }
  }

  /// Get user ID
  Future<String?> getUserId() => read(keyUserId);

  /// Get user email
  Future<String?> getUserEmail() => read(keyUserEmail);

  /// Enable/disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    return write(keyBiometricEnabled, enabled.toString());
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final value = await read(keyBiometricEnabled);
    return value == 'true';
  }

  /// Save device ID
  Future<bool> saveDeviceId(String deviceId) async {
    return write(keyDeviceId, deviceId);
  }

  /// Get device ID
  Future<String?> getDeviceId() => read(keyDeviceId);
}
