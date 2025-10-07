import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/services/jailbreak_detection_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JailbreakDetectionService', () {
    late JailbreakDetectionService service;

    setUp(() {
      service = JailbreakDetectionService();
    });

    group('Service structure', () {
      test('JailbreakDetectionService is a singleton', () {
        final instance1 = JailbreakDetectionService();
        final instance2 = JailbreakDetectionService();
        expect(identical(instance1, instance2), isTrue);
      });

      test('has all required public methods', () {
        expect(service.isDeviceCompromised(), isA<Future<bool>>());
        expect(service.isDeveloperMode(), isA<Future<bool>>());
        expect(service.checkDeviceSecurity(), isA<Future<DeviceSecurityStatus>>());
        expect(service.isSafeForSensitiveOperations(), isA<Future<bool>>());
        expect(service.getSecurityStatusMessage(), isA<Future<String>>());
      });
    });

    group('isDeviceCompromised', () {
      test('returns a Future<bool>', () {
        final result = service.isDeviceCompromised();
        expect(result, isA<Future<bool>>());
      });

      test('completes without throwing', () async {
        expect(() => service.isDeviceCompromised(), returnsNormally);
      });
    });

    group('isDeveloperMode', () {
      test('returns a Future<bool>', () {
        final result = service.isDeveloperMode();
        expect(result, isA<Future<bool>>());
      });

      test('completes without throwing', () async {
        expect(() => service.isDeveloperMode(), returnsNormally);
      });
    });

    group('checkDeviceSecurity', () {
      test('returns a Future<DeviceSecurityStatus>', () {
        final result = service.checkDeviceSecurity();
        expect(result, isA<Future<DeviceSecurityStatus>>());
      });

      test('completes and returns DeviceSecurityStatus', () async {
        final status = await service.checkDeviceSecurity();
        expect(status, isA<DeviceSecurityStatus>());
        expect(status.message, isA<String>());
        expect(status.recommendation, isA<String>());
        expect(status.isCompromised, isA<bool>());
        expect(status.type, isA<DeviceCompromiseType>());
        expect(status.allowAppUsage, isA<bool>());
      });

      test('returns valid compromise types', () async {
        final status = await service.checkDeviceSecurity();
        final validTypes = [
          DeviceCompromiseType.none,
          DeviceCompromiseType.jailbrokenOrRooted,
          DeviceCompromiseType.developerMode,
          DeviceCompromiseType.unknown,
        ];
        expect(validTypes.contains(status.type), isTrue);
      });
    });

    group('isSafeForSensitiveOperations', () {
      test('returns a Future<bool>', () {
        final result = service.isSafeForSensitiveOperations();
        expect(result, isA<Future<bool>>());
      });

      test('completes without throwing', () async {
        expect(() => service.isSafeForSensitiveOperations(), returnsNormally);
      });
    });

    group('getSecurityStatusMessage', () {
      test('returns a Future<String>', () {
        final result = service.getSecurityStatusMessage();
        expect(result, isA<Future<String>>());
      });

      test('returns a non-empty message', () async {
        final message = await service.getSecurityStatusMessage();
        expect(message, isA<String>());
        expect(message.isNotEmpty, isTrue);
      });
    });

    group('Error handling', () {
      test('service handles exceptions gracefully', () async {
        // Should not throw even if plugin is not initialized
        expect(() => service.checkDeviceSecurity(), returnsNormally);
        expect(() => service.isDeviceCompromised(), returnsNormally);
        expect(() => service.isDeveloperMode(), returnsNormally);
      });
    });
  });

  group('DeviceSecurityStatus', () {
    test('can be instantiated with required parameters', () {
      final status = DeviceSecurityStatus(
        isCompromised: false,
        type: DeviceCompromiseType.none,
        message: 'Test message',
        recommendation: 'Test recommendation',
        allowAppUsage: true,
      );

      expect(status.isCompromised, isFalse);
      expect(status.type, DeviceCompromiseType.none);
      expect(status.message, 'Test message');
      expect(status.recommendation, 'Test recommendation');
      expect(status.allowAppUsage, isTrue);
    });

    test('toString returns formatted string', () {
      final status = DeviceSecurityStatus(
        isCompromised: true,
        type: DeviceCompromiseType.jailbrokenOrRooted,
        message: 'Test',
        recommendation: 'Test',
        allowAppUsage: false,
      );

      final string = status.toString();
      expect(string, contains('DeviceSecurityStatus'));
      expect(string, contains('compromised: true'));
      expect(string, contains('type: DeviceCompromiseType.jailbrokenOrRooted'));
      expect(string, contains('allowUsage: false'));
    });
  });

  group('DeviceCompromiseType', () {
    test('has all expected values', () {
      expect(DeviceCompromiseType.values.length, 4);
      expect(DeviceCompromiseType.values, contains(DeviceCompromiseType.none));
      expect(DeviceCompromiseType.values, contains(DeviceCompromiseType.jailbrokenOrRooted));
      expect(DeviceCompromiseType.values, contains(DeviceCompromiseType.developerMode));
      expect(DeviceCompromiseType.values, contains(DeviceCompromiseType.unknown));
    });

    test('displayName extension returns correct names', () {
      expect(DeviceCompromiseType.none.displayName, 'Secure');
      expect(DeviceCompromiseType.jailbrokenOrRooted.displayName, 'Jailbroken/Rooted');
      expect(DeviceCompromiseType.developerMode.displayName, 'Developer Mode');
      expect(DeviceCompromiseType.unknown.displayName, 'Unknown');
    });
  });

  group('SecurityPolicy', () {
    test('default constructor creates permissive policy', () {
      const policy = SecurityPolicy();
      expect(policy.blockOnJailbreak, isFalse);
      expect(policy.blockOnDeveloperMode, isFalse);
      expect(policy.showWarnings, isTrue);
      expect(policy.allowSensitiveOpsOnCompromisedDevice, isFalse);
    });

    test('strict policy blocks all compromised devices', () {
      const policy = SecurityPolicy.strict;
      expect(policy.blockOnJailbreak, isTrue);
      expect(policy.blockOnDeveloperMode, isTrue);
      expect(policy.showWarnings, isTrue);
      expect(policy.allowSensitiveOpsOnCompromisedDevice, isFalse);
    });

    test('permissive policy allows everything with warnings', () {
      const policy = SecurityPolicy.permissive;
      expect(policy.blockOnJailbreak, isFalse);
      expect(policy.blockOnDeveloperMode, isFalse);
      expect(policy.showWarnings, isTrue);
      expect(policy.allowSensitiveOpsOnCompromisedDevice, isTrue);
    });

    test('balanced policy warns but allows app with payment restrictions', () {
      const policy = SecurityPolicy.balanced;
      expect(policy.blockOnJailbreak, isFalse);
      expect(policy.blockOnDeveloperMode, isFalse);
      expect(policy.showWarnings, isTrue);
      expect(policy.allowSensitiveOpsOnCompromisedDevice, isFalse);
    });
  });

  group('SecurityCheckResult', () {
    test('can be instantiated with required parameters', () {
      final status = DeviceSecurityStatus(
        isCompromised: false,
        type: DeviceCompromiseType.none,
        message: 'Test',
        recommendation: '',
        allowAppUsage: true,
      );

      const policy = SecurityPolicy();

      final result = SecurityCheckResult(
        status: status,
        policy: policy,
        allowAppUsage: true,
        allowSensitiveOperations: true,
        warningMessage: null,
      );

      expect(result.status, status);
      expect(result.policy, policy);
      expect(result.allowAppUsage, isTrue);
      expect(result.allowSensitiveOperations, isTrue);
      expect(result.warningMessage, isNull);
    });

    test('fromStatusAndPolicy creates result for secure device', () {
      final status = DeviceSecurityStatus(
        isCompromised: false,
        type: DeviceCompromiseType.none,
        message: 'Device is secure',
        recommendation: '',
        allowAppUsage: true,
      );

      const policy = SecurityPolicy.balanced;
      final result = SecurityCheckResult.fromStatusAndPolicy(status, policy);

      expect(result.allowAppUsage, isTrue);
      expect(result.allowSensitiveOperations, isTrue);
      expect(result.warningMessage, isNull);
    });

    test('fromStatusAndPolicy applies strict policy to jailbroken device', () {
      final status = DeviceSecurityStatus(
        isCompromised: true,
        type: DeviceCompromiseType.jailbrokenOrRooted,
        message: 'Device is jailbroken',
        recommendation: 'Use a secure device',
        allowAppUsage: true,
      );

      const policy = SecurityPolicy.strict;
      final result = SecurityCheckResult.fromStatusAndPolicy(status, policy);

      expect(result.allowAppUsage, isFalse); // Blocked by strict policy
      expect(result.allowSensitiveOperations, isFalse);
      expect(result.warningMessage, isNotNull);
      expect(result.warningMessage, 'Device is jailbroken');
    });

    test('fromStatusAndPolicy applies balanced policy to jailbroken device', () {
      final status = DeviceSecurityStatus(
        isCompromised: true,
        type: DeviceCompromiseType.jailbrokenOrRooted,
        message: 'Device is jailbroken',
        recommendation: 'Use a secure device',
        allowAppUsage: true,
      );

      const policy = SecurityPolicy.balanced;
      final result = SecurityCheckResult.fromStatusAndPolicy(status, policy);

      expect(result.allowAppUsage, isTrue); // Allowed by balanced policy
      expect(result.allowSensitiveOperations, isFalse); // But payments blocked
      expect(result.warningMessage, isNotNull);
    });

    test('fromStatusAndPolicy applies policy to developer mode', () {
      final status = DeviceSecurityStatus(
        isCompromised: true,
        type: DeviceCompromiseType.developerMode,
        message: 'Device is in developer mode',
        recommendation: 'Disable developer mode',
        allowAppUsage: true,
      );

      const policy = SecurityPolicy.balanced;
      final result = SecurityCheckResult.fromStatusAndPolicy(status, policy);

      expect(result.allowAppUsage, isTrue); // Balanced policy allows dev mode
      expect(result.allowSensitiveOperations, isFalse);
      expect(result.warningMessage, isNotNull);
    });

    test('fromStatusAndPolicy strict policy blocks developer mode', () {
      final status = DeviceSecurityStatus(
        isCompromised: true,
        type: DeviceCompromiseType.developerMode,
        message: 'Device is in developer mode',
        recommendation: 'Disable developer mode',
        allowAppUsage: true,
      );

      const policy = SecurityPolicy.strict;
      final result = SecurityCheckResult.fromStatusAndPolicy(status, policy);

      expect(result.allowAppUsage, isFalse); // Strict policy blocks dev mode
      expect(result.allowSensitiveOperations, isFalse);
    });

    test('fromStatusAndPolicy permissive policy allows everything', () {
      final status = DeviceSecurityStatus(
        isCompromised: true,
        type: DeviceCompromiseType.jailbrokenOrRooted,
        message: 'Device is jailbroken',
        recommendation: 'Use a secure device',
        allowAppUsage: true,
      );

      const policy = SecurityPolicy.permissive;
      final result = SecurityCheckResult.fromStatusAndPolicy(status, policy);

      expect(result.allowAppUsage, isTrue);
      expect(result.allowSensitiveOperations, isTrue); // Permissive allows payments
      expect(result.warningMessage, isNotNull);
    });

    test('fromStatusAndPolicy handles unknown type', () {
      final status = DeviceSecurityStatus(
        isCompromised: false,
        type: DeviceCompromiseType.unknown,
        message: 'Cannot determine security',
        recommendation: '',
        allowAppUsage: true,
      );

      const policy = SecurityPolicy.balanced;
      final result = SecurityCheckResult.fromStatusAndPolicy(status, policy);

      expect(result.allowAppUsage, isTrue); // Unknown type allows usage
      expect(result.allowSensitiveOperations, isTrue);
      expect(result.warningMessage, isNull);
    });

    test('policy without warnings does not set warning message', () {
      final status = DeviceSecurityStatus(
        isCompromised: true,
        type: DeviceCompromiseType.jailbrokenOrRooted,
        message: 'Device is jailbroken',
        recommendation: 'Use a secure device',
        allowAppUsage: true,
      );

      const policy = SecurityPolicy(
        blockOnJailbreak: false,
        showWarnings: false, // Warnings disabled
      );
      final result = SecurityCheckResult.fromStatusAndPolicy(status, policy);

      expect(result.warningMessage, isNull); // No warning despite compromise
    });
  });

  group('Integration scenarios', () {
    late JailbreakDetectionService service;

    setUp(() {
      service = JailbreakDetectionService();
    });

    test('check device security flow completes', () async {
      final status = await service.checkDeviceSecurity();
      expect(status, isA<DeviceSecurityStatus>());

      // Should be able to get a message from the status
      expect(status.message.isNotEmpty, isTrue);
    });

    test('sensitive operations check completes', () async {
      final isSafe = await service.isSafeForSensitiveOperations();
      expect(isSafe, isA<bool>());
    });

    test('security status message retrieval completes', () async {
      final message = await service.getSecurityStatusMessage();
      expect(message, isA<String>());
      expect(message.isNotEmpty, isTrue);
    });

    test('multiple checks can be performed', () async {
      final check1 = await service.checkDeviceSecurity();
      final check2 = await service.checkDeviceSecurity();

      // Both should complete successfully
      expect(check1, isA<DeviceSecurityStatus>());
      expect(check2, isA<DeviceSecurityStatus>());
    });
  });
}
