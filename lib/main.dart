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
import 'package:yajid/bloc/gamification/gamification_event.dart';

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
          create: (context) => GamificationBloc()..add(InitializeGamification()),
          lazy: false, // Needed for app bar points widget
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          // User is authenticated, check onboarding status
          return Consumer<OnboardingProvider>(
            builder: (context, onboardingProvider, child) {
              if (onboardingProvider.isLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (!onboardingProvider.isOnboardingCompleted) {
                return const OnboardingScreen();
              }

              return const MainNavigationScreen();
            },
          );
        }

        return const AuthScreen();
      },
    );
  }
}