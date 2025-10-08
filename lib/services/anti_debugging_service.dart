import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Anti-Debugging Detection Service
///
/// Detects if the app is being debugged, reverse engineered, or tampered with.
/// This is part of the defense-in-depth security strategy.
///
/// Detections include:
/// - Debugger attachment (native debuggers like lldb, gdb, etc.)
/// - Emulator detection (app running on emulator/simulator)
/// - App tampering/modification detection
///
/// Usage:
/// ```dart
/// final service = AntiDebuggingService();
/// final status = await service.checkDebugStatus();
///
/// if (status.isDebugged) {
///   // Show warning or exit app
///   print('Debugger detected: ${status.message}');
/// }
/// ```
///
/// Security Note:
/// - This is NOT foolproof - determined attackers can bypass detection
/// - Use as part of defense-in-depth strategy
/// - Combine with other security measures (biometric auth, certificate pinning, jailbreak detection)
/// - Consider showing warning vs. blocking app entirely based on risk assessment
class AntiDebuggingService {
  static final AntiDebuggingService _instance =
      AntiDebuggingService._internal();
  static final Logger _logger = Logger();
  static const MethodChannel _channel =
      MethodChannel('com.yajid.security/anti_debugging');

  factory AntiDebuggingService() => _instance;

  AntiDebuggingService._internal();

  /// Check if a debugger is currently attached to the app
  Future<bool> isDebuggerAttached() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDebuggerAttached');
      final isAttached = result ?? false;

      if (isAttached) {
        _logger.w('Security: Debugger is attached to the app');
      } else {
        _logger.d('Security: No debugger detected');
      }

      return isAttached;
    } on PlatformException catch (e) {
      _logger.e('Security: Error checking debugger status', error: e);
      // Fail open - don't block users if detection fails
      return false;
    }
  }

  /// Check if the app is running on an emulator/simulator
  Future<bool> isRunningOnEmulator() async {
    try {
      final result = await _channel.invokeMethod<bool>('isRunningOnEmulator');
      final isEmulator = result ?? false;

      if (isEmulator) {
        _logger.w('Security: App is running on emulator/simulator');
      } else {
        _logger.d('Security: App is running on physical device');
      }

      return isEmulator;
    } on PlatformException catch (e) {
      _logger.e('Security: Error checking emulator status', error: e);
      // Fail open
      return false;
    }
  }

  /// Check if the app has been tampered with or modified
  ///
  /// This checks:
  /// - Debug mode enabled
  /// - Build type (debug vs release)
  /// - Signing certificate (Android only)
  Future<bool> isAppTampered() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAppTampered');
      final isTampered = result ?? false;

      if (isTampered) {
        _logger.w('Security: App tampering detected');
      } else {
        _logger.d('Security: App integrity check passed');
      }

      return isTampered;
    } on PlatformException catch (e) {
      _logger.e('Security: Error checking app integrity', error: e);
      // Fail open
      return false;
    }
  }

  /// Comprehensive security check combining all anti-debugging measures
  ///
  /// Returns [DebugStatus] with detailed information about any detected issues
  Future<DebugStatus> checkDebugStatus() async {
    try {
      final isDebugger = await isDebuggerAttached();
      final isEmulator = await isRunningOnEmulator();
      final isTampered = await isAppTampered();

      final isDebugged = isDebugger || isTampered;

      if (isDebugged) {
        _logger.w('Security: App is being debugged or tampered with');
      }

      return DebugStatus(
        isDebuggerAttached: isDebugger,
        isRunningOnEmulator: isEmulator,
        isAppTampered: isTampered,
      );
    } catch (e) {
      _logger.e('Security: Error during comprehensive debug check', error: e);
      // Fail open
      return DebugStatus(
        isDebuggerAttached: false,
        isRunningOnEmulator: false,
        isAppTampered: false,
      );
    }
  }

  /// Check if app should allow sensitive operations
  ///
  /// Sensitive operations include:
  /// - Payment processing
  /// - Viewing financial data
  /// - Exporting sensitive user data
  ///
  /// Uses the configured security policy to determine if operation should proceed
  Future<bool> isSafeForSensitiveOperations({
    DebugSecurityPolicy policy = DebugSecurityPolicy.balanced,
  }) async {
    final status = await checkDebugStatus();

    switch (policy) {
      case DebugSecurityPolicy.strict:
        // Block on any debugging activity
        return !status.isDebugged;

      case DebugSecurityPolicy.permissive:
        // Allow everything (for development/testing only)
        return true;

      case DebugSecurityPolicy.balanced:
        // Block on debugger or tampering, but allow emulator
        return !(status.isDebuggerAttached || status.isAppTampered);
    }
  }

  /// Get user-friendly security status message
  Future<String> getSecurityStatusMessage() async {
    final status = await checkDebugStatus();

    if (!status.isDebugged && !status.isRunningOnEmulator) {
      return 'Your device environment is secure';
    }

    final issues = <String>[];

    if (status.isDebuggerAttached) {
      issues.add('A debugger is attached to the app');
    }

    if (status.isAppTampered) {
      issues.add('App tampering has been detected');
    }

    if (status.isRunningOnEmulator) {
      issues.add('App is running on an emulator/simulator');
    }

    return 'Security warning: ${issues.join(', ')}';
  }
}

