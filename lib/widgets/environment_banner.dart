import 'package:flutter/material.dart';
import 'package:yajid/config/env_config.dart';

/// Environment indicator banner for dev/staging environments
/// Shows a colored banner at the top of the screen to indicate the current environment
/// Only visible in non-production environments
class EnvironmentBanner extends StatelessWidget {
  final Widget child;

  const EnvironmentBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show banner in production
    if (currentConfig.isProduction) {
      return child;
    }

    return Banner(
      message: currentConfig.environmentName.toUpperCase(),
      location: BannerLocation.topEnd,
      color: _getBannerColor(),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.0,
      ),
      child: child,
    );
  }

  Color _getBannerColor() {
    if (currentConfig.isDevelopment) {
      return const Color(0xFFFF9800); // Orange
    } else if (currentConfig.isStaging) {
      return const Color(0xFF2196F3); // Blue
    }
    return Colors.grey; // Fallback
  }
}

/// Environment indicator widget to show at the bottom of screens
/// Displays a small chip with environment info
class EnvironmentIndicator extends StatelessWidget {
  const EnvironmentIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Don't show in production
    if (currentConfig.isProduction) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getIndicatorColor().withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getEnvironmentIcon(),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            currentConfig.environmentName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (currentConfig.enableLogging) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'DEBUG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getIndicatorColor() {
    if (currentConfig.isDevelopment) {
      return const Color(0xFFFF9800); // Orange
    } else if (currentConfig.isStaging) {
      return const Color(0xFF2196F3); // Blue
    }
    return Colors.grey;
  }

  IconData _getEnvironmentIcon() {
    if (currentConfig.isDevelopment) {
      return Icons.bug_report; // Development = bug/testing
    } else if (currentConfig.isStaging) {
      return Icons.science; // Staging = experimental
    }
    return Icons.info; // Fallback
  }
}

/// Floating environment info button
/// Shows detailed environment configuration when tapped
class EnvironmentInfoButton extends StatelessWidget {
  const EnvironmentInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Don't show in production
    if (currentConfig.isProduction) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      mini: true,
      backgroundColor: _getButtonColor(),
      onPressed: () => _showEnvironmentInfo(context),
      child: const Icon(Icons.info_outline, size: 20),
    );
  }

  Color _getButtonColor() {
    if (currentConfig.isDevelopment) {
      return const Color(0xFFFF9800); // Orange
    } else if (currentConfig.isStaging) {
      return const Color(0xFF2196F3); // Blue
    }
    return Colors.grey;
  }

  void _showEnvironmentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              currentConfig.isDevelopment ? Icons.bug_report : Icons.science,
              color: _getButtonColor(),
            ),
            const SizedBox(width: 12),
            Text('${currentConfig.environmentName} Environment'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Environment', currentConfig.environmentName),
              _buildInfoRow('Firebase Project', currentConfig.firebaseProjectId),
              _buildInfoRow('API Base URL', currentConfig.apiBaseUrl),
              const Divider(height: 24),
              _buildFeatureRow('Debug Logging', currentConfig.enableLogging),
              _buildFeatureRow('Crashlytics', currentConfig.enableCrashlytics),
              _buildFeatureRow('Performance Monitoring', currentConfig.enablePerformanceMonitoring),
              _buildFeatureRow('Debug Banner', currentConfig.showDebugBanner),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: enabled ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
