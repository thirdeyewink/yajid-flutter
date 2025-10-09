# Multi-Environment Setup Guide

This guide explains how to configure and use the dev, staging, and production environments in the Yajid Flutter app.

## Overview

The Yajid app supports three separate environments:

| Environment | Purpose | Firebase Project | App ID | Features |
|------------|---------|------------------|---------|----------|
| **Development** | Local development & testing | `yajid-dev` | `com.example.myapp.dev` | Logging enabled, no crashlytics |
| **Staging** | QA testing & demos | `yajid-staging` | `com.example.myapp.staging` | All features enabled |
| **Production** | Live app for users | `yajid-connect` | `com.example.myapp` | Optimized, crashlytics enabled |

## Project Structure

```
yajid/
├── lib/
│   ├── config/
│   │   └── env_config.dart              # Environment configuration
│   ├── main_dev.dart                    # Dev entry point
│   ├── main_staging.dart                # Staging entry point
│   ├── main_production.dart             # Production entry point
│   ├── firebase_options_dev.dart        # Dev Firebase config (gitignored)
│   ├── firebase_options_staging.dart    # Staging Firebase config (gitignored)
│   ├── firebase_options.dart            # Production Firebase config (committed)
│   ├── services/
│   │   └── data_seeding_service.dart    # Fake data generator
│   └── widgets/
│       └── environment_banner.dart      # Environment indicator UI
├── android/
│   └── app/
│       ├── build.gradle.kts             # Product flavors configuration
│       └── src/
│           ├── dev/
│           │   ├── google-services.json (gitignored)
│           │   └── README.md
│           ├── staging/
│           │   ├── google-services.json (gitignored)
│           │   └── README.md
│           └── production/
│               ├── google-services.json (gitignored)
│               └── README.md
├── scripts/
│   ├── seed_data.dart                   # Data seeding script
│   └── README.md
└── .github/
    └── workflows/
        ├── deploy-dev.yml               # Dev CI/CD
        ├── deploy-staging.yml           # Staging CI/CD
        └── deploy-production.yml        # Production CI/CD
```

## Firebase Setup

### Step 1: Create Firebase Projects

