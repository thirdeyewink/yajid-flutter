import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:logger/logger.dart';

/// Certificate Pinning Service for secure API communication
///
/// IMPORTANT NOTE about Firebase Certificate Pinning:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Firebase SDK manages its own HTTP client internally, making traditional
/// certificate pinning difficult. Firebase's recommended security approach is:
///
/// 1. Firebase App Check (recommended) - Verifies requests come from your app
/// 2. Firebase Security Rules - Server-side access control
/// 3. TLS 1.3 encryption (default) - Protects data in transit
///
/// This service provides certificate pinning for:
/// - Custom API endpoints (non-Firebase)
/// - Future backend services
/// - Third-party integrations
///
/// For Firebase endpoints, rely on:
/// - App Check: https://firebase.google.com/docs/app-check
/// - Security Rules: Already implemented in firestore.rules
/// - Default TLS 1.3 encryption
///
/// Certificate Pinning Strategy:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// - Pin both leaf certificate AND CA certificate (dual pinning)
/// - Rotate certificates every 90 days
/// - Keep backup pins for certificate rotation
/// - Monitor pinning failures via Crashlytics
class CertificatePinningService {
  static final CertificatePinningService _instance =
      CertificatePinningService._internal();
  static final Logger _logger = Logger();

  factory CertificatePinningService() => _instance;

  CertificatePinningService._internal();

  /// Certificate pins for custom API endpoints
  ///
  /// Format: Map with String keys and List of String values
  /// Key: Domain (e.g., 'api.yajid.ma')
  /// Value: List of SHA-256 certificate fingerprints
  ///
  /// How to get certificate fingerprints:
  /// ```bash
  /// # Method 1: Using OpenSSL
  /// openssl s_client -connect api.yajid.ma:443 -showcerts | \
  ///   openssl x509 -pubkey -noout | \
  ///   openssl rsa -pubin -outform der | \
  ///   openssl dgst -sha256 -binary | \
  ///   openssl enc -base64
  ///
  /// # Method 2: Using online tools
  /// # Visit: https://www.ssllabs.com/ssltest/
  /// # Or: https://report-uri.com/home/pkp_hash
  /// ```
  static final Map<String, List<String>> _certificatePins = {
    // Example: Custom API endpoint (replace with actual values)
    // 'api.yajid.ma': [
    //   'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Leaf certificate
    //   'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Intermediate CA
    //   'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=', // Backup pin (for rotation)
    // ],

    // Example: Payment gateway endpoint
    // 'payment.cmi.co.ma': [
    //   'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=',
    //   'EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE=',
    // ],
  };

  /// Check if certificate pinning is configured for a domain
  bool hasPinsForDomain(String domain) {
    return _certificatePins.containsKey(domain) &&
        _certificatePins[domain]!.isNotEmpty;
  }

  /// Get certificate pins for a specific domain
  List<String> getPinsForDomain(String domain) {
    return _certificatePins[domain] ?? [];
  }

  /// Verify SSL certificate for a URL
  ///
  /// Returns: true if certificate is valid and pinned (or no pins configured)
  ///          false if certificate validation fails
  Future<bool> checkCertificate({
    required String url,
    List<String>? pins,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host;

      // Get pins from provided list or configured pins
      final certificatePins = pins ?? _certificatePins[domain];

      if (certificatePins == null || certificatePins.isEmpty) {
        _logger.w('CertPinning: No pins configured for $domain');
        return true; // No pinning configured, allow connection
      }

      _logger.d('CertPinning: Checking certificate for $domain');

      // Use http_certificate_pinning to verify certificate
      final result = await HttpCertificatePinning.check(
        serverURL: url,
        headerHttp: {},
        sha: SHA.SHA256,
        allowedSHAFingerprints: certificatePins,
        timeout: timeout.inSeconds,
      );

      if (result.contains('CONNECTION_SECURE')) {
        _logger.d('CertPinning: Certificate valid for $domain ✓');
        return true;
      } else {
        _logger.e('CertPinning: Certificate validation failed for $domain');
        return false;
      }
    } catch (e) {
      _logger.e('CertPinning: Error checking certificate', error: e);
      return false;
    }
  }

  /// Verify certificate before making HTTP requests
  ///
  /// Use this to verify certificate pinning before making API calls
  /// with your preferred HTTP client (e.g., http, dio)
  ///
  /// Example with http package:
  /// ```dart
  /// final isValid = await certPinning.checkCertificate(url: apiUrl);
  /// if (isValid) {
  ///   final response = await http.get(Uri.parse(apiUrl));
  ///   // Process response
  /// }
  /// ```
  Future<bool> verifyCertificateForRequest({
    required String url,
    List<String>? pins,
  }) async {
    return await checkCertificate(url: url, pins: pins);
  }

