# Yajid Scripts

This directory contains utility scripts for the Yajid project.

## Data Seeding Script

### Purpose

The `seed_data.dart` script populates your development or staging Firebase environment with realistic fake data for testing purposes.

### What it creates:

- **20 fake users** with realistic profiles, avatars, and preferences
- **60 events** (3 per user) with dates, locations, and attendees
- **120 recommendations** across all 12 categories (movies, music, books, etc.)
- **~150 messages** in chat conversations between users
- **160 notifications** (8 per user) of various types

### Prerequisites:

1. **Firebase Configuration**: Ensure you have the appropriate `firebase_options_dev.dart` or `firebase_options_staging.dart` file
2. **Firestore Security Rules**: Temporarily relax security rules to allow batch writes (or use admin SDK)
3. **Dependencies**: Run `flutter pub get` to install the `faker` package

### Usage:

#### Method 1: Using Flutter (Recommended)

```bash
# For development environment
flutter run scripts/seed_data.dart --dart-define=ENV=dev

# For staging environment
flutter run scripts/seed_data.dart --dart-define=ENV=staging
```

#### Method 2: Direct Dart execution

```bash
dart run scripts/seed_data.dart
```

**Note**: You'll need to uncomment the Firebase initialization code in the script before running.

### Safety Features:

- **Production Protection**: The script will refuse to run if `currentConfig.isProduction` is true
- **Environment Detection**: Automatically detects which environment you're targeting
- **Confirmation Prompt**: Gives you 3 seconds to cancel before proceeding

### After Seeding:

Once the script completes, you can:

1. Log into your app with any of the seeded user emails
2. Browse seeded recommendations across all categories
3. View fake events in the calendar
4. See message conversations between users
5. Check notifications for various interaction types

### Clearing Seeded Data:

To clear all seeded data (useful for re-seeding):

```dart
final seedingService = DataSeedingService();
await seedingService.clearAllSeededData();
```

Or create a separate `clear_data.dart` script using this method.

### Customization:

You can modify the seeding parameters in `seed_data.dart`:

```dart
await seedingService.seedAllData(
  userCount: 50,              // Increase to 50 users
  eventsPerUser: 5,           // 5 events per user
  recommendationsPerCategory: 20,  // More recommendations
  messagesPerConversation: 30,     // Longer conversations
  notificationsPerUser: 12,        // More notifications
);
```

### Troubleshooting:

**Error: Firebase not initialized**
- Uncomment and configure Firebase initialization in `seed_data.dart`
- Ensure the correct `firebase_options_*.dart` file exists

**Error: Permission denied**
- Check your Firestore security rules
- Ensure you're authenticated (or rules allow unauthenticated writes for seeding)

**Error: Package 'faker' not found**
- Run `flutter pub get` to install dependencies

**Error: Already running in production**
- You cannot seed data in production
- Switch to dev or staging environment configuration

### Best Practices:

1. **Always seed on fresh databases** to avoid conflicts with real data
2. **Use separate Firebase projects** for dev, staging, and production
3. **Don't commit seeded data** to production Firestore
4. **Re-seed regularly** when testing major features to ensure clean state
5. **Adjust quantities** based on your testing needs (more users = slower seeding)

---

## Future Scripts

This directory will house additional utility scripts such as:

- `clear_data.dart` - Clear all seeded data from dev/staging
- `export_firestore.dart` - Export Firestore data for backup
- `migrate_data.dart` - Migrate data between environments
- `generate_reports.dart` - Generate usage reports from Firestore data
