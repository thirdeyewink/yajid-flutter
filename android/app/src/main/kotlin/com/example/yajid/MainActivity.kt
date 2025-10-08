package com.example.yajid

import android.os.Build
import android.os.Debug
import com.example.yajid.BuildConfig
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.yajid.security/anti_debugging"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDebuggerAttached" -> {
                    result.success(isDebuggerAttached())
                }
                "isRunningOnEmulator" -> {
                    result.success(isRunningOnEmulator())
                }
                "isAppTampered" -> {
                    result.success(isAppTampered())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Detect if a debugger is attached to the app
     *
     * Checks:
     * - Debug.isDebuggerConnected() - Native debugger detection
     * - Debug.waitingForDebugger() - Waiting for debugger flag
     */
    private fun isDebuggerAttached(): Boolean {
        return Debug.isDebuggerConnected() || Debug.waitingForDebugger()
    }

    /**
     * Detect if the app is running on an emulator/simulator
     *
     * Checks multiple device characteristics:
     * - Device brand, manufacturer, model
     * - Hardware properties
     * - Build fingerprint
     */
    private fun isRunningOnEmulator(): Boolean {
        val isEmulator = (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")) ||
                Build.FINGERPRINT.startsWith("generic") ||
                Build.FINGERPRINT.startsWith("unknown") ||
                Build.HARDWARE.contains("goldfish") ||
                Build.HARDWARE.contains("ranchu") ||
                Build.MODEL.contains("google_sdk") ||
                Build.MODEL.contains("Emulator") ||
                Build.MODEL.contains("Android SDK built for x86") ||
                Build.MANUFACTURER.contains("Genymotion") ||
                Build.PRODUCT.contains("sdk_google") ||
                Build.PRODUCT.contains("google_sdk") ||
                Build.PRODUCT.contains("sdk") ||
                Build.PRODUCT.contains("sdk_x86") ||
                Build.PRODUCT.contains("sdk_gphone64_arm64") ||
                Build.PRODUCT.contains("vbox86p") ||
                Build.PRODUCT.contains("emulator") ||
                Build.PRODUCT.contains("simulator")

        return isEmulator
    }

    /**
     * Detect if the app has been tampered with or modified
     *
     * Checks:
     * - Debug build type (BuildConfig.DEBUG)
     * - Debuggable flag in application info
     *
     * Note: In production, BuildConfig.DEBUG should be false
     */
    private fun isAppTampered(): Boolean {
        // Check if app is built in debug mode
        val isDebugBuild = BuildConfig.DEBUG

        // Check if app is debuggable (should be false in production)
        val isDebuggable = (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0

        return isDebugBuild || isDebuggable
    }
}