Create three separate Firebase projects in the [Firebase Console](https://console.firebase.google.com/):

1. **yajid-dev** (Development)
2. **yajid-staging** (Staging)
3. **yajid-connect** (Production - already exists)

### Step 2: Register Android Apps

For each Firebase project, register an Android app:

| Project | Package Name |
|---------|-------------|
| yajid-dev | `com.example.myapp.dev` |
| yajid-staging | `com.example.myapp.staging` |
| yajid-connect | `com.example.myapp` |

### Step 3: Download google-services.json

For each project:

1. Go to Project Settings → Your apps → Android app
2. Download `google-services.json`
3. Place in the appropriate directory:
   - Dev: `android/app/src/dev/google-services.json`
   - Staging: `android/app/src/staging/google-services.json`
   - Production: `android/app/src/production/google-services.json`

**Important**: These files are gitignored and must be manually added by each developer.

### Step 4: Generate Firebase Options Files

For dev and staging environments, generate Firebase options:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate dev options
flutterfire configure \
  --project=yajid-dev \
  --out=lib/firebase_options_dev.dart \
  --platforms=android,ios,web

# Generate staging options
flutterfire configure \
  --project=yajid-staging \
  --out=lib/firebase_options_staging.dart \
  --platforms=android,ios,web
```

### Step 5: Configure Firebase Services

For each project, enable:

- **Authentication** (Email/Password, Google, Apple)
- **Firestore Database**
- **Cloud Functions** (if needed)
- **Crashlytics** (staging & production only)
- **Performance Monitoring** (staging & production only)

## Building the App

### Development Build

```bash
# Debug build
flutter run --flavor dev -t lib/main_dev.dart

# Release build
flutter build apk --release --flavor dev -t lib/main_dev.dart
```

### Staging Build

```bash
# Debug build
flutter run --flavor staging -t lib/main_staging.dart

# Release build
flutter build apk --release --flavor staging -t lib/main_staging.dart
```

### Production Build

```bash
# Debug build
flutter run --flavor production -t lib/main_production.dart

# Release build
flutter build apk --release --flavor production -t lib/main_production.dart

# App Bundle for Play Store
flutter build appbundle --release --flavor production -t lib/main_production.dart
```

## Data Seeding

Development and staging environments can be populated with realistic fake data.

### Prerequisites

```bash
flutter pub get  # Installs faker package
```

### Running the Seed Script

```bash
# Make sure Firebase is configured first
flutter run scripts/seed_data.dart
```

This creates:
- 20 fake users
- 60 events (3 per user)
- 120 recommendations (10 per category)
- ~150 messages
- 160 notifications (8 per user)

**Safety**: The script will refuse to run in production environment.

## Environment Configuration

### Environment-Specific Settings

See `lib/config/env_config.dart`:

```dart
// Development
EnvConfig.dev = {
  appName: 'Yajid (Dev)',
  apiBaseUrl: 'https://dev-api.yajid.com',
  enableLogging: true,
  enableCrashlytics: false,
  showDebugBanner: true,
  firebaseProjectId: 'yajid-dev',
}

// Staging
EnvConfig.staging = {
  appName: 'Yajid (Staging)',
  apiBaseUrl: 'https://staging-api.yajid.com',
  enableLogging: true,
  enableCrashlytics: true,
  showDebugBanner: true,
  firebaseProjectId: 'yajid-staging',
}

// Production
EnvConfig.production = {
  appName: 'Yajid',
  apiBaseUrl: 'https://api.yajid.com',
  enableLogging: false,
  enableCrashlytics: true,
  showDebugBanner: false,
  firebaseProjectId: 'yajid-connect',
}
```

### Environment Indicators

- **Dev**: Orange banner with "DEVELOPMENT" label
- **Staging**: Blue banner with "STAGING" label
- **Production**: No banner (clean UI)

Tap the environment indicator to view detailed configuration.

## GitHub Actions CI/CD

### Branch Strategy

| Branch | Environment | Workflow | Auto-Deploy |
|--------|------------|----------|-------------|
| `develop` | Development | deploy-dev.yml | Yes |
| `staging` | Staging | deploy-staging.yml | Yes |
| `main` | Production | deploy-production.yml | Tags only |

### Workflow Triggers

**Development**:
- Push to `develop` branch
- Manual trigger via workflow_dispatch

**Staging**:
- Push to `staging` branch
- Pull requests to `main` (for testing before production)
- Manual trigger

**Production**:
- Push to `main` branch
- Version tags (e.g., `v1.0.0`)
- Manual trigger

### Required GitHub Secrets

Configure these secrets in your GitHub repository settings:

#### Firebase Secrets

```
FIREBASE_OPTIONS_DEV              # Contents of firebase_options_dev.dart
FIREBASE_OPTIONS_STAGING          # Contents of firebase_options_staging.dart
GOOGLE_SERVICES_JSON_DEV          # Contents of dev google-services.json
GOOGLE_SERVICES_JSON_STAGING      # Contents of staging google-services.json
GOOGLE_SERVICES_JSON_PRODUCTION   # Contents of production google-services.json
```

#### Firebase Distribution

```
FIREBASE_APP_ID_DEV               # Dev app ID from Firebase Console
FIREBASE_APP_ID_STAGING           # Staging app ID
FIREBASE_APP_ID_PRODUCTION        # Production app ID
FIREBASE_TOKEN                    # Firebase CI token (firebase login:ci)
FIREBASE_SERVICE_ACCOUNT_DEV      # Service account JSON for dev
FIREBASE_SERVICE_ACCOUNT_STAGING  # Service account JSON for staging
FIREBASE_SERVICE_ACCOUNT_PRODUCTION # Service account JSON for production
```

#### Play Store (Production Only)

```
PLAY_STORE_SERVICE_ACCOUNT        # Google Play service account JSON
```

#### Notifications (Optional)

```
SLACK_WEBHOOK_URL                 # For deployment notifications
```

### Generating Firebase Secrets

```bash
# Get Firebase CI token
firebase login:ci

# Get service account JSON
# Go to Firebase Console → Project Settings → Service Accounts
# Click "Generate new private key"
# Copy the entire JSON contents
```

## Testing

### Run All Tests

```bash
flutter test --coverage
```

### Run Integration Tests

```bash
# With Firebase Emulators
firebase emulators:start --only auth,firestore
flutter test integration_test/
```

## Deployment Workflow

### Development Deployment

1. Commit and push to `develop` branch
2. GitHub Actions automatically builds and deploys
3. APK uploaded to Firebase App Distribution
4. Developers/testers notified via email

### Staging Deployment

1. Merge `develop` into `staging`
2. GitHub Actions runs full test suite
3. Builds release APK
4. Deploys to Firebase App Distribution
5. QA team and stakeholders notified

### Production Deployment

1. Create pull request from `staging` to `main`
2. Code review and approval required
3. Merge to `main`
4. Create version tag: `git tag v1.0.0 && git push --tags`
5. GitHub Actions:
   - Runs full test suite
   - Builds signed release APK and App Bundle
   - Deploys to Play Store (internal track)
   - Deploys web app to Firebase Hosting
   - Creates GitHub release

## Troubleshooting

### Build Errors

**Error**: `google-services.json not found`
- Ensure the file is in the correct flavor directory
- Check that it's not gitignored accidentally

**Error**: `firebase_options_dev.dart not found`
- Run `flutterfire configure` to generate the file
- Ensure it's in the `lib/` directory

### CI/CD Errors

**Error**: `FIREBASE_OPTIONS_DEV secret not found`
- Add the secret to GitHub repository settings
- Copy the entire file contents, not just a snippet

**Error**: Firebase distribution failed
- Check that `FIREBASE_TOKEN` is valid
- Regenerate with `firebase login:ci` if expired

### Data Seeding Errors

**Error**: `Permission denied`
- Check Firestore security rules
- Ensure user is authenticated or rules allow writes

**Error**: Cannot run in production
- This is expected behavior for safety
- Switch to dev or staging environment

## Best Practices

1. **Never commit sensitive files**:
   - `google-services.json`
   - `firebase_options_dev.dart`
   - `firebase_options_staging.dart`

2. **Use separate Firebase projects**:
   - Prevents accidental data corruption
   - Allows independent scaling and billing

3. **Test in staging before production**:
   - Always merge to staging first
   - Run full QA test suite
   - Get stakeholder approval

4. **Use version tags for production releases**:
   - Semantic versioning: `v1.0.0`, `v1.1.0`, etc.
   - Triggers production deployment
   - Creates GitHub release automatically

5. **Monitor deployments**:
   - Check Firebase Console after deployment
   - Monitor Crashlytics for errors
   - Review performance metrics

6. **Seed data regularly**:
   - Re-seed dev/staging when testing new features
   - Keeps data fresh and realistic
   - Helps catch edge cases

## Support

For questions or issues with the multi-environment setup:

1. Check this documentation first
2. Review `scripts/README.md` for seeding help
3. Check `android/app/src/{env}/README.md` for Firebase config help
4. Open an issue on GitHub with the `environment` label

## Changelog

- **2025-10-09**: Initial multi-environment setup
  - Created dev, staging, production configurations
  - Added Android product flavors
  - Implemented data seeding service
  - Set up GitHub Actions workflows
  - Added environment indicator UI