  /// Add or update certificate pins for a domain
  ///
  /// Use this to configure pinning for new endpoints
  /// or rotate certificates
  void configurePins(String domain, List<String> pins) {
    _certificatePins[domain] = pins;
    _logger.i('CertPinning: Configured ${pins.length} pins for $domain');
  }

  /// Remove certificate pins for a domain
  void removePins(String domain) {
    _certificatePins.remove(domain);
    _logger.i('CertPinning: Removed pins for $domain');
  }

  /// Get all configured domains
  List<String> getConfiguredDomains() {
    return _certificatePins.keys.toList();
  }

  /// Certificate rotation helper
  ///
  /// Call this periodically (e.g., every 90 days) to remind about rotation
  Map<String, dynamic> getCertificateRotationInfo() {
    return {
      'configuredDomains': _certificatePins.length,
      'domains': _certificatePins.keys.toList(),
      'recommendedRotationInterval': '90 days',
      'lastRotationCheck': DateTime.now().toIso8601String(),
      'nextRotationDue': DateTime.now()
          .add(const Duration(days: 90))
          .toIso8601String(),
    };
  }

  /// Verify certificate pinning is working (test mode)
  ///
  /// Use this in development to verify your pins are correct
  Future<Map<String, bool>> testAllPinnedDomains() async {
    final results = <String, bool>{};

    for (final domain in _certificatePins.keys) {
      try {
        final testUrl = 'https://$domain';
        final isValid = await checkCertificate(url: testUrl);
        results[domain] = isValid;
      } catch (e) {
        _logger.e('CertPinning: Test failed for $domain', error: e);
        results[domain] = false;
      }
    }

    return results;
  }
}

/// Certificate Pinning Configuration Guide
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
///
/// STEP 1: Get Certificate Fingerprints
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Option A: Using OpenSSL
/// ```bash
/// # Get certificate from server
/// echo | openssl s_client -connect api.yajid.ma:443 -showcerts 2>/dev/null | \
///   openssl x509 -outform PEM > cert.pem
///
/// # Extract public key and hash it
/// openssl x509 -in cert.pem -pubkey -noout | \
///   openssl rsa -pubin -outform der 2>/dev/null | \
///   openssl dgst -sha256 -binary | \
///   openssl enc -base64
/// ```
///
/// Option B: Using online tools
/// - SSL Labs: https://www.ssllabs.com/ssltest/
/// - Report URI: https://report-uri.com/home/pkp_hash
///
/// STEP 2: Configure Pins in Code
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// ```dart
/// CertificatePinningService().configurePins('api.yajid.ma', [
///   'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Current cert
///   'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Backup cert
/// ]);
/// ```
///
/// STEP 3: Make Pinned Requests
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// ```dart
/// final response = await CertificatePinningService().secureGet(
///   url: 'https://api.yajid.ma/endpoint',
///   headers: {'Authorization': 'Bearer $token'},
/// );
/// ```
///
/// STEP 4: Monitor & Rotate
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// - Rotate certificates every 90 days
/// - Always keep 2-3 pins (current + backup)
/// - Test before deploying: testAllPinnedDomains()
/// - Monitor Crashlytics for pinning failures
///
/// BEST PRACTICES:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// ✅ Pin both leaf and intermediate certificates
/// ✅ Keep backup pins for rotation
/// ✅ Use SHA-256 fingerprints
/// ✅ Test thoroughly in staging environment
/// ✅ Monitor pinning failures
/// ✅ Have certificate rotation plan
///
/// ❌ Don't pin root CA only (too generic)
/// ❌ Don't hard-code in release builds without backup
/// ❌ Don't skip testing
/// ❌ Don't forget to rotate
///
/// Firebase & Certificate Pinning:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Firebase SDK uses its own HTTP client, making traditional pinning
/// difficult. Instead, use Firebase App Check:
///
/// 1. Enable App Check in Firebase Console
/// 2. Configure for iOS (DeviceCheck/App Attest)
/// 3. Configure for Android (Play Integrity API)
/// 4. Enforce in Firebase Security Rules
///
/// Firebase App Check provides:
/// - Request origin verification
/// - Anti-abuse protection
/// - Automatic token refresh
/// - Works with all Firebase services
///
/// Learn more: https://firebase.google.com/docs/app-check