/// Status of anti-debugging checks
class DebugStatus {
  /// Whether a debugger is currently attached
  final bool isDebuggerAttached;

  /// Whether the app is running on an emulator/simulator
  final bool isRunningOnEmulator;

  /// Whether the app has been tampered with or modified
  final bool isAppTampered;

  const DebugStatus({
    required this.isDebuggerAttached,
    required this.isRunningOnEmulator,
    required this.isAppTampered,
  });

  /// Whether any debugging or tampering is detected
  bool get isDebugged => isDebuggerAttached || isAppTampered;

  /// Get type of debugging/tampering detected
  DebugDetectionType get type {
    if (isDebuggerAttached) return DebugDetectionType.debuggerAttached;
    if (isAppTampered) return DebugDetectionType.appTampered;
    if (isRunningOnEmulator) return DebugDetectionType.emulator;
    return DebugDetectionType.none;
  }

  /// Get user-friendly message describing the status
  String get message {
    if (isDebuggerAttached) {
      return 'A debugger is attached to this application. '
          'This may indicate reverse engineering attempts.';
    }
    if (isAppTampered) {
      return 'App tampering has been detected. '
          'The application may have been modified from its original state.';
    }
    if (isRunningOnEmulator) {
      return 'This app is running on an emulator or simulator.';
    }
    return 'No debugging or tampering detected.';
  }

  /// Get recommendation for the user
  String get recommendation {
    if (isDebuggerAttached) {
      return 'For security reasons, please remove any debuggers and restart the app.';
    }
    if (isAppTampered) {
      return 'Please reinstall the app from an official source (App Store/Play Store).';
    }
    if (isRunningOnEmulator) {
      return 'For the best security, use a physical device for sensitive operations.';
    }
    return '';
  }

  /// Whether app usage should be allowed based on this status
  bool get allowAppUsage {
    // Emulator alone doesn't block app usage
    // Only block on active debugging or tampering
    return !isDebuggerAttached && !isAppTampered;
  }
}

/// Type of debugging/tampering detected
enum DebugDetectionType {
  /// No debugging or tampering detected
  none,

  /// A debugger is attached to the app
  debuggerAttached,

  /// App has been tampered with or modified
  appTampered,

  /// App is running on emulator/simulator (not necessarily a security issue)
  emulator,
}

/// Security policy for anti-debugging measures
enum DebugSecurityPolicy {
  /// Block all debugging activity (strictest)
  ///
  /// - Blocks debugger attachment
  /// - Blocks app tampering
  /// - Blocks emulator usage
  strict,

  /// Warn but allow most activity (recommended for production)
  ///
  /// - Blocks debugger attachment for sensitive operations
  /// - Blocks app tampering for sensitive operations
  /// - Allows emulator usage with warnings
  balanced,

  /// Allow all debugging activity (development/testing only)
  ///
  /// - Allows debugger attachment
  /// - Allows app tampering
  /// - Allows emulator usage
  permissive,
}

/// Result of a security check with applied policy
class SecurityCheckResult {
  /// The debug status detected
  final DebugStatus status;

  /// Whether the operation should be allowed
  final bool allowed;

  /// Message explaining the decision
  final String message;

  /// The security policy that was applied
  final DebugSecurityPolicy policy;

  const SecurityCheckResult({
    required this.status,
    required this.allowed,
    required this.message,
    required this.policy,
  });

  factory SecurityCheckResult.fromStatus(
    DebugStatus status,
    DebugSecurityPolicy policy,
  ) {
    bool allowed;
    String message;

    switch (policy) {
      case DebugSecurityPolicy.strict:
        allowed = !status.isDebugged && !status.isRunningOnEmulator;
        message = allowed
            ? 'Security check passed'
            : 'Operation blocked due to strict security policy';
        break;

      case DebugSecurityPolicy.balanced:
        allowed = !status.isDebuggerAttached && !status.isAppTampered;
        message = allowed
            ? 'Security check passed'
            : 'Operation blocked due to security concerns';
        break;

      case DebugSecurityPolicy.permissive:
        allowed = true;
        message = 'Security check passed (permissive mode)';
        break;
    }

    return SecurityCheckResult(
      status: status,
      allowed: allowed,
      message: message,
      policy: policy,
    );
  }
}
