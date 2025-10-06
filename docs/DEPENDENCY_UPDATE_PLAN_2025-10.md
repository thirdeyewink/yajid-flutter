# Dependency Update Plan - October 2025

**Project:** Yajid - Lifestyle & Social Discovery Super App
**Plan Date:** October 6, 2025
**Status:** Proposed
**Priority:** P2 - Medium (Security & Performance)
**Estimated Time:** 1-2 weeks (with thorough testing)

---

## Executive Summary

Currently, **48 packages have newer versions** with many involving breaking changes. This plan outlines a phased, risk-managed approach to updating dependencies while maintaining app stability.

**Key Updates:**
- Firebase packages: 5.x → 6.x (BREAKING CHANGES)
- BLoC/flutter_bloc: 8.x → 9.x (BREAKING CHANGES)
- Google Sign-In: 6.x → 7.x (BREAKING CHANGES)
- 45 other packages with minor/patch updates

**Benefits:**
- ✅ Security patches and bug fixes
- ✅ Performance improvements
- ✅ New features and APIs
- ✅ Better Flutter 3.x compatibility
- ✅ Reduced technical debt

**Risks:**
- ⚠️ Breaking changes may require code refactoring
- ⚠️ Potential regressions and bugs
- ⚠️ Time investment for testing

---

## Current Dependency Status

### Critical Direct Dependencies

| Package | Current | Latest | Type | Breaking Changes |
|---------|---------|--------|------|------------------|
| **firebase_core** | 3.15.2 | 4.1.1 | Major | ✅ Yes - v4.0.0+ |
| **firebase_auth** | 5.7.0 | 6.1.0 | Major | ✅ Yes - v6.0.0+ |
| **cloud_firestore** | 5.6.12 | 6.0.2 | Major | ✅ Yes - v6.0.0+ |
| **cloud_functions** | 5.6.2 | 6.0.2 | Major | ✅ Yes - v6.0.0+ |
| **firebase_crashlytics** | 4.3.10 | 5.0.2 | Major | ✅ Yes - v5.0.0+ |
| **firebase_performance** | 0.10.1+10 | 0.11.1 | Minor | ❌ No |
| **google_sign_in** | 6.3.0 | 7.2.0 | Major | ✅ Yes - v7.0.0+ |
| **sign_in_with_apple** | 6.1.4 | 7.0.1 | Major | ✅ Yes - v7.0.0+ |
| **flutter_bloc** | 8.1.6 | 9.1.1 | Major | ✅ Yes - v9.0.0+ |
| **bloc** | 8.1.4 | 9.0.1 | Major | ✅ Yes - v9.0.0+ |
| **bloc_test** | 9.1.7 | 10.0.0 | Major | ✅ Yes - v10.0.0+ |
| **flutter_secure_storage** | 9.0.0 | Latest | ✅ | ✅ Up to date |
| **flutter_lints** | 5.0.0 | 6.0.0 | Major | ✅ Yes - v6.0.0+ |
| **geolocator** | 13.0.4 | 14.0.2 | Major | ✅ Yes - v14.0.0+ |

### Transitive Dependencies (45 packages)
- Most are automatically updated with direct dependencies
- Some may have constraint conflicts requiring resolution

---

## Update Strategy: Phased Approach

### Phase 1: Preparation (1-2 days)

**Objectives:**
- Research breaking changes
- Create update branches
- Backup current working state

**Tasks:**
1. ✅ Create git branch: `feature/dependency-updates-oct-2025`
2. ✅ Document current test coverage baseline (21.3%)
3. ✅ Backup firebase config and security rules
4. ✅ Review changelogs for all major updates
5. ✅ Identify code that will break with updates

**Deliverables:**
- Update branch created
- Breaking changes documented
- Test baseline established

---

### Phase 2: BLoC Update (2-3 days)

**Priority:** High (affects state management across app)

**Updates:**
- bloc: 8.1.4 → 9.0.1
- flutter_bloc: 8.1.6 → 9.1.1
- bloc_test: 9.1.7 → 10.0.0

**Breaking Changes (BLoC 9.0.0):**
1. **Removed deprecated APIs**
   - `transformEvents` and `transformTransitions` removed
   - Use `EventTransformer` instead

2. **Stream behavior changes**
   - More strict typing
   - Better null safety

