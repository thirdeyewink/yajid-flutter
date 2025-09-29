# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Yajid** is a comprehensive social media and recommendation platform built with Flutter. The application features Firebase authentication, real-time messaging, user profiles, content recommendations, and extensive multi-language localization support. Users can connect with others, share content, rate and bookmark recommendations, and participate in a vibrant community platform.

### Core Features
- **Authentication System**: Complete Firebase Auth integration with email/password, Google Sign-In, Apple Sign-In, and phone verification
- **Real-time Messaging**: Chat functionality with user search, message sending, and real-time updates via Firestore
- **User Profiles**: Comprehensive profiles with social media links, skills, preferences, and personalization
- **Recommendation Engine**: Content recommendations with ratings, bookmarks, and category-based filtering
- **Social Features**: User search, friend connections, and community interactions
- **Content Management**: Add, rate, and organize various types of content (movies, music, books, etc.)
- **Calendar Integration**: Event management and scheduling features
- **Onboarding Flow**: Multi-step user onboarding with preference selection

## Development Commands

### Essential Commands
- `flutter run` - Run the app (development server with hot reload)
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis and check for issues
- `flutter pub get` - Install dependencies after modifying pubspec.yaml
- `dart format .` - Format code according to Dart style guidelines

### Build Commands
- `flutter build web` - Build for web deployment
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (requires macOS)

### Localization Commands
After modifying `.arb` files in `lib/l10n/`, run:
- `flutter pub get` - Regenerates localization files automatically

## Architecture Overview

### Core Structure
- **Authentication Flow**: Uses Firebase Auth with email/password authentication
- **State Management**: Provider pattern for app-wide state (LocaleProvider for language switching)
- **Localization**: Flutter's built-in internationalization with `.arb` files
- **Navigation**: Basic Navigator with StreamBuilder for auth state management

### Key Files

#### Core Application
- `lib/main.dart` - App entry point with Firebase initialization, providers setup, and auth state management
- `lib/auth_screen.dart` - Comprehensive authentication UI with multi-step registration and phone verification
- `lib/home_screen.dart` - Main recommendation feed with content filtering and user interactions
- `lib/profile_screen.dart` - Complete user profile management with social media integration
- `lib/onboarding_screen.dart` - Multi-step onboarding flow for new users

#### Services & Data
- `lib/services/messaging_service.dart` - Real-time chat functionality with Firestore backend
- `lib/services/user_profile_service.dart` - User data management and profile operations
- `lib/services/logging_service.dart` - Centralized logging system for debugging and monitoring
- `lib/auth_service.dart` - Authentication service for Google and Apple Sign-In

#### Models
- `lib/models/user_model.dart` - User data structure for profiles and authentication
- `lib/models/chat_model.dart` - Chat conversation data structure
- `lib/models/message_model.dart` - Individual message data structure

#### Screens & UI
- `lib/screens/chat_list_screen.dart` - List of user conversations
- `lib/screens/chat_screen.dart` - Individual chat conversation interface
- `lib/screens/user_search_screen.dart` - Search and discover other users
- `lib/screens/add_content_screen.dart` - Content creation and recommendation submission
- `lib/screens/discover_screen.dart` - Content discovery and exploration
- `lib/screens/calendar_screen.dart` - Event management and scheduling
- `lib/screens/notifications_screen.dart` - User notification center

#### Providers & State Management
- `lib/locale_provider.dart` - Language selection and internationalization
- `lib/theme_provider.dart` - Dark/light theme management
- `lib/onboarding_provider.dart` - User onboarding state management

#### Localization
- `lib/l10n/` - Comprehensive localization files for 5 languages (en, es, fr, ar, pt)
- `lib/firebase_options.dart` - Auto-generated Firebase configuration

### Dependencies
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Firebase backend services
- `provider` - State management for app-wide state (locale, theme, onboarding)
- `flutter_localizations` & `intl` - Internationalization support (5 languages)
- `google_sign_in` & `sign_in_with_apple` - Social authentication providers
- `country_code_picker` - International phone number input
- `shared_preferences` - Local data persistence
- `flutter_svg` - SVG icon support
- `logger` - Structured logging system

### Authentication Features
- Email/password login and registration
- Password reset functionality
- Comprehensive user registration form (name, phone, gender, birthday)
- Real-time auth state monitoring

### Localization Features
- 5 supported languages: English, Spanish, French, Arabic, Portuguese
- Language selector in app bar with radio button dialog
- Persistent language selection via Provider
- Comprehensive translations for all UI text

## Project Configuration

### Firebase Setup
- Project ID: `yajid-connect`
- Android package: `com.example.ffsf`
- Firebase config files are already generated and included

### Asset Structure
- `assets/images/` - Image assets (logo.png referenced in auth screen)
- Localization files in `lib/l10n/` follow Flutter's standard structure

### Testing
- Default widget test exists but needs updating for current app structure
- Run `flutter test` to execute tests

## Development Notes

### Current State
- Basic authentication and localization functionality is complete
- App follows Material Design principles with custom styling
- Uses Firebase for backend authentication services
- Responsive design works on mobile and web platforms

### Code Style
- Follows standard Dart/Flutter conventions
- Uses const constructors where appropriate
- Proper error handling for Firebase operations
- Null safety enabled (SDK: '>=3.2.3 <4.0.0')

### Firebase Integration
- Firebase is properly initialized in main.dart
- Google Services configuration files are in place for Android
- App uses Firebase Auth for user management