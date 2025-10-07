import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:logger/logger.dart';

/// Jailbreak and Root Detection Service
///
/// Detects if the app is running on a compromised device (jailbroken iOS or rooted Android).
/// This is important for security-sensitive applications that handle financial transactions
/// or sensitive user data.
///
/// Usage:
/// ```dart
/// final service = JailbreakDetectionService();
/// final status = await service.checkDeviceSecurity();
///
/// if (status.isCompromised) {
///   // Show warning or block functionality
///   print('Device is ${status.type}: ${status.message}');
/// }
/// ```
///
/// Security Note:
/// - This is NOT foolproof - determined attackers can bypass detection
/// - Use as part of defense-in-depth strategy
/// - Combine with other security measures (biometric auth, certificate pinning, etc.)
/// - Consider showing warning vs. blocking app entirely based on risk assessment
class JailbreakDetectionService {
  static final JailbreakDetectionService _instance =
      JailbreakDetectionService._internal();
  static final Logger _logger = Logger();

  factory JailbreakDetectionService() => _instance;

  JailbreakDetectionService._internal();

  /// Check if device is jailbroken (iOS) or rooted (Android)
  Future<bool> isDeviceCompromised() async {
    try {
      final jailbroken = await FlutterJailbreakDetection.jailbroken;
      if (jailbroken) {
        _logger.w('Security: Device is jailbroken/rooted');
      } else {
        _logger.d('Security: Device security check passed');
      }
      return jailbroken;
    } catch (e) {
      _logger.e('Security: Error checking device security', error: e);
      // Fail open - don't block users if detection fails
      return false;
    }
  }

  /// Check if app is running in developer mode (Android)
  Future<bool> isDeveloperMode() async {
    try {
      final devMode = await FlutterJailbreakDetection.developerMode;
      if (devMode) {
        _logger.w('Security: Device is in developer mode');
      }
      return devMode;
    } catch (e) {
      _logger.e('Security: Error checking developer mode', error: e);
      return false;
    }
  }

  /// Comprehensive device security check
  ///
  /// Returns detailed security status including:
  /// - Whether device is compromised
  /// - Type of compromise detected
  /// - User-friendly message
  /// - Recommendations
  Future<DeviceSecurityStatus> checkDeviceSecurity() async {
    try {
      final jailbroken = await isDeviceCompromised();
      final devMode = await isDeveloperMode();

      if (jailbroken) {
        return DeviceSecurityStatus(
          isCompromised: true,
          type: DeviceCompromiseType.jailbrokenOrRooted,
          message: 'This device appears to be jailbroken (iOS) or rooted (Android). '
              'Running the app on a compromised device may expose your data to security risks.',
          recommendation: 'For your security, we recommend using this app on a non-jailbroken/rooted device.',
          allowAppUsage: true, // Allow but warn - can be changed based on risk tolerance
        );
      }

      if (devMode) {
        return DeviceSecurityStatus(
          isCompromised: true,
          type: DeviceCompromiseType.developerMode,
          message: 'This device is in developer mode. '
              'This may reduce the security of sensitive operations.',
          recommendation: 'Consider disabling developer mode for enhanced security.',
          allowAppUsage: true, // Allow with warning
        );
      }

      return DeviceSecurityStatus(
        isCompromised: false,
        type: DeviceCompromiseType.none,
        message: 'Device security check passed',
        recommendation: '',
        allowAppUsage: true,
      );
    } catch (e) {
      _logger.e('Security: Comprehensive check failed', error: e);
      // Fail open - allow app usage if detection fails
      return DeviceSecurityStatus(
        isCompromised: false,
        type: DeviceCompromiseType.unknown,
        message: 'Unable to verify device security status',
        recommendation: '',
        allowAppUsage: true,
      );
    }
  }

  /// Check if device security is acceptable for sensitive operations
  ///
  /// This is a stricter check than [checkDeviceSecurity] and can be used
  /// for high-risk operations like payments.
  Future<bool> isSafeForSensitiveOperations() async {
    final status = await checkDeviceSecurity();

    // For sensitive operations, we might want to be more strict
    // Currently allows developer mode but blocks jailbreak/root
    if (status.type == DeviceCompromiseType.jailbrokenOrRooted) {
      _logger.w('Security: Device not safe for sensitive operations - ${status.type}');
      return false;
    }

    return true;
  }

  /// Get user-friendly security status message
  Future<String> getSecurityStatusMessage() async {
    final status = await checkDeviceSecurity();
    return status.message;
  }
}

/// Device security status information
class DeviceSecurityStatus {
  /// Whether the device is considered compromised
  final bool isCompromised;

  /// Type of compromise detected
  final DeviceCompromiseType type;

  /// User-friendly message describing the security status
  final String message;