**Migration Steps:**
```bash
# 1. Update pubspec.yaml
bloc: ^9.0.1
flutter_bloc: ^9.1.1
bloc_test: ^10.0.0

# 2. Run pub get
flutter pub get

# 3. Fix breaking changes in BLoC files
# lib/bloc/auth/auth_bloc.dart
# lib/bloc/profile/profile_bloc.dart
# lib/bloc/gamification/gamification_bloc.dart
# lib/bloc/navigation/navigation_bloc.dart
# lib/bloc/venue/venue_bloc.dart
# lib/bloc/booking/booking_bloc.dart
# lib/bloc/payment/payment_bloc.dart

# 4. Update tests
flutter test test/bloc/

# 5. Verify no analyzer issues
flutter analyze
```

**Testing:**
- ✅ All BLoC unit tests pass
- ✅ No analyzer warnings
- ✅ Manual testing of auth flow, profile, gamification

**Rollback Plan:** Revert pubspec.yaml, run `flutter pub get`

---

### Phase 3: Firebase Updates (3-4 days)

**Priority:** Critical (breaking changes in Auth & Firestore)

**Updates:**
- firebase_core: 3.15.2 → 4.1.1
- firebase_auth: 5.7.0 → 6.1.0
- cloud_firestore: 5.6.12 → 6.0.2
- cloud_functions: 5.6.2 → 6.0.2
- firebase_crashlytics: 4.3.10 → 5.0.2

**Breaking Changes (Firebase 6.0.0):**

**1. Firebase Auth (v6.0.0+):**
- `User.photoURL` → `User.photoUrl` (camelCase)
- `User.displayName` may be nullable
- Social auth provider changes

**2. Cloud Firestore (v6.0.0+):**
- Collection reference typing changes
- Query API improvements (may require type updates)
- Timestamp handling changes

**3. Firebase Crashlytics (v5.0.0+):**
- API modernization
- New error reporting methods

**Migration Steps:**
```bash
# 1. Update pubspec.yaml
firebase_core: ^4.1.1
firebase_auth: ^6.1.0
cloud_firestore: ^6.0.2
cloud_functions: ^6.0.2
firebase_crashlytics: ^5.0.2

# 2. Run pub get
flutter pub get

# 3. Update Firebase initialization (main.dart)
# Check for API changes in Firebase.initializeApp()

# 4. Fix Auth API changes
# Search and replace: photoURL → photoUrl
# Add null checks for displayName

# 5. Fix Firestore query types
# Update collection references with explicit types

# 6. Update Crashlytics calls
# Check error reporting method signatures

# 7. Run tests
flutter test
```

**Critical Files to Update:**
- `lib/main.dart` (Firebase init, Crashlytics)
- `lib/bloc/auth/auth_bloc.dart` (Auth API changes)
- `lib/services/user_profile_service.dart` (Firestore queries)
- `lib/services/messaging_service.dart` (Firestore queries)
- `lib/services/gamification_service.dart` (Firestore queries)

**Testing:**
- ✅ Authentication flows (email, Google, Apple)
- ✅ Firestore CRUD operations
- ✅ Cloud Functions calls (if any)
- ✅ Crashlytics error reporting
- ✅ All integration tests pass

**Rollback Plan:** Major rollback - revert branch, comprehensive testing

---

### Phase 4: Auth Providers Update (1-2 days)

**Priority:** Medium (affects social login)

**Updates:**
- google_sign_in: 6.3.0 → 7.2.0
- sign_in_with_apple: 6.1.4 → 7.0.1

**Breaking Changes:**

**Google Sign-In (v7.0.0+):**
- Platform-specific implementations changed
- New callback structure
- Improved error handling

**Sign in with Apple (v7.0.0+):**
- API modernization
- Better null safety

**Migration Steps:**
```bash
# 1. Update pubspec.yaml
google_sign_in: ^7.2.0
sign_in_with_apple: ^7.0.1

# 2. Update auth service
# lib/auth_service.dart
# lib/bloc/auth/auth_bloc.dart

# 3. Test social logins
```

**Testing:**
- ✅ Google Sign-In (Android & iOS)
- ✅ Sign in with Apple (iOS)
- ✅ Error handling and edge cases

---

### Phase 5: Other Dependencies (1-2 days)

**Priority:** Low (minor/patch updates)

**Updates:**
- geolocator: 13.0.4 → 14.0.2 (for astronomical service)
- flutter_lints: 5.0.0 → 6.0.0 (new lint rules)
- All transitive dependencies

