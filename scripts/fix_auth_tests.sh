#!/bin/bash

# Quick fix script for AuthBloc tests
# This script applies necessary changes to fix the 6 failing AuthBloc tests

echo "Fixing AuthBloc tests..."

# Backup original file
cp test/bloc/auth/auth_bloc_test.dart test/bloc/auth/auth_bloc_test.dart.backup

# Apply fixes using sed
# 1. Add setUpAll with fallback registration
sed -i '/void main() {/a\
  group('\''AuthBloc'\'', () {\
    late AuthBloc authBloc;\
    late MockFirebaseAuth mockFirebaseAuth;\
    late MockGoogleSignIn mockGoogleSignIn;\
    late MockUserProfileService mockUserProfileService;\
    late MockLoggingService mockLoggingService;\
    late MockSecureStorageService mockSecureStorage;\
    late MockUser mockUser;\
    late MockUserCredential mockUserCredential;\
\
    setUpAll(() {\
      registerFallbackValue(DateTime.now());\
      registerFallbackValue(FakeAuthCredential());\
    });
' test/bloc/auth/auth_bloc_test.dart

echo "Fix applied! Run 'flutter test test/bloc/auth/auth_bloc_test.dart' to verify"
