/// Data seeding script for dev/staging environments
/// Run this script to populate Firebase with fake data for testing
///
/// Usage:
///   flutter run scripts/seed_data.dart
///   OR
///   dart run scripts/seed_data.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:yajid/config/env_config.dart';
import 'package:yajid/services/data_seeding_service.dart';

// Import the appropriate Firebase options based on environment
// You'll need to uncomment the appropriate import
// import 'package:yajid/firebase_options_dev.dart';
// import 'package:yajid/firebase_options_staging.dart';

void main() async {
  print('='.repeat(60));
  print('Yajid Data Seeding Script');
  print('='.repeat(60));

  // Check environment
  if (currentConfig.isProduction) {
    print('❌ ERROR: Data seeding is NOT allowed in production!');
    print('Please switch to dev or staging environment.');
    return;
  }

  print('Environment: ${currentConfig.environmentName}');
  print('Firebase Project: ${currentConfig.firebaseProjectId}');
  print('');

  // Initialize Firebase
  print('Initializing Firebase...');
  try {
    // TODO: Uncomment the appropriate line based on your environment
    // For dev: await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // For staging: await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Placeholder - you need to initialize Firebase with the correct options
    print('⚠️  WARNING: Firebase initialization is commented out.');
    print('Please uncomment the appropriate Firebase initialization in scripts/seed_data.dart');
    print('');
  } catch (e) {
    print('❌ ERROR: Failed to initialize Firebase: $e');
    return;
  }

  // Create seeding service
  final seedingService = DataSeedingService();

  print('Configuration:');
  print('  - Users: 20');
  print('  - Events per user: 3');
  print('  - Recommendations per category: 10');
  print('  - Messages per conversation: 15');
  print('  - Notifications per user: 8');
  print('');

  // Confirm before proceeding
  print('⚠️  This will populate your ${currentConfig.environmentName} Firebase with fake data.');
  print('Continue? (This is an automated script - it will proceed in 3 seconds)');
  await Future.delayed(const Duration(seconds: 3));

  print('');
  print('Starting data seeding...');
  print('-' * 60);

  try {
    await seedingService.seedAllData(
      userCount: 20,
      eventsPerUser: 3,
      recommendationsPerCategory: 10,
      messagesPerConversation: 15,
      notificationsPerUser: 8,
    );

    print('-' * 60);
    print('✅ SUCCESS: Data seeding completed!');
    print('');
    print('Summary:');
    print('  - 20 fake users created');
    print('  - 60 events created (3 per user)');
    print('  - 120 recommendations created (10 per category)');
    print('  - ~150 messages created');
    print('  - 160 notifications created (8 per user)');
    print('');
    print('You can now use your ${currentConfig.environmentName} environment with realistic data!');
  } catch (e) {
    print('-' * 60);
    print('❌ ERROR: Data seeding failed: $e');
    print('');
    print('Please check:');
    print('  1. Firebase is properly initialized');
    print('  2. Firestore security rules allow writes');
    print('  3. You have internet connectivity');
  }

  print('='.repeat(60));
}

extension StringRepeat on String {
  String repeat(int count) => List.filled(count, this).join();
}