**Migration Steps:**
```bash
# 1. Update pubspec.yaml with remaining packages
flutter_lints: ^6.0.0
geolocator: ^14.0.2

# 2. Address new lint warnings
flutter analyze

# 3. Fix astronomical service if geolocator API changed
```

**Testing:**
- ✅ Prayer time calculations work
- ✅ No new lint violations
- ✅ All tests pass

---

### Phase 6: Final Validation (1 day)

**Comprehensive Testing:**
1. ✅ All unit tests pass (398 tests)
2. ✅ flutter analyze: 0 issues
3. ✅ Integration tests reviewed
4. ✅ Manual testing checklist:
   - [ ] Auth flows (email, Google, Apple, phone)
   - [ ] Profile management
   - [ ] Gamification (points, badges, levels)
   - [ ] Recommendations (all 11 categories)
   - [ ] Messaging (chat, inbox)
   - [ ] Calendar and events
   - [ ] Notifications
   - [ ] Language switching (5 languages)
   - [ ] Theme switching (dark/light)
   - [ ] Venue search and booking
   - [ ] Payment flow (if implemented)

5. ✅ Performance testing:
   - [ ] App startup time <2s
   - [ ] No memory leaks
   - [ ] Smooth UI (60fps)

6. ✅ Production build testing:
   - [ ] `flutter build apk --release`
   - [ ] ProGuard obfuscation works
   - [ ] No debug logging in release
   - [ ] Crashlytics integration works

---

## Breaking Changes Reference

### BLoC 9.0.0 Breaking Changes
```dart
// BEFORE (v8.x)
class MyBloc extends Bloc<MyEvent, MyState> {
  @override
  Stream<Transition<MyEvent, MyState>> transformEvents(
    Stream<MyEvent> events,
    TransitionFunction<MyEvent, MyState> transitionFn,
  ) {
    return events.debounceTime(Duration(milliseconds: 300))
        .switchMap(transitionFn);
  }
}

// AFTER (v9.x)
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyInitialState()) {
    on<MyEvent>(
      _onMyEvent,
      transformer: debounce(Duration(milliseconds: 300)),
    );
  }
}
```

### Firebase Auth 6.0.0 Breaking Changes
```dart
// BEFORE (v5.x)
final photoURL = user.photoURL;
final name = user.displayName;

// AFTER (v6.x)
final photoUrl = user.photoUrl; // Note: camelCase
final name = user.displayName ?? 'Unknown'; // May be null
```

### Cloud Firestore 6.0.0 Breaking Changes
```dart
// BEFORE (v5.x)
final collection = firestore.collection('users');
final query = collection.where('age', isGreaterThan: 18);

// AFTER (v6.x) - Explicit typing
final collection = firestore.collection('users').withConverter<UserModel>(
  fromFirestore: (snap, _) => UserModel.fromMap(snap.data()!),
  toFirestore: (user, _) => user.toMap(),
);
```

### Google Sign-In 7.0.0 Breaking Changes
```dart
// BEFORE (v6.x)
final account = await GoogleSignIn().signIn();

// AFTER (v7.x)
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);
final account = await googleSignIn.signIn();
```

---

## Risk Mitigation

### High-Risk Changes
1. **Firebase Auth 6.0.0**
   - Risk: Authentication may break
   - Mitigation: Comprehensive auth flow testing
   - Rollback: Keep v5.x branch for quick revert

2. **BLoC 9.0.0**
   - Risk: State management breaks
   - Mitigation: Update all BLoCs systematically
   - Rollback: Revert pubspec, test thoroughly

3. **Cloud Firestore 6.0.0**
   - Risk: Data queries may fail
   - Mitigation: Type all queries explicitly
   - Rollback: Database structure unchanged, code revert OK

### Medium-Risk Changes
- Google/Apple Sign-In updates (isolated to auth service)
- Geolocator update (isolated to astronomical service)

### Low-Risk Changes
- Transitive dependencies (auto-updated)
- Lint rules (non-breaking)

---

## Timeline

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| **Phase 1: Preparation** | 1-2 days | None |
| **Phase 2: BLoC Update** | 2-3 days | Phase 1 complete |
| **Phase 3: Firebase Update** | 3-4 days | Phase 2 complete |
| **Phase 4: Auth Providers** | 1-2 days | Phase 3 complete |
| **Phase 5: Other Deps** | 1-2 days | Phase 4 complete |
| **Phase 6: Validation** | 1 day | All phases complete |
| **Total** | **9-14 days** | Sequential execution |

