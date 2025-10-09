import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:yajid/auth_screen.dart';
import 'package:yajid/screens/main_navigation_screen.dart';
import 'package:yajid/firebase_options.dart';
import 'package:yajid/locale_provider.dart';
import 'package:yajid/theme_provider.dart';
import 'package:yajid/onboarding_screen.dart';
import 'package:yajid/onboarding_provider.dart';

// BLoC imports
import 'package:yajid/bloc/auth/auth_bloc.dart';
import 'package:yajid/bloc/auth/auth_event.dart';
import 'package:yajid/bloc/auth/auth_state.dart';
import 'package:yajid/bloc/profile/profile_bloc.dart';
import 'package:yajid/bloc/gamification/gamification_bloc.dart';
import 'package:yajid/bloc/booking/booking_bloc.dart';
import 'package:yajid/services/booking_service.dart';
import 'package:yajid/bloc/event/event_bloc.dart';
import 'package:yajid/services/event_service.dart';

// Security
import 'package:yajid/services/jailbreak_detection_service.dart';
import 'package:yajid/services/anti_debugging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Crashlytics
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Enable Firebase Performance Monitoring
  // Automatic traces will be collected for app startup, screen rendering, and network requests
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BLoC Providers - Complex business logic (see ADR-001, ADR-002)
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(const AuthStarted()),
          lazy: false, // Needed at app startup
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
          lazy: true, // Created on first access
        ),
        BlocProvider<GamificationBloc>(
          create: (context) => GamificationBloc(),
          lazy: true, // Created when user logs in and points widget accessed
        ),
        BlocProvider<BookingBloc>(
          create: (context) => BookingBloc(bookingService: BookingService()),
          lazy: true,
        ),
        BlocProvider<EventBloc>(
          create: (context) => EventBloc(EventService()),
          lazy: true,
        ),

        // Provider - Simple UI state (see ADR-001)
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => OnboardingProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Yajid Social',
            theme: themeProvider.themeData,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _jailbreakService = JailbreakDetectionService();
  final _antiDebuggingService = AntiDebuggingService();
  bool _securityCheckCompleted = false;

  @override
  void initState() {
    super.initState();
    _performSecurityCheck();
  }

  Future<void> _performSecurityCheck() async {
    try {
      // Skip security checks in debug mode (development only)
      if (kDebugMode) {
        _securityCheckCompleted = true;
        return;
      }

      // Check both jailbreak/root and debugging status
      final jailbreakStatus = await _jailbreakService.checkDeviceSecurity();
      final debugStatus = await _antiDebuggingService.checkDebugStatus();

      final hasSecurityIssue = jailbreakStatus.isCompromised || debugStatus.isDebugged;

      if (mounted && hasSecurityIssue) {
        // Show security warning dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_securityCheckCompleted) {
            _showSecurityWarningDialog(jailbreakStatus, debugStatus);
            _securityCheckCompleted = true;
          }
        });
      } else {
        _securityCheckCompleted = true;
      }
    } catch (e) {
      // Fail open - allow app to continue if security check fails
      _securityCheckCompleted = true;
    }
  }

  void _showSecurityWarningDialog(
    DeviceSecurityStatus jailbreakStatus,
    DebugStatus debugStatus,
  ) {
    // Combine security issues into a single message
    final issues = <String>[];

    if (jailbreakStatus.isCompromised) {
      issues.add(jailbreakStatus.message);
    }

    if (debugStatus.isDebugged) {
      issues.add(debugStatus.message);
    }

    final combinedMessage = issues.join('\n\n');
    final hasRecommendation = jailbreakStatus.recommendation.isNotEmpty ||
        debugStatus.recommendation.isNotEmpty;

    final recommendation = [
      if (jailbreakStatus.recommendation.isNotEmpty) jailbreakStatus.recommendation,
      if (debugStatus.recommendation.isNotEmpty) debugStatus.recommendation,
    ].join(' ');

    _showSecurityDialog(combinedMessage, recommendation, hasRecommendation);
  }

  void _showSecurityDialog(
    String message,
    String recommendation,
    bool hasRecommendation,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Security Warning'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (hasRecommendation)
              Text(
                recommendation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sensitive operations like payments may be restricted on this device.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('AuthWrapper: Current auth state: ${state.runtimeType}');

        if (state is AuthInitial || state is AuthLoading) {
          print('AuthWrapper: Showing loading screen');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          print('AuthWrapper: User authenticated, userId: ${state.user.uid}');
          return OnboardingWrapper(userId: state.user.uid);
        }

        if (state is AuthError) {
          print('AuthWrapper: Auth error: ${state.message}');
        }

        // User is unauthenticated, clear onboarding provider after build
        print('AuthWrapper: User unauthenticated, showing auth screen');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
          onboardingProvider.clearUser();
        });

        return const AuthScreen();
      },
    );
  }
}

class OnboardingWrapper extends StatefulWidget {
  final String userId;

  const OnboardingWrapper({super.key, required this.userId});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool _hasLoadedOnboarding = false;

  @override
  void initState() {
    super.initState();
    print('OnboardingWrapper: initState for userId: ${widget.userId}');
    // Load onboarding status after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedOnboarding) {
        print('OnboardingWrapper: Loading onboarding status in postFrameCallback');
        final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
        onboardingProvider.loadOnboardingStatus(widget.userId);
        _hasLoadedOnboarding = true;
      }
    });
  }

  @override
  void didUpdateWidget(OnboardingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('OnboardingWrapper: didUpdateWidget, old: ${oldWidget.userId}, new: ${widget.userId}');
    // If user changed, reload onboarding status
    if (oldWidget.userId != widget.userId) {
      print('OnboardingWrapper: User changed, reloading onboarding status');
      _hasLoadedOnboarding = false;
      final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
      onboardingProvider.loadOnboardingStatus(widget.userId);
      _hasLoadedOnboarding = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        print('OnboardingWrapper: Building, isLoading: ${onboardingProvider.isLoading}, isCompleted: ${onboardingProvider.isOnboardingCompleted}');

        if (onboardingProvider.isLoading) {
          print('OnboardingWrapper: Showing loading screen');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!onboardingProvider.isOnboardingCompleted) {
          print('OnboardingWrapper: Showing onboarding screen');
          return const OnboardingScreen();
        }

        print('OnboardingWrapper: Showing main navigation screen');
        return const MainNavigationScreen();
      },
    );
  }
}