import 'package:flutter/material.dart';
import 'package:yajid/services/biometric_auth_service.dart';

/// Reusable biometric authentication prompt widget
///
/// This widget provides a consistent way to require biometric authentication
/// before performing sensitive operations (payments, data deletion, etc.)
///
/// Usage:
/// ```dart
/// final authenticated = await showBiometricPrompt(
///   context: context,
///   title: 'Payment Confirmation',
///   reason: 'Authenticate to complete your payment of \$50.00',
/// );
///
/// if (authenticated) {
///   // Proceed with payment
/// }
/// ```
class BiometricPrompt {
  static final BiometricAuthService _biometricService = BiometricAuthService();

  /// Show biometric authentication prompt
  ///
  /// Returns true if authentication succeeded, false otherwise
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String reason,
    bool biometricOnly = false,
    bool showCancelButton = true,
  }) async {
    final isBiometricEnabled = await _biometricService.isBiometricEnabled();

    if (!isBiometricEnabled) {
      // Biometric is not enabled, show confirmation dialog instead
      if (!context.mounted) return false;
      return await _showConfirmationDialog(
        context: context,
        title: title,
        message: reason,
        showCancelButton: showCancelButton,
      );
    }

    // Perform biometric authentication
    final authenticated = biometricOnly
        ? await _biometricService.authenticateBiometricOnly(
            localizedReason: reason,
          )
        : await _biometricService.authenticateWithFallback(
            localizedReason: reason,
          );

    if (!authenticated && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Authentication failed')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return authenticated;
  }

  /// Show payment confirmation with biometric authentication
  ///
  /// Specialized method for payment flows with amount display
  static Future<bool> showForPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    String? description,
  }) async {
    final formattedAmount = _formatCurrency(amount, currency);
    final reason = description != null
        ? 'Authenticate to complete payment of $formattedAmount for $description'
        : 'Authenticate to complete payment of $formattedAmount';

    return await show(
      context: context,
      title: 'Payment Confirmation',
      reason: reason,
      showCancelButton: true,
    );
  }

  /// Show account deletion confirmation with biometric authentication
  static Future<bool> showForAccountDeletion({
    required BuildContext context,
  }) async {
    return await show(
      context: context,
      title: 'Delete Account',
      reason: 'Authenticate to permanently delete your account',
      biometricOnly: false,
      showCancelButton: true,
    );
  }

  /// Show data export confirmation with biometric authentication
  static Future<bool> showForDataExport({
    required BuildContext context,
    String? dataType,
  }) async {
    final reason = dataType != null
        ? 'Authenticate to export your $dataType'
        : 'Authenticate to export your data';

    return await show(
      context: context,
      title: 'Export Data',
      reason: reason,
      showCancelButton: true,
    );
  }

  /// Format currency amount for display
  static String _formatCurrency(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'GBP':
        return '£${amount.toStringAsFixed(2)}';
      case 'MAD':
        return '${amount.toStringAsFixed(2)} MAD';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }

  /// Show confirmation dialog when biometric is not enabled
  static Future<bool> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    bool showCancelButton = true,
  }) async {
    if (!context.mounted) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enable biometric authentication in Settings for enhanced security',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (showCancelButton)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// Check if biometric authentication is available and enabled
  static Future<bool> isEnabled() async {
    return await _biometricService.isBiometricEnabled();
  }

  /// Get biometric capability information
  static Future<Map<String, dynamic>> getInfo() async {
    return await _biometricService.getBiometricSetupInfo();
  }
}

/// Example widget showing how to use BiometricPrompt for payments
///
/// This is a reference implementation - adapt to your payment flow
class PaymentButton extends StatefulWidget {
  final double amount;
  final String currency;
  final String description;
  final Future<bool> Function() onPayment;

  const PaymentButton({
    super.key,
    required this.amount,
    required this.currency,
    required this.description,
    required this.onPayment,
  });

  @override
  State<PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<PaymentButton> {
  bool _isProcessing = false;

  Future<void> _handlePayment() async {
    if (_isProcessing) return;

    // Require biometric authentication
    final authenticated = await BiometricPrompt.showForPayment(
      context: context,
      amount: widget.amount,
      currency: widget.currency,
      description: widget.description,
    );

    if (!authenticated) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await widget.onPayment();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(success ? 'Payment successful' : 'Payment failed'),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Payment error: $e')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _handlePayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: _isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Pay ${BiometricPrompt._formatCurrency(widget.amount, widget.currency)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