**Recommended Schedule:**
- Week 1: Phases 1-3 (BLoC + Firebase)
- Week 2: Phases 4-6 (Auth Providers + Final validation)

---

## Success Criteria

### Must Have (P0)
- ✅ All 398 tests pass
- ✅ flutter analyze: 0 issues
- ✅ No regressions in core features
- ✅ Authentication works (all providers)
- ✅ Firestore CRUD operations work
- ✅ Production build succeeds

### Should Have (P1)
- ✅ Performance maintained (startup <2s)
- ✅ No memory leaks
- ✅ Crashlytics still reporting errors
- ✅ All Firebase features work

### Nice to Have (P2)
- ✅ New features utilized (if any)
- ✅ Performance improvements measured
- ✅ Code quality improved with new lints

---

## Rollback Strategy

### Quick Rollback (if issues found early)
```bash
# Revert pubspec.yaml changes
git checkout main -- pubspec.yaml
flutter pub get
flutter analyze
flutter test
```

### Full Rollback (if issues in production)
```bash
# Revert entire branch
git reset --hard origin/main
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

### Partial Rollback (if one package problematic)
```bash
# Revert single package in pubspec.yaml
# e.g., keep firebase_auth: ^5.7.0 if v6 breaks
flutter pub get
flutter test
```

---

## Post-Update Actions

1. **Documentation Updates**
   - [ ] Update pubspec.yaml
   - [ ] Update CHANGELOG.md
   - [ ] Update README.md (if dependency versions mentioned)
   - [ ] Update ADRs (if architecture affected)

2. **Code Quality**
   - [ ] Address new lint warnings (flutter_lints 6.0)
   - [ ] Refactor code using new APIs (if beneficial)
   - [ ] Update deprecated API usage

3. **Monitoring**
   - [ ] Monitor Crashlytics for new errors
   - [ ] Track performance metrics
   - [ ] Monitor user reports for issues

4. **Team Communication**
   - [ ] Notify team of breaking changes
   - [ ] Update development guidelines
   - [ ] Document migration learnings

---

## Alternative: Incremental Updates

If full update is too risky, consider incremental approach:

**Option A: Security-Only Updates**
- Update only packages with security patches
- Skip breaking changes for now
- Lower risk, partial benefit

**Option B: Non-Breaking Updates First**
- Update patch/minor versions only
- Defer major version updates
- Gradual migration path

**Option C: Update on Next Major Release**
- Keep current versions for MVP/v1.0
- Plan full update for v2.0
- Align with major feature releases

---

## Resources

### Changelogs
- [BLoC 9.0.0 Migration Guide](https://bloclibrary.dev/migration/)
- [Firebase FlutterFire 6.0.0 Release Notes](https://firebase.google.com/support/release-notes/flutter)
- [Google Sign-In 7.0.0 Changelog](https://pub.dev/packages/google_sign_in/changelog)
- [Flutter Lints 6.0.0 Changelog](https://pub.dev/packages/flutter_lints/changelog)

### Testing Resources
- Firebase Emulator Suite (for testing Firebase changes)
- BLoC testing best practices
- Flutter integration testing guide

### Team Support
- Dedicated Slack channel: #dependency-updates
- Daily standups during update phases
- Code review: Mandatory for all migration PRs

---

## Recommendation

**Recommended Approach:** **Phased Update** (Phases 1-6)

**Reasoning:**
1. ✅ Systematic risk management
2. ✅ Catch issues early with incremental testing
3. ✅ Easy rollback at any phase
4. ✅ Team can focus on one area at a time
5. ✅ Comprehensive validation at each step

**When to Start:** After current sprint / Before next major feature

**Prerequisites:**
- ✅ Test coverage >30% (currently 21.3% - improve first)
- ✅ All P0/P1 bugs fixed
- ✅ Stable production baseline
- ✅ Team availability (9-14 days)

---

**Plan Status:** Proposed
**Next Steps:**
1. Review and approve plan
2. Schedule update window
3. Create update branch
4. Begin Phase 1 (Preparation)

**Owner:** Technical Lead
**Reviewers:** Engineering Team
**Approval Required:** Yes

---

**Document Version:** 1.0
**Last Updated:** October 6, 2025
**Next Review:** Before update begins
