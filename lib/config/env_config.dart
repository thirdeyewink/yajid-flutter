/// Environment configuration for the Yajid app
/// Defines different build environments: dev, staging, and production

enum Environment {
  dev,
  staging,
  production,
}

class EnvConfig {
  final Environment environment;
  final String appName;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableCrashlytics;
  final bool enablePerformanceMonitoring;
  final bool showDebugBanner;
  final String firebaseProjectId;

  const EnvConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableCrashlytics,
    required this.enablePerformanceMonitoring,
    required this.showDebugBanner,
    required this.firebaseProjectId,
  });

  /// Development environment configuration
  static const EnvConfig dev = EnvConfig(
    environment: Environment.dev,
    appName: 'Yajid (Dev)',
    apiBaseUrl: 'https://dev-api.yajid.com',
    enableLogging: true,
    enableCrashlytics: false,
    enablePerformanceMonitoring: false,
    showDebugBanner: true,
    firebaseProjectId: 'yajid-dev',
  );

  /// Staging environment configuration
  static const EnvConfig staging = EnvConfig(
    environment: Environment.staging,
    appName: 'Yajid (Staging)',
    apiBaseUrl: 'https://staging-api.yajid.com',
    enableLogging: true,
    enableCrashlytics: true,
    enablePerformanceMonitoring: true,
    showDebugBanner: true,
    firebaseProjectId: 'yajid-staging',
  );

  /// Production environment configuration
  static const EnvConfig production = EnvConfig(
    environment: Environment.production,
    appName: 'Yajid',
    apiBaseUrl: 'https://api.yajid.com',
    enableLogging: false,
    enableCrashlytics: true,
    enablePerformanceMonitoring: true,
    showDebugBanner: false,
    firebaseProjectId: 'yajid-connect', // Current production project
  );

  /// Check if current environment is development
  bool get isDevelopment => environment == Environment.dev;

  /// Check if current environment is staging
  bool get isStaging => environment == Environment.staging;

  /// Check if current environment is production
  bool get isProduction => environment == Environment.production;

  /// Get environment name as string
  String get environmentName {
    switch (environment) {
      case Environment.dev:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  /// Get environment color for UI indicators
  /// Dev = Orange, Staging = Blue, Production = Green
  String get environmentColor {
    switch (environment) {
      case Environment.dev:
        return '#FF9800'; // Orange
      case Environment.staging:
        return '#2196F3'; // Blue
      case Environment.production:
        return '#4CAF50'; // Green
    }
  }

  @override
  String toString() {
    return 'EnvConfig(environment: $environmentName, projectId: $firebaseProjectId)';
  }
}

/// Global environment configuration
/// This will be set by the entry point (main_dev.dart, main_staging.dart, main_production.dart)
EnvConfig currentConfig = EnvConfig.production; // Default to production for safety
