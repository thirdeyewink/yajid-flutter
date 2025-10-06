# ADR-001: Mixed State Management (Provider + BLoC)

**Status:** Accepted
**Date:** October 6, 2025
**Deciders:** Technical Team
**Technical Story:** [Identified during Oct 6, 2025 code analysis](#context)

---

## Context and Problem Statement

The Yajid application currently uses two different state management approaches:
1. **Provider** pattern for simple, app-wide state (locale, theme, onboarding)
2. **BLoC** pattern for complex business logic and feature-specific state (auth, profile, gamification, etc.)

This mixed approach was discovered during comprehensive codebase analysis. A comment in `lib/main.dart` marks Provider implementations as "Legacy Provider support for migration", suggesting an incomplete transition to BLoC.

**Key Question**: Should we complete the migration to BLoC, or is the mixed approach intentional and beneficial?

---

## Decision Drivers

### Technical Factors
- **Code Consistency**: Unified patterns are easier to maintain and understand
- **Learning Curve**: New developers must learn both patterns
- **Testability**: Both Provider and BLoC are testable, but with different approaches
- **Performance**: Both patterns perform well for their use cases
- **Boilerplate**: Provider has less boilerplate for simple state; BLoC requires more setup

### Business Factors
- **Time to Market**: Migration would require 1-2 weeks of development time
- **Risk**: Migration could introduce bugs in stable features
- **Team Expertise**: Team is comfortable with both patterns
- **Future Maintainability**: Consistency reduces long-term maintenance costs

### Current Usage Analysis

**Provider Pattern** (3 implementations):
```dart
// In main.dart - marked as "Legacy Provider support for migration"
ChangeNotifierProvider(create: (context) => LocaleProvider()),
ChangeNotifierProvider(create: (context) => ThemeProvider()),
ChangeNotifierProvider(create: (context) => OnboardingProvider()),
```

**Characteristics**:
- ✅ Simple, app-wide state
- ✅ Minimal boilerplate
- ✅ Perfect for theme/locale settings
- ✅ No complex async operations
- ✅ UI-driven state changes

**BLoC Pattern** (7 implementations):

**App-Level BLoCs** (wired in main.dart):
```dart
BlocProvider<AuthBloc>(create: (context) => AuthBloc()..add(const AuthStarted())),
BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()),
```

**Feature-Level BLoCs** (provided at screen level):
- `GamificationBloc` - Complex point calculation, badge unlocking
- `NavigationBloc` - Bottom navigation state
- `VenueBloc` - Venue search and filtering
- `BookingBloc` - Booking workflow
- `PaymentBloc` - Payment processing

**Characteristics**:
- ✅ Complex business logic
- ✅ Async operations with multiple states
- ✅ Event-driven architecture
- ✅ Comprehensive testing support
- ✅ Clear separation of concerns
- ⚠️ More boilerplate than Provider

---

## Considered Options

### Option 1: Complete Migration to BLoC (100% BLoC)
**Description**: Convert all Provider implementations to BLoC pattern.

**Pros** ✅:
- Complete consistency across the codebase
- Single pattern to learn for new developers
- Unified testing approach
- Clear architectural standard

**Cons** ❌:
- 1-2 weeks development time
- Risk of introducing bugs in stable features
- Unnecessary complexity for simple state (theme, locale)
- More boilerplate for simple use cases
- No immediate business value

**Impact**:
- Time: 1-2 weeks
- Risk: Medium (touching stable features)
- Benefit: Long-term maintainability

### Option 2: Keep Mixed Approach (Provider + BLoC) ✅ SELECTED
**Description**: Maintain current hybrid approach with clear guidelines on when to use each pattern.

**Pros** ✅:
- **Pragmatic**: Right tool for the right job
- **No Migration Risk**: Existing code remains stable
- **Developer Productivity**: Less boilerplate for simple state
- **Best of Both Worlds**: Simple for UI state, robust for business logic
- **Industry Standard**: Many Flutter apps use this pattern (e.g., Google I/O app)
- **Zero Development Time**: No migration needed

**Cons** ❌:
- Two patterns to learn
- Requires clear guidelines to prevent confusion
- Potential for inconsistent usage without documentation

**Impact**:
- Time: 0 weeks (just documentation)
- Risk: Low (no code changes)
- Benefit: Immediate clarity, flexibility

### Option 3: Migrate to Riverpod (New Pattern)
**Description**: Adopt Riverpod as a unified solution for all state management.

**Pros** ✅:
- Modern, compile-safe state management
- Combines simplicity of Provider with power of BLoC
- Growing community support
- Better testing story

**Cons** ❌:
- Complete rewrite of all state management (3-4 weeks)
- Very high risk
- Learning curve for entire team
- Disrupts ongoing development
- No immediate business value

**Impact**:
- Time: 3-4 weeks
- Risk: High (complete rewrite)
- Benefit: Modern architecture (but not critical)

---

## Decision Outcome

**Chosen Option**: **Option 2 - Keep Mixed Approach (Provider + BLoC)**

### Rationale

We choose to **maintain the mixed state management approach** with clear guidelines because:

1. **Pragmatic Engineering**: The current split is actually well-aligned with use cases:
   - Provider for **simple, UI-centric state** (theme, locale, onboarding)
   - BLoC for **complex business logic** (auth, gamification, venues, payments)

2. **Industry Precedent**: This pattern is used successfully in production Flutter applications, including Google's own apps

3. **Zero Risk**: No code changes means no risk to stable features

4. **Developer Productivity**: Provider's simplicity for UI state reduces boilerplate without sacrificing power where needed

5. **Time to Market**: No migration time means we can focus on delivering business value

### Implementation Guidelines

#### When to Use Provider
Use Provider (ChangeNotifier) for:
- ✅ Simple, app-wide state (theme, locale, preferences)
- ✅ UI-driven state changes (no complex async)
- ✅ State that doesn't require event sourcing
- ✅ State with minimal business logic
- ✅ Direct UI-to-state binding

**Examples**:
- Theme switching (dark/light mode)
- Language/locale selection
- Onboarding completion state
- UI preferences (grid vs list view)

#### When to Use BLoC
Use BLoC pattern for:
- ✅ Complex business logic
- ✅ Multiple async operations
- ✅ Event-driven workflows
- ✅ State requiring history/replay
- ✅ Features needing extensive testing
- ✅ Multi-step processes

**Examples**:
- Authentication flows
- Payment processing
- Gamification (points, badges, levels)
- Booking workflows
- Data fetching with multiple states

### Code Organization

**Provider implementations** (`lib/providers/`):
```
lib/
├── locale_provider.dart       # ✅ Provider: Simple locale state
├── theme_provider.dart        # ✅ Provider: Simple theme state
└── onboarding_provider.dart   # ✅ Provider: Simple completion flag
```

**BLoC implementations** (`lib/bloc/`):
```
lib/bloc/
├── auth/                      # ✅ BLoC: Complex auth flows
├── gamification/              # ✅ BLoC: Complex point calculation
├── profile/                   # ✅ BLoC: User data management
├── navigation/                # ✅ BLoC: Navigation state
├── venue/                     # ✅ BLoC: Search, filters, async data
├── booking/                   # ✅ BLoC: Multi-step workflow
└── payment/                   # ✅ BLoC: Payment processing
```

### Documentation Updates

1. ✅ Update README.md with state management section
2. ✅ Update architecture documentation
3. ✅ Create this ADR for future reference
4. ✅ Add guidelines to contributing docs
5. ✅ Remove "Legacy" comment from main.dart (it's intentional, not legacy)

---

## Consequences

### Positive Consequences ✅

1. **Clear Guidelines**: New developers know when to use each pattern
2. **Code Stability**: No migration risk to stable features
3. **Developer Productivity**: Simpler code for simple state
4. **Flexibility**: Right tool for the right job
5. **Immediate Clarity**: Decision documented and communicated
6. **Industry Alignment**: Following established Flutter patterns

### Negative Consequences ⚠️

1. **Learning Curve**: New developers must understand both patterns
   - **Mitigation**: Clear documentation and examples
   - **Mitigation**: Code review guidelines

2. **Potential Inconsistency**: Risk of using wrong pattern
   - **Mitigation**: Clear decision tree in docs
   - **Mitigation**: PR review checklist
   - **Mitigation**: Team training

3. **Two Testing Approaches**: Different test patterns for each
   - **Mitigation**: Test examples for both patterns
   - **Mitigation**: Shared testing utilities

### Risks and Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| Wrong pattern chosen for new feature | Medium | Low | Clear guidelines, code review |
| Confusion for new developers | Medium | Low | Documentation, onboarding guide |
| Inconsistent usage over time | Low | Low | Regular arch reviews, PR templates |

---

## Validation

### Success Criteria

This decision will be considered successful if:
- ✅ No mixed-pattern features (each feature uses one pattern consistently)
- ✅ New developers can choose the right pattern 90%+ of the time
- ✅ Code review feedback on state management decreases
- ✅ No state management-related bugs in production

### Review Schedule

- **Next Review**: January 2026 (3 months)
- **Trigger for Review**: If >3 instances of wrong pattern choice
- **Re-evaluation**: If team size doubles or Riverpod becomes industry standard

---

## References

### Internal Documents
- Code Analysis: `docs/SESSION_SUMMARY_2025-10-06.md`
- TODO: `docs/TODO.md` (Section: Mixed State Management Architecture)
- Main App Entry: `lib/main.dart` (lines 52-66)

### External References
- [Flutter State Management Options](https://docs.flutter.dev/data-and-backend/state-mgmt/options)
- [Provider Package](https://pub.dev/packages/provider)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Google I/O App Source](https://github.com/flutter/ioapp) - Uses mixed approach
- [Very Good Ventures Best Practices](https://verygood.ventures/blog/very-good-flutter-architecture) - Recommends BLoC for complex state

### Code Examples

**Good: Provider for Theme**
```dart
// Simple, UI-driven state - perfect for Provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
```

**Good: BLoC for Authentication**
```dart
// Complex async operations - perfect for BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    // ... complex event handling
  }

  Future<void> _onSignInRequested(event, emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

---

## Notes

- The "Legacy" comment in main.dart line 62 should be updated to "Simple state management with Provider"
- This ADR supersedes any previous informal decisions about state management
- Consider this pattern as the project standard going forward
- Feel free to challenge this decision if requirements change significantly

---

**ADR Status**: ✅ Accepted
**Last Updated**: October 6, 2025
**Next Review**: January 2026
**Supersedes**: None
**Superseded By**: None
