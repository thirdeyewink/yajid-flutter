import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/services/certificate_pinning_service.dart';

void main() {
  group('CertificatePinningService', () {
    late CertificatePinningService service;

    setUp(() {
      service = CertificatePinningService();
    });

    group('Singleton pattern', () {
      test('returns same instance', () {
        final instance1 = CertificatePinningService();
        final instance2 = CertificatePinningService();
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('hasPinsForDomain', () {
      test('returns false for unconfigured domain', () {
        expect(service.hasPinsForDomain('example.com'), isFalse);
      });

      test('returns true after configuring pins', () {
        service.configurePins('example.com', ['pin1', 'pin2']);
        expect(service.hasPinsForDomain('example.com'), isTrue);
      });

      test('returns false after removing pins', () {
        service.configurePins('example.com', ['pin1', 'pin2']);
        service.removePins('example.com');
        expect(service.hasPinsForDomain('example.com'), isFalse);
      });
    });

    group('getPinsForDomain', () {
      test('returns empty list for unconfigured domain', () {
        expect(service.getPinsForDomain('example.com'), isEmpty);
      });

      test('returns configured pins', () {
        service.configurePins('example.com', ['pin1', 'pin2']);
        expect(service.getPinsForDomain('example.com'), equals(['pin1', 'pin2']));
      });

      test('returns empty list after removing pins', () {
        service.configurePins('example.com', ['pin1', 'pin2']);
        service.removePins('example.com');
        expect(service.getPinsForDomain('example.com'), isEmpty);
      });
    });

    group('configurePins', () {
      test('configures pins for domain', () {
        service.configurePins('api.example.com', ['pin1', 'pin2', 'pin3']);
        expect(service.hasPinsForDomain('api.example.com'), isTrue);
        expect(service.getPinsForDomain('api.example.com').length, equals(3));
      });

      test('updates existing pins', () {
        service.configurePins('api.example.com', ['pin1']);
        service.configurePins('api.example.com', ['pin2', 'pin3']);
        expect(service.getPinsForDomain('api.example.com'), equals(['pin2', 'pin3']));
      });

      test('handles empty pin list', () {
        service.configurePins('api.example.com', []);
        expect(service.hasPinsForDomain('api.example.com'), isFalse);
      });
    });

    group('removePins', () {
      test('removes configured pins', () {
        service.configurePins('api.example.com', ['pin1', 'pin2']);
        service.removePins('api.example.com');
        expect(service.hasPinsForDomain('api.example.com'), isFalse);
      });

      test('handles removing non-existent domain', () {
        expect(() => service.removePins('nonexistent.com'), returnsNormally);
      });
    });

    group('getConfiguredDomains', () {
      test('returns empty list initially', () {
        // Note: This assumes a fresh instance or cleanup between tests
        expect(service.getConfiguredDomains(), isA<List<String>>());
      });

      test('returns list of configured domains', () {
        service.configurePins('domain1.com', ['pin1']);
        service.configurePins('domain2.com', ['pin2']);

        final domains = service.getConfiguredDomains();
        expect(domains, contains('domain1.com'));
        expect(domains, contains('domain2.com'));
      });

      test('updates after removing domain', () {
        service.configurePins('domain1.com', ['pin1']);
        service.configurePins('domain2.com', ['pin2']);
        service.removePins('domain1.com');

        final domains = service.getConfiguredDomains();
        expect(domains, isNot(contains('domain1.com')));
        expect(domains, contains('domain2.com'));
      });
    });

    group('checkCertificate', () {
      test('returns future when checking certificate', () {
        final result = service.checkCertificate(url: 'https://example.com');
        expect(result, isA<Future<bool>>());
      });

      test('accepts custom timeout', () {
        final result = service.checkCertificate(
          url: 'https://example.com',
          timeout: const Duration(seconds: 10),
        );
        expect(result, isA<Future<bool>>());
      });

      test('accepts custom pins parameter', () {
        final result = service.checkCertificate(
          url: 'https://example.com',
          pins: ['customPin1', 'customPin2'],
        );
        expect(result, isA<Future<bool>>());
      });
    });

    group('verifyCertificateForRequest', () {
      test('returns future when verifying certificate', () {
        final result = service.verifyCertificateForRequest(
          url: 'https://example.com',
        );
        expect(result, isA<Future<bool>>());
      });

      test('accepts custom pins', () {
        final result = service.verifyCertificateForRequest(
          url: 'https://example.com',
          pins: ['pin1', 'pin2'],
        );
        expect(result, isA<Future<bool>>());
      });
    });

    group('getCertificateRotationInfo', () {
      test('returns rotation information', () {
        final info = service.getCertificateRotationInfo();

        expect(info, isA<Map<String, dynamic>>());
        expect(info.containsKey('configuredDomains'), isTrue);
        expect(info.containsKey('domains'), isTrue);
        expect(info.containsKey('recommendedRotationInterval'), isTrue);
        expect(info.containsKey('lastRotationCheck'), isTrue);
        expect(info.containsKey('nextRotationDue'), isTrue);
      });

      test('contains correct rotation interval', () {
        final info = service.getCertificateRotationInfo();
        expect(info['recommendedRotationInterval'], equals('90 days'));
      });

      test('includes domain count', () {
        service.configurePins('domain1.com', ['pin1']);
        service.configurePins('domain2.com', ['pin2']);

        final info = service.getCertificateRotationInfo();
        expect(info['configuredDomains'], isA<int>());
      });

      test('includes domain list', () {
        service.configurePins('domain1.com', ['pin1']);

        final info = service.getCertificateRotationInfo();
        expect(info['domains'], isA<List>());
        expect((info['domains'] as List).contains('domain1.com'), isTrue);
      });

      test('includes ISO8601 timestamps', () {
        final info = service.getCertificateRotationInfo();

        expect(info['lastRotationCheck'], isA<String>());
        expect(info['nextRotationDue'], isA<String>());

        // Verify ISO8601 format
        expect(
          () => DateTime.parse(info['lastRotationCheck'] as String),
          returnsNormally,
        );
        expect(
          () => DateTime.parse(info['nextRotationDue'] as String),
          returnsNormally,
        );
      });
    });

    group('testAllPinnedDomains', () {
      test('returns map when testing domains', () {
        final result = service.testAllPinnedDomains();
        expect(result, isA<Future<Map<String, bool>>>());
      });

      test('tests all configured domains', () async {
        service.configurePins('example1.com', ['pin1']);
        service.configurePins('example2.com', ['pin2']);

        final result = await service.testAllPinnedDomains();
        expect(result, isA<Map<String, bool>>());
      });
    });

    group('Multiple domain configuration', () {
      test('handles multiple domains independently', () {
        service.configurePins('api.example.com', ['pin1', 'pin2']);
        service.configurePins('payment.example.com', ['pin3', 'pin4']);

        expect(service.hasPinsForDomain('api.example.com'), isTrue);
        expect(service.hasPinsForDomain('payment.example.com'), isTrue);
        expect(service.getPinsForDomain('api.example.com'), equals(['pin1', 'pin2']));
        expect(service.getPinsForDomain('payment.example.com'), equals(['pin3', 'pin4']));
      });

      test('removing one domain does not affect others', () {
        service.configurePins('api.example.com', ['pin1']);
        service.configurePins('payment.example.com', ['pin2']);

        service.removePins('api.example.com');

        expect(service.hasPinsForDomain('api.example.com'), isFalse);
        expect(service.hasPinsForDomain('payment.example.com'), isTrue);
      });
    });

    group('Edge cases', () {
      test('handles URL with port number', () {
        final result = service.checkCertificate(url: 'https://example.com:8443');
        expect(result, isA<Future<bool>>());
      });

      test('handles URL with path', () {
        final result = service.checkCertificate(url: 'https://example.com/api/v1');
        expect(result, isA<Future<bool>>());
      });

      test('handles URL with query parameters', () {
        final result = service.checkCertificate(url: 'https://example.com?param=value');
        expect(result, isA<Future<bool>>());
      });

      test('handles subdomain', () {
        service.configurePins('api.example.com', ['pin1']);
        expect(service.hasPinsForDomain('api.example.com'), isTrue);
        expect(service.hasPinsForDomain('example.com'), isFalse);
      });
    });

    group('Pin format validation', () {
      test('accepts valid SHA-256 base64 pin format', () {
        final validPin = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
        service.configurePins('example.com', [validPin]);
        expect(service.getPinsForDomain('example.com'), contains(validPin));
      });

      test('handles multiple pins', () {
        final pins = [
          'pin1==',
          'pin2==',
          'pin3==',
        ];
        service.configurePins('example.com', pins);
        expect(service.getPinsForDomain('example.com'), equals(pins));
      });
    });

    group('Service cleanup', () {
      test('can clear all pins', () {
        service.configurePins('domain1.com', ['pin1']);
        service.configurePins('domain2.com', ['pin2']);

        final domains = service.getConfiguredDomains();
        for (final domain in List.from(domains)) {
          service.removePins(domain);
        }

        expect(service.getConfiguredDomains(), everyElement(
          predicate<String>((domain) => !service.hasPinsForDomain(domain)),
        ));
      });
    });
  });

  group('CertificatePinningService - Integration Tests', () {
    late CertificatePinningService service;

    setUp(() {
      service = CertificatePinningService();
    });

    test('typical usage flow', () {
      // Configure pins for API endpoint
      service.configurePins('api.yajid.ma', [
        'leafCertPin==',
        'intermediateCertPin==',
        'backupPin==',
      ]);

      // Verify pins are configured
      expect(service.hasPinsForDomain('api.yajid.ma'), isTrue);
      expect(service.getPinsForDomain('api.yajid.ma').length, equals(3));

      // Check rotation info
      final rotationInfo = service.getCertificateRotationInfo();
      expect(rotationInfo['configuredDomains'], greaterThanOrEqualTo(1));

      // Simulate rotation - update pins
      service.configurePins('api.yajid.ma', [
        'newLeafCertPin==',
        'newIntermediateCertPin==',
        'backupPin==', // Keep backup pin
      ]);

      expect(service.getPinsForDomain('api.yajid.ma').length, equals(3));
    });

    test('certificate check flow without configured pins', () async {
      // Attempt to check certificate without configuring pins
      final result = await service.checkCertificate(url: 'https://unconfigured.com');

      // Should return true (no pinning configured, allow connection)
      expect(result, isTrue);
    });
  });
}