  /// Recommendation for the user
  final String recommendation;

  /// Whether the app should allow usage on this device
  final bool allowAppUsage;

  const DeviceSecurityStatus({
    required this.isCompromised,
    required this.type,
    required this.message,
    required this.recommendation,
    required this.allowAppUsage,
  });

  @override
  String toString() {
    return 'DeviceSecurityStatus('
        'compromised: $isCompromised, '
        'type: $type, '
        'allowUsage: $allowAppUsage'
        ')';
  }
}

/// Types of device compromise
enum DeviceCompromiseType {
  /// No compromise detected
  none,

  /// Device is jailbroken (iOS) or rooted (Android)
  jailbrokenOrRooted,

  /// Device is in developer mode (Android)
  developerMode,

  /// Unable to determine security status
  unknown,
}

/// Extension for user-friendly type names
extension DeviceCompromiseTypeExtension on DeviceCompromiseType {
  String get displayName {
    switch (this) {
      case DeviceCompromiseType.none:
        return 'Secure';
      case DeviceCompromiseType.jailbrokenOrRooted:
        return 'Jailbroken/Rooted';
      case DeviceCompromiseType.developerMode:
        return 'Developer Mode';
      case DeviceCompromiseType.unknown:
        return 'Unknown';
    }
  }
}

/// Security Policy Configuration
///
/// Configure how the app should respond to security threats
class SecurityPolicy {
  /// Whether to block app usage on jailbroken/rooted devices
  final bool blockOnJailbreak;

  /// Whether to block app usage in developer mode
  final bool blockOnDeveloperMode;

  /// Whether to show warnings for compromised devices
  final bool showWarnings;

  /// Whether to allow sensitive operations (payments) on compromised devices
  final bool allowSensitiveOpsOnCompromisedDevice;

  const SecurityPolicy({
    this.blockOnJailbreak = false, // Default: warn but allow
    this.blockOnDeveloperMode = false, // Default: warn but allow
    this.showWarnings = true,
    this.allowSensitiveOpsOnCompromisedDevice = false, // Default: block payments on compromised devices
  });

  /// Strict policy - block all compromised devices
  static const SecurityPolicy strict = SecurityPolicy(
    blockOnJailbreak: true,
    blockOnDeveloperMode: true,
    showWarnings: true,
    allowSensitiveOpsOnCompromisedDevice: false,
  );

  /// Permissive policy - warn but allow everything
  static const SecurityPolicy permissive = SecurityPolicy(
    blockOnJailbreak: false,
    blockOnDeveloperMode: false,
    showWarnings: true,
    allowSensitiveOpsOnCompromisedDevice: true,
  );

  /// Balanced policy - warn for all, block payments on jailbreak
  static const SecurityPolicy balanced = SecurityPolicy(
    blockOnJailbreak: false,
    blockOnDeveloperMode: false,
    showWarnings: true,
    allowSensitiveOpsOnCompromisedDevice: false, // Block payments but allow app
  );
}

/// Security Check Result
///
/// Used to determine app behavior based on security policy
class SecurityCheckResult {
  /// The detected security status
  final DeviceSecurityStatus status;

  /// The security policy applied
  final SecurityPolicy policy;

  /// Whether the app should be allowed to run
  final bool allowAppUsage;

  /// Whether sensitive operations should be allowed
  final bool allowSensitiveOperations;

  /// Message to display to user (if any)
  final String? warningMessage;

  SecurityCheckResult({
    required this.status,
    required this.policy,
    required this.allowAppUsage,
    required this.allowSensitiveOperations,
    this.warningMessage,
  });

  factory SecurityCheckResult.fromStatusAndPolicy(
    DeviceSecurityStatus status,
    SecurityPolicy policy,
  ) {
    bool allowApp = true;
    bool allowSensitive = true;
    String? warning;

    switch (status.type) {
      case DeviceCompromiseType.jailbrokenOrRooted:
        allowApp = !policy.blockOnJailbreak;
        allowSensitive = policy.allowSensitiveOpsOnCompromisedDevice;
        if (policy.showWarnings) {
          warning = status.message;
        }
        break;
      case DeviceCompromiseType.developerMode:
        allowApp = !policy.blockOnDeveloperMode;
        allowSensitive = policy.allowSensitiveOpsOnCompromisedDevice;
        if (policy.showWarnings) {
          warning = status.message;
        }
        break;
      case DeviceCompromiseType.none:
      case DeviceCompromiseType.unknown:
        // No restrictions
        break;
    }

    return SecurityCheckResult(
      status: status,
      policy: policy,
      allowAppUsage: allowApp,
      allowSensitiveOperations: allowSensitive,
      warningMessage: warning,
    );
  }
}
