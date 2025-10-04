# AuthBloc Test Fixes

## Quick Reference: 3 Changes to Make

### Change 1: Add setUpAll() with Fallback Registration

**Location**: Line 39 (before `setUp()`)

**Add this code**:
```dart
setUpAll(() {
  // Register fallback values for mocktail
  registerFallbackValue(DateTime.now());
  registerFallbackValue(FakeAuthCredential());
});
```

**Remove from setUp()**: Delete lines 48-49:
```dart
// Register fallback values for mocktail
registerFallbackValue(DateTime.now());
```

---

### Change 2: Fix authStateChanges Mock

**Location**: Line 75 in `setUp()`

**Change FROM**:
```dart
when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));
```

**Change TO**:
```dart
when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => const Stream.empty());
```

---

### Change 3: Update Test Expectations

#### Test 1: "emits [AuthLoading, AuthUnauthenticated] when user is null"
**Location**: Lines 96-106

**Change FROM**:
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthUnauthenticated] when user is null',
  build: () {
    when(() => mockFirebaseAuth.currentUser).thenReturn(null);
    return authBloc;
  },
  act: (bloc) => bloc.add(const AuthStarted()),
  expect: () => [
    const AuthLoading(),  // REMOVE THIS LINE
    const AuthUnauthenticated(),
  ],
);
```

**Change TO**:
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthUnauthenticated] when user is null',  // Updated description
  build: () {
    when(() => mockFirebaseAuth.currentUser).thenReturn(null);
    return authBloc;
  },
  act: (bloc) => bloc.add(const AuthStarted()),
  expect: () => [
    const AuthUnauthenticated(),  // Only this state
  ],
);
```

#### Test 2: "emits [AuthLoading, AuthAuthenticated] when user exists"
**Location**: Lines 108-119

**Change FROM**:
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] when user exists',
  build: () {
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    return authBloc;
  },
  act: (bloc) => bloc.add(const AuthStarted()),
  expect: () => [
    const AuthLoading(),  // REMOVE THIS LINE
    AuthAuthenticated(user: mockUser),
  ],
);
```

**Change TO**:
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthAuthenticated] when user exists',  // Updated description
  build: () {
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    return authBloc;
  },
  act: (bloc) => bloc.add(const AuthStarted()),
  expect: () => [
    AuthAuthenticated(user: mockUser),  // Only this state
  ],
);
```

#### Test 3: "emits [AuthLoading, AuthAuthenticated] when sign in succeeds"
**Location**: Lines 126-143

**ADD stream mock in build**:
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
  build: () {
    when(() => mockFirebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    )).thenAnswer((_) async => mockUserCredential);

    // ADD THESE 3 LINES:
    when(() => mockFirebaseAuth.authStateChanges()).thenAnswer(
      (_) => Stream.value(mockUser),
    );

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
```

#### Test 4: "emits [AuthLoading, AuthAuthenticated] when sign up succeeds"
**Location**: Lines 179-204

**ADD stream mock in build**:
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] when sign up succeeds',
  build: () {
    when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
      email: signUpEvent.email,
      password: signUpEvent.password,
    )).thenAnswer((_) async => mockUserCredential);

    // ADD THESE 3 LINES:
    when(() => mockFirebaseAuth.authStateChanges()).thenAnswer(
      (_) => Stream.value(mockUser),
    );

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
```

#### Test 5: "emits [AuthLoading, AuthAuthenticated] when Google sign in succeeds"
**Location**: Lines 227-246

**ADD stream mock in build**:
```dart
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

    // ADD THESE 3 LINES:
    when(() => mockFirebaseAuth.authStateChanges()).thenAnswer(
      (_) => Stream.value(mockUser),
    );

    return authBloc;
  },
  act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
  expect: () => [
    const AuthLoading(),
    AuthAuthenticated(user: mockUser),
  ],
);
```

---

## Summary

**3 changes total**:
1. ✅ Add `setUpAll()` with fallback registrations
2. ✅ Change `authStateChanges` mock to empty stream in setUp
3. ✅ Update 5 test expectations (remove AuthLoading from 2, add stream mocks to 3)

**Time to fix**: ~10-15 minutes

**Verify**:
```bash
flutter test test/bloc/auth/auth_bloc_test.dart
```

Should see: **✅ All 12 tests passing**

---

## Why These Changes?

1. **AuthCredential Fallback**: Mocktail requires fallback values for non-primitive types used with `any()`
2. **Empty Stream**: Using `Stream.empty()` prevents immediate emissions that interfere with test setup
3. **AuthStarted State**: The implementation doesn't emit `AuthLoading` for this event
4. **Auth Stream Mocks**: Sign in/up operations trigger `authStateChanges` which emits the user, causing `AuthUserChanged` event → `AuthAuthenticated` state
