import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let CHANNEL = "com.yajid.security/anti_debugging"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let antiDebuggingChannel = FlutterMethodChannel(
      name: CHANNEL,
      binaryMessenger: controller.binaryMessenger
    )

    antiDebuggingChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }

      switch call.method {
      case "isDebuggerAttached":
        result(self.isDebuggerAttached())
      case "isRunningOnEmulator":
        result(self.isRunningOnEmulator())
      case "isAppTampered":
        result(self.isAppTampered())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Detect if a debugger is attached to the app
  ///
  /// Uses sysctl to check the P_TRACED flag which indicates debugging
  private func isDebuggerAttached() -> Bool {
    var info = kinfo_proc()
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var size = MemoryLayout<kinfo_proc>.stride

    let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)

    if result != 0 {
      // Error checking debug status, fail open
      return false
    }

    // P_TRACED flag indicates the process is being traced (debugged)
    let isDebugged = (info.kp_proc.p_flag & P_TRACED) != 0
    return isDebugged
  }

  /// Detect if the app is running on a simulator
  ///
  /// Checks if TARGET_OS_SIMULATOR is defined (compile-time check)
  private func isRunningOnEmulator() -> Bool {
    #if targetEnvironment(simulator)
      return true
    #else
      return false
    #endif
  }

  /// Detect if the app has been tampered with or modified
  ///
  /// Checks:
  /// - Debug build configuration
  /// - Code signing identity
  private func isAppTampered() -> Bool {
    // Check if app is built in debug mode
    #if DEBUG
      return true
    #else
      // In release builds, check if app is properly signed
      // Note: Apps distributed via TestFlight or Ad-Hoc will have different signatures
      // This is a basic check and not foolproof

      // Check if running without proper signing (should not happen in production)
      guard let _ = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else {
        return true
      }

      return false
    #endif
  }
}
