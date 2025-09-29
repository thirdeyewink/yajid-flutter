# Project Blueprint

## Overview

This is a Flutter application with Firebase authentication and localization support. The application allows users to sign up, log in, and view a home screen. It also supports multiple languages.

## Style, Design, and Features

*   **Authentication**: The application uses Firebase Authentication to manage user accounts. Users can sign up with their email and password, and also log in with their credentials. A password reset functionality is also included.
*   **Localization**: The application supports English, Arabic, French, Spanish, and Portuguese. The UI is translated based on the device's locale.
*   **Language Selection**: A language selection dialog has been added to the `AuthScreen`. Users can switch between English, Spanish, French, Arabic, and Portuguese. The application's locale is managed using a `LocaleProvider` and the `provider` package.
*   **UI**: The UI is built with Flutter's Material Design components. It includes a login screen, a signup screen, and a home screen.

## Current Task: Implement Language Selection

*   **DONE**: Add the `flutter_localizations` package to `pubspec.yaml`.
*   **DONE**: Add the `intl` package to `pubspec.yaml`.
*   **DONE**: Create the `l10n.yaml` file.
*   **DONE**: Create the `lib/l10n` directory and the `.arb` files for each language.
*   **DONE**: Run `flutter pub get` to generate the localization files.
*   **DONE**: Update `lib/main.dart` to include the `localizationsDelegates` and `supportedLocales`.
*   **DONE**: Refactor the UI code in `auth_screen.dart` and `home_screen.dart` to use the new localization keys.
*   **DONE**: Add a language icon to the `AuthScreen` app bar.
*   **DONE**: Implement a dialog to allow users to select their preferred language.
*   **DONE**: Use a `LocaleProvider` to manage the application's locale.
*   **DONE**: Update the `AuthScreen` to use the `LocaleProvider`.
*   **DONE**: Added `selectLanguage` to `.arb` files.
*   **DONE**: Added French, Arabic, and Portuguese to the language selection dialog.
