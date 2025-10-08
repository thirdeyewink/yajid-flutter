import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/services/anti_debugging_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel('com.yajid.security/anti_debugging');

  group('AntiDebuggingService', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    group('Service Structure', () {
      test('should be a singleton', () {
        final instance1 = AntiDebuggingService();
        final instance2 = AntiDebuggingService();
        expect(instance1, same(instance2));
      });

      test('should have required methods', () {
        final service = AntiDebuggingService();
        expect(service.isDebuggerAttached, isA<Function>());
        expect(service.isRunningOnEmulator, isA<Function>());
        expect(service.isAppTampered, isA<Function>());
        expect(service.checkDebugStatus, isA<Function>());
        expect(service.isSafeForSensitiveOperations, isA<Function>());
        expect(service.getSecurityStatusMessage, isA<Function>());
      });
    });

    group('isDebuggerAttached', () {
      test('should return false when no debugger is attached', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isDebuggerAttached') {
            return false;
          }
          return null;
        });

        final service = AntiDebuggingService();
        final result = await service.isDebuggerAttached();

        expect(result, false);
      });

      test('should return true when debugger is attached', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isDebuggerAttached') {
            return true;
          }
          return null;
        });

        final service = AntiDebuggingService();
        final result = await service.isDebuggerAttached();

        expect(result, true);
      });

      test('should return false on platform exception (fail open)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isDebuggerAttached') {
            throw PlatformException(code: 'ERROR');
          }
          return null;
        });

        final service = AntiDebuggingService();
        final result = await service.isDebuggerAttached();

        expect(result, false);
      });
    });

    group('isRunningOnEmulator', () {
      test('should return false when running on physical device', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isRunningOnEmulator') {
            return false;
          }
          return null;
        });

        final service = AntiDebuggingService();
        final result = await service.isRunningOnEmulator();

        expect(result, false);
      });

      test('should return true when running on emulator', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isRunningOnEmulator') {
            return true;
          }
          return null;
        });

        final service = AntiDebuggingService();
        final result = await service.isRunningOnEmulator();

        expect(result, true);
      });

      test('should return false on platform exception (fail open)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isRunningOnEmulator') {
            throw PlatformException(code: 'ERROR');
          }
          return null;
        });

        final service = AntiDebuggingService();
        final result = await service.isRunningOnEmulator();

        expect(result, false);
      });
    });

    group('isAppTampered', () {
      test('should return false when app is not tampered', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isAppTampered') {
            return false;
          }
          return null;
        });

        final service = AntiDebuggingService();
        final result = await service.isAppTampered();

        expect(result, false);
      });

      test('should return true when app is tampered', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isAppTampered') {
            return true;
          }
          return null;
        });

        final service = AntiDebuggingService();
        final result = await service.isAppTampered();

        expect(result, true);
      });

      test('should return false on platform exception (fail open)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isAppTampered') {
            throw PlatformException(code: 'ERROR');
          }
          return null;
        });

        final service = AntiDebuggingService();
        final result = await service.isAppTampered();

        expect(result, false);
      });
    });

    group('checkDebugStatus', () {
      test('should return clean status when no issues detected', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return false;
        });

        final service = AntiDebuggingService();
        final status = await service.checkDebugStatus();

        expect(status.isDebuggerAttached, false);
        expect(status.isRunningOnEmulator, false);
        expect(status.isAppTampered, false);
        expect(status.isDebugged, false);
        expect(status.type, DebugDetectionType.none);
      });

      test('should detect debugger attachment', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isDebuggerAttached') return true;
          return false;
        });

        final service = AntiDebuggingService();
        final status = await service.checkDebugStatus();

        expect(status.isDebuggerAttached, true);
        expect(status.isDebugged, true);
        expect(status.type, DebugDetectionType.debuggerAttached);
      });

      test('should detect emulator', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isRunningOnEmulator') return true;
          return false;
        });

        final service = AntiDebuggingService();
        final status = await service.checkDebugStatus();

        expect(status.isRunningOnEmulator, true);
        expect(status.type, DebugDetectionType.emulator);
      });

      test('should detect app tampering', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isAppTampered') return true;
          return false;
        });

        final service = AntiDebuggingService();
        final status = await service.checkDebugStatus();

        expect(status.isAppTampered, true);
        expect(status.isDebugged, true);
        expect(status.type, DebugDetectionType.appTampered);
      });

      test('should handle errors gracefully', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          throw PlatformException(code: 'ERROR');
        });

        final service = AntiDebuggingService();
        final status = await service.checkDebugStatus();

        expect(status.isDebugged, false);
        expect(status.type, DebugDetectionType.none);
      });
    });

    group('isSafeForSensitiveOperations', () {
      test('strict policy blocks on any debugging activity', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isRunningOnEmulator') return true;
          return false;
        });

        final service = AntiDebuggingService();
        final isSafe = await service.isSafeForSensitiveOperations(
          policy: DebugSecurityPolicy.strict,
        );

        expect(isSafe, false);
      });

      test('balanced policy allows emulator but blocks debugger', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isRunningOnEmulator') return true;
          return false;
        });

        final service = AntiDebuggingService();
        final isSafe = await service.isSafeForSensitiveOperations(
          policy: DebugSecurityPolicy.balanced,
        );

        expect(isSafe, true);
      });

      test('balanced policy blocks debugger attachment', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isDebuggerAttached') return true;
          return false;
        });

        final service = AntiDebuggingService();
        final isSafe = await service.isSafeForSensitiveOperations(
          policy: DebugSecurityPolicy.balanced,
        );

        expect(isSafe, false);
      });

      test('permissive policy allows everything', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return true;
        });

        final service = AntiDebuggingService();
        final isSafe = await service.isSafeForSensitiveOperations(
          policy: DebugSecurityPolicy.permissive,
        );

        expect(isSafe, true);
      });
    });

    group('getSecurityStatusMessage', () {
      test('should return secure message when no issues', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return false;
        });

        final service = AntiDebuggingService();
        final message = await service.getSecurityStatusMessage();

        expect(message, 'Your device environment is secure');
      });

      test('should return debugger warning when debugger attached', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isDebuggerAttached') return true;
          return false;
        });

        final service = AntiDebuggingService();
        final message = await service.getSecurityStatusMessage();

        expect(message, contains('debugger'));
      });

      test('should return tampering warning when app tampered', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isAppTampered') return true;
          return false;
        });

        final service = AntiDebuggingService();
        final message = await service.getSecurityStatusMessage();

        expect(message, contains('tampering'));
      });

      test('should return emulator warning when on emulator', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isRunningOnEmulator') return true;
          return false;
        });

        final service = AntiDebuggingService();
        final message = await service.getSecurityStatusMessage();

        expect(message, contains('emulator'));
      });
    });
  });

  group('DebugStatus', () {
    test('should correctly identify no debugging', () {
      const status = DebugStatus(
        isDebuggerAttached: false,
        isRunningOnEmulator: false,
        isAppTampered: false,
      );

      expect(status.isDebugged, false);
      expect(status.type, DebugDetectionType.none);
      expect(status.allowAppUsage, true);
    });

    test('should correctly identify debugger attachment', () {
      const status = DebugStatus(
        isDebuggerAttached: true,
        isRunningOnEmulator: false,
        isAppTampered: false,
      );

      expect(status.isDebugged, true);
      expect(status.type, DebugDetectionType.debuggerAttached);
      expect(status.allowAppUsage, false);
      expect(status.message, contains('debugger'));
      expect(status.recommendation, contains('remove'));
    });

    test('should correctly identify app tampering', () {
      const status = DebugStatus(
        isDebuggerAttached: false,
        isRunningOnEmulator: false,
        isAppTampered: true,
      );

      expect(status.isDebugged, true);
      expect(status.type, DebugDetectionType.appTampered);
      expect(status.allowAppUsage, false);
      expect(status.message, contains('tampering'));
      expect(status.recommendation, contains('reinstall'));
    });

    test('should correctly identify emulator (allows app usage)', () {
      const status = DebugStatus(
        isDebuggerAttached: false,
        isRunningOnEmulator: true,
        isAppTampered: false,
      );

      expect(status.isDebugged, false);
      expect(status.type, DebugDetectionType.emulator);
      expect(status.allowAppUsage, true);
      expect(status.message, contains('emulator'));
    });
  });

  group('DebugSecurityPolicy', () {
    test('should have strict policy', () {
      expect(DebugSecurityPolicy.strict, isA<DebugSecurityPolicy>());
    });

    test('should have balanced policy', () {
      expect(DebugSecurityPolicy.balanced, isA<DebugSecurityPolicy>());
    });

    test('should have permissive policy', () {
      expect(DebugSecurityPolicy.permissive, isA<DebugSecurityPolicy>());
    });
  });

  group('SecurityCheckResult', () {
    test('should create result from status with strict policy', () {
      const status = DebugStatus(
        isDebuggerAttached: false,
        isRunningOnEmulator: true,
        isAppTampered: false,
      );

      final result = SecurityCheckResult.fromStatus(
        status,
        DebugSecurityPolicy.strict,
      );

      expect(result.allowed, false);
      expect(result.policy, DebugSecurityPolicy.strict);
      expect(result.message, contains('blocked'));
    });

    test('should create result from status with balanced policy', () {
      const status = DebugStatus(
        isDebuggerAttached: false,
        isRunningOnEmulator: true,
        isAppTampered: false,
      );

      final result = SecurityCheckResult.fromStatus(
        status,
        DebugSecurityPolicy.balanced,
      );

      expect(result.allowed, true);
      expect(result.policy, DebugSecurityPolicy.balanced);
    });

    test('should create result from status with permissive policy', () {
      const status = DebugStatus(
        isDebuggerAttached: true,
        isRunningOnEmulator: true,
        isAppTampered: true,
      );

      final result = SecurityCheckResult.fromStatus(
        status,
        DebugSecurityPolicy.permissive,
      );

      expect(result.allowed, true);
      expect(result.policy, DebugSecurityPolicy.permissive);
      expect(result.message, contains('permissive'));
    });
  });
}
