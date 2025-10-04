import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:yajid/bloc/auth/auth_bloc.dart';
import 'package:yajid/bloc/auth/auth_event.dart';
import 'package:yajid/bloc/auth/auth_state.dart';
import 'package:yajid/services/user_profile_service.dart';
import 'package:yajid/services/logging_service.dart';
import 'package:yajid/core/utils/secure_storage.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}
class MockUserProfileService extends Mock implements UserProfileService {}
class MockLoggingService extends Mock implements LoggingService {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

// Fake classes for fallback values
class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockUserProfileService mockUserProfileService;
    late MockLoggingService mockLoggingService;
    late MockSecureStorageService mockSecureStorage;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUpAll(() {
      // Register fallback values for mocktail ONCE for all tests
      registerFallbackValue(DateTime.now());
      registerFallbackValue(FakeAuthCredential());
    });

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      mockUserProfileService = MockUserProfileService();
      mockLoggingService = MockLoggingService();
      mockSecureStorage = MockSecureStorageService();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      // Set up common mocks BEFORE creating AuthBloc
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUserProfileService.createUserProfile(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        email: any(named: 'email'),
        phoneNumber: any(named: 'phoneNumber'),
        birthday: any(named: 'birthday'),
        gender: any(named: 'gender'),
      )).thenAnswer((_) async => true);
      when(() => mockUserProfileService.initializeUserProfile()).thenAnswer((_) async => true);
      when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
      when(() => mockLoggingService.info(any())).thenReturn(null);
      when(() => mockLoggingService.error(any(), any())).thenReturn(null);
      when(() => mockLoggingService.debug(any())).thenReturn(null);
      when(() => mockSecureStorage.saveUserCredentials(
        userId: any(named: 'userId'),
        email: any(named: 'email'),
      )).thenAnswer((_) async => true);
      when(() => mockSecureStorage.clearAuthData()).thenAnswer((_) async => true);
      // CRITICAL: Set up authStateChanges mock BEFORE creating AuthBloc
      when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => const Stream.empty());

      authBloc = AuthBloc(
        firebaseAuth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
        userProfileService: mockUserProfileService,
        logger: mockLoggingService,
        secureStorage: mockSecureStorage,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    group('AuthStarted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when user is null',
        build: () {
          when(() => mockFirebaseAuth.currentUser).thenReturn(null);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthStarted()),
        expect: () => [
          const AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] when user exists',
        build: () {
          when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthStarted()),
        expect: () => [
          AuthAuthenticated(user: mockUser),
        ],
      );
    });

    group('AuthSignInRequested', () {
      const email = 'test@example.com';
      const password = 'password123';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
        build: () {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenAnswer((_) async => mockUserCredential);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(user: mockUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails with user-not-found',
        build: () {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenThrow(FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'No user found with this email address.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails with wrong-password',
        build: () {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenThrow(FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Incorrect password.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails with invalid-email',
        build: () {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenThrow(FirebaseAuthException(
            code: 'invalid-email',
            message: 'Invalid email',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Invalid email address.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails with user-disabled',
        build: () {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenThrow(FirebaseAuthException(
            code: 'user-disabled',
            message: 'User disabled',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'This account has been disabled.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails with too-many-requests',
        build: () {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenThrow(FirebaseAuthException(
            code: 'too-many-requests',
            message: 'Too many requests',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Too many attempts. Please try again later.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails with network-request-failed',
        build: () {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).thenThrow(FirebaseAuthException(
            code: 'network-request-failed',
            message: 'Network error',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: email,
          password: password,
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'An error occurred. Please try again.'),
        ],
      );
    });

    group('AuthSignUpRequested', () {
      final signUpEvent = AuthSignUpRequested(
        email: 'test@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        birthday: DateTime(1990, 1, 1),
        gender: 'Male',
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign up succeeds',
        build: () {
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: signUpEvent.email,
            password: signUpEvent.password,
          )).thenAnswer((_) async => mockUserCredential);
          return authBloc;
        },
        act: (bloc) => bloc.add(signUpEvent),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(user: mockUser),
        ],
        verify: (_) {
          verify(() => mockUser.updateDisplayName('John Doe')).called(1);
          verify(() => mockUserProfileService.createUserProfile(
            firstName: 'John',
            lastName: 'Doe',
            email: 'test@example.com',
            phoneNumber: '+1234567890',
            birthday: any(named: 'birthday'),
            gender: 'Male',
          )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign up fails with email-already-in-use',
        build: () {
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: signUpEvent.email,
            password: signUpEvent.password,
          )).thenThrow(FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email already in use',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(signUpEvent),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'An account already exists with this email address.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign up fails with weak-password',
        build: () {
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: signUpEvent.email,
            password: signUpEvent.password,
          )).thenThrow(FirebaseAuthException(
            code: 'weak-password',
            message: 'Weak password',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(signUpEvent),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Password is too weak.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign up fails with invalid-email',
        build: () {
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: signUpEvent.email,
            password: signUpEvent.password,
          )).thenThrow(FirebaseAuthException(
            code: 'invalid-email',
            message: 'Invalid email',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(signUpEvent),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Invalid email address.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign up fails with operation-not-allowed',
        build: () {
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: signUpEvent.email,
            password: signUpEvent.password,
          )).thenThrow(FirebaseAuthException(
            code: 'operation-not-allowed',
            message: 'Operation not allowed',
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(signUpEvent),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'An error occurred. Please try again.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when profile creation fails after successful sign up',
        build: () {
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: signUpEvent.email,
            password: signUpEvent.password,
          )).thenAnswer((_) async => mockUserCredential);
          when(() => mockUserProfileService.createUserProfile(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            email: any(named: 'email'),
            phoneNumber: any(named: 'phoneNumber'),
            birthday: any(named: 'birthday'),
            gender: any(named: 'gender'),
          )).thenThrow(Exception('Profile creation failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(signUpEvent),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'An unexpected error occurred'),
        ],
      );
    });

    group('AuthGoogleSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when Google sign in succeeds',
        build: () {
          final mockGoogleUser = MockGoogleSignInAccount();
          final mockGoogleAuth = MockGoogleSignInAuthentication();

          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
          when(() => mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
          when(() => mockGoogleAuth.accessToken).thenReturn('access-token');
          when(() => mockGoogleAuth.idToken).thenReturn('id-token');
          when(() => mockFirebaseAuth.signInWithCredential(any()))
              .thenAnswer((_) async => mockUserCredential);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(user: mockUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when Google sign in fails with exception',
        build: () {
          when(() => mockGoogleSignIn.signIn()).thenThrow(Exception('Google Sign In failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Google sign in failed'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when user cancels Google sign in',
        build: () {
          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when Google authentication returns null access token',
        build: () {
          final mockGoogleUser = MockGoogleSignInAccount();
          final mockGoogleAuth = MockGoogleSignInAuthentication();

          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
          when(() => mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
          when(() => mockGoogleAuth.accessToken).thenReturn(null);
          when(() => mockGoogleAuth.idToken).thenReturn('id-token');
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Google sign in failed'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when Google authentication returns null id token',
        build: () {
          final mockGoogleUser = MockGoogleSignInAccount();
          final mockGoogleAuth = MockGoogleSignInAuthentication();

          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
          when(() => mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
          when(() => mockGoogleAuth.accessToken).thenReturn('access-token');
          when(() => mockGoogleAuth.idToken).thenReturn(null);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Google sign in failed'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when Firebase sign in with Google credential fails',
        build: () {
          final mockGoogleUser = MockGoogleSignInAccount();
          final mockGoogleAuth = MockGoogleSignInAuthentication();

          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
          when(() => mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
          when(() => mockGoogleAuth.accessToken).thenReturn('access-token');
          when(() => mockGoogleAuth.idToken).thenReturn('id-token');
          when(() => mockFirebaseAuth.signInWithCredential(any()))
              .thenThrow(FirebaseAuthException(
                code: 'account-exists-with-different-credential',
                message: 'Account exists',
              ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Google sign in failed'),
        ],
      );
    });

    group('AuthPasswordResetRequested', () {
      const email = 'test@example.com';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthPasswordResetSent] when password reset succeeds',
        build: () {
          when(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
              .thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: email)),
        expect: () => [
          const AuthLoading(),
          const AuthPasswordResetSent(email: email),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when password reset fails with user-not-found',
        build: () {
          when(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
              .thenThrow(FirebaseAuthException(
                code: 'user-not-found',
                message: 'User not found',
              ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: email)),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'No user found with this email address.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when password reset fails with invalid-email',
        build: () {
          when(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
              .thenThrow(FirebaseAuthException(
                code: 'invalid-email',
                message: 'Invalid email',
              ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: email)),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Invalid email address.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when password reset fails with too-many-requests',
        build: () {
          when(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
              .thenThrow(FirebaseAuthException(
                code: 'too-many-requests',
                message: 'Too many requests',
              ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: email)),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Too many attempts. Please try again later.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when password reset fails with network error',
        build: () {
          when(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
              .thenThrow(FirebaseAuthException(
                code: 'network-request-failed',
                message: 'Network error',
              ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: email)),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'An error occurred. Please try again.'),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'calls sign out methods when sign out succeeds',
        build: () {
          when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
          when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [],
        verify: (_) {
          verify(() => mockFirebaseAuth.signOut()).called(1);
          verify(() => mockGoogleSignIn.signOut()).called(1);
          verify(() => mockSecureStorage.clearAuthData()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthError] when Firebase sign out fails',
        build: () {
          when(() => mockFirebaseAuth.signOut()).thenThrow(Exception('Sign out failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthError(message: 'Sign out failed'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthError] when Google sign out fails',
        build: () {
          when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
          when(() => mockGoogleSignIn.signOut()).thenThrow(Exception('Google sign out failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthError(message: 'Sign out failed'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthError] when secure storage clear fails',
        build: () {
          when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
          when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
          when(() => mockSecureStorage.clearAuthData()).thenThrow(Exception('Storage clear failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthError(message: 'Sign out failed'),
        ],
      );
    });

    group('AuthUserChanged', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] when user is not null',
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthUserChanged(mockUser)),
        expect: () => [
          AuthAuthenticated(user: mockUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when user is null',
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthUserChanged(null)),
        expect: () => [
          const AuthUnauthenticated(),
        ],
      );
    });
  });
}