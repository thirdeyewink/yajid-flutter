import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:yajid/services/user_profile_service.dart';
import 'package:yajid/services/logging_service.dart';
import 'package:yajid/core/utils/secure_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserProfileService _userProfileService;
  final LoggingService _logger;
  final SecureStorageService _secureStorage;
  late StreamSubscription<User?> _userSubscription;

  AuthBloc({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    UserProfileService? userProfileService,
    LoggingService? logger,
    SecureStorageService? secureStorage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _userProfileService = userProfileService ?? UserProfileService(),
        _logger = logger ?? LoggingService(),
        _secureStorage = secureStorage ?? SecureStorageService(),
        super(const AuthInitial()) {

    // Listen to auth state changes
    _userSubscription = _firebaseAuth.authStateChanges().listen(
      (user) => add(AuthUserChanged(user)),
    );

    on<AuthStarted>(_onAuthStarted);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthAppleSignInRequested>(_onAuthAppleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    final user = event.user;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        // Save credentials to secure storage
        await _saveUserCredentials(credential.user!);
        _logger.info('User signed in successfully: ${credential.user!.uid}');
        emit(AuthAuthenticated(user: credential.user!));
      }
    } on FirebaseAuthException catch (e) {
      _logger.error('Sign in error: ${e.code}', e);
      emit(AuthError(message: _getErrorMessage(e.code)));
    } catch (e) {
      _logger.error('Unexpected sign in error', e);
      emit(const AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Sign up requested for email: ${event.email}');
    emit(const AuthLoading());
    try {
      print('AuthBloc: Creating user with email and password');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        print('AuthBloc: User created successfully, uid: ${credential.user!.uid}');

        // Update display name
        print('AuthBloc: Updating display name');
        await credential.user!.updateDisplayName('${event.firstName} ${event.lastName}');

        // Create user profile
        print('AuthBloc: Creating user profile in Firestore');
        await _userProfileService.createUserProfile(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          phoneNumber: event.phoneNumber,
          birthday: event.birthday?.toIso8601String(),
          gender: event.gender,
        );

        // Save credentials to secure storage
        print('AuthBloc: Saving user credentials to secure storage');
        await _saveUserCredentials(credential.user!);

        _logger.info('User registered successfully: ${credential.user!.uid}');
        print('AuthBloc: Emitting AuthAuthenticated state');
        emit(AuthAuthenticated(user: credential.user!));
      } else {
        print('AuthBloc: ERROR - credential.user is null');
      }
    } on FirebaseAuthException catch (e) {
      print('AuthBloc: FirebaseAuthException during signup: ${e.code} - ${e.message}');
      _logger.error('Sign up error: ${e.code}', e);
      emit(AuthError(message: _getErrorMessage(e.code)));
    } catch (e, stackTrace) {
      print('AuthBloc: Unexpected error during signup: $e');
      print('AuthBloc: Stack trace: $stackTrace');
      _logger.error('Unexpected sign up error', e);
      emit(const AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Initialize user profile if new user
        await _userProfileService.initializeUserProfile();
        // Save credentials to secure storage
        await _saveUserCredentials(userCredential.user!);
        _logger.info('Google sign in successful: ${userCredential.user!.uid}');
        emit(AuthAuthenticated(user: userCredential.user!));
      }
    } catch (e) {
      _logger.error('Google sign in error', e);
      emit(const AuthError(message: 'Google sign in failed'));
    }
  }

  Future<void> _onAuthAppleSignInRequested(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user != null) {
        // Initialize user profile if new user
        await _userProfileService.initializeUserProfile();
        // Save credentials to secure storage
        await _saveUserCredentials(userCredential.user!);
        _logger.info('Apple sign in successful: ${userCredential.user!.uid}');
        emit(AuthAuthenticated(user: userCredential.user!));
      }
    } catch (e) {
      _logger.error('Apple sign in error', e);
      emit(const AuthError(message: 'Apple sign in failed'));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _secureStorage.clearAuthData(), // Clear secure storage on sign out
      ]);
      _logger.info('User signed out successfully');
    } catch (e) {
      _logger.error('Sign out error', e);
      emit(const AuthError(message: 'Sign out failed'));
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: event.email);
      emit(AuthPasswordResetSent(email: event.email));
      _logger.info('Password reset email sent to: ${event.email}');
    } on FirebaseAuthException catch (e) {
      _logger.error('Password reset error: ${e.code}', e);
      emit(AuthError(message: _getErrorMessage(e.code)));
    } catch (e) {
      _logger.error('Unexpected password reset error', e);
      emit(const AuthError(message: 'An unexpected error occurred'));
    }
  }

  /// Save user credentials to secure storage
  Future<void> _saveUserCredentials(User user) async {
    try {
      await _secureStorage.saveUserCredentials(
        userId: user.uid,
        email: user.email ?? '',
      );
      _logger.debug('User credentials saved to secure storage for user: ${user.uid}');
    } catch (e) {
      _logger.error('Failed to save credentials to secure storage', e);
      // Don't throw - this shouldn't block authentication flow
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}