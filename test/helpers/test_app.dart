import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:yajid/auth_screen.dart';
import 'package:yajid/bloc/auth/auth_bloc.dart';
import 'package:yajid/bloc/auth/auth_event.dart';
import 'package:yajid/bloc/gamification/gamification_bloc.dart';
import 'package:yajid/bloc/profile/profile_bloc.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/locale_provider.dart';
import 'package:yajid/services/gamification_service.dart';
import 'package:yajid/theme_provider.dart';

/// Test-friendly version of the app that doesn't require Firebase initialization
///
/// This widget provides the same app structure as the main app but skips
/// Firebase initialization, making it suitable for widget and integration tests.
class TestApp extends StatelessWidget {
  /// Optional home widget to override the default AuthScreen
  final Widget? home;

  /// Optional locale for testing localization
  final Locale? locale;

  const TestApp({
    super.key,
    this.home,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BLoC Providers
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(const AuthStarted()),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
        BlocProvider<GamificationBloc>(
          create: (context) => GamificationBloc(
            gamificationService: GamificationService(),
          ),
        ),

        // Legacy Provider support
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          return MaterialApp(
            title: 'Yajid Test',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            locale: locale ?? localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: home ?? const AuthScreen(),
          );
        },
      ),
    );
  }
}
