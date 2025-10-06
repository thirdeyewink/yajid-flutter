# ADR-002: BLoC Wiring Strategy (App-Level vs Screen-Level)

**Status:** Accepted
**Date:** October 6, 2025
**Deciders:** Technical Team
**Technical Story:** [Identified during Oct 6, 2025 code analysis](#context)
**Related ADRs**: [ADR-001: Mixed State Management](./ADR-001-mixed-state-management.md)

---

## Context and Problem Statement

The Yajid application has 7 BLoC implementations:
- **2 BLoCs** wired at app level (AuthBloc, ProfileBloc)
- **5 BLoCs** created but NOT wired at app level (GamificationBloc, NavigationBloc, VenueBloc, BookingBloc, PaymentBloc)

During code analysis, this raised a question: Is this intentional architecture or incomplete implementation?

**Key Question**: Which BLoCs should be provided at app level vs screen level, and why?

---

## Decision Drivers

### Architectural Factors
- **State Scope**: Is the state needed across multiple screens or just one feature?
- **Lifecycle Management**: Should the BLoC persist across navigation or be created/disposed per screen?
- **Memory Management**: App-level BLoCs stay in memory throughout app lifetime
- **Initialization Cost**: Some BLoCs have expensive initialization
- **Testing Complexity**: App-level BLoCs affect all widget tests

### Current Analysis

#### App-Level BLoCs (in main.dart)

**AuthBloc** ✅:
```dart
BlocProvider<AuthBloc>(
  create: (context) => AuthBloc()..add(const AuthStarted()),
)
```

**Justification**:
- ✅ Needed across entire app (auth state checked everywhere)
- ✅ Single source of truth for authentication
- ✅ Must persist across all navigation
- ✅ Initial event triggers app startup logic

**ProfileBloc** ✅:
```dart
BlocProvider<ProfileBloc>(
  create: (context) => ProfileBloc(),
)
```

**Justification**:
- ✅ User profile accessed from multiple screens
- ✅ Profile data should persist across navigation
- ✅ Single source of truth for user data

#### Screen-Level BLoCs (NOT in main.dart)

**GamificationBloc**:
- **Current**: Not wired at app level
- **Used In**: GamificationScreen, LeaderboardScreen, BadgeShowcaseScreen
- **State**: Points, badges, levels, leaderboard
- **Accessed From**: Gamification screens + points widget in app bar

**NavigationBloc**:
- **Current**: Not wired at app level
- **Used In**: MainNavigationScreen
- **State**: Current bottom nav tab index
- **Accessed From**: Only main navigation screen

**VenueBloc**:
- **Current**: Not wired at app level
- **Used In**: VenueSearchScreen, VenueDetailScreen
- **State**: Venue search results, filters, selected venue
- **Accessed From**: Venue-related screens only

**BookingBloc**:
- **Current**: Not wired at app level
- **Used In**: Booking flow screens (when implemented)
- **State**: Booking workflow state, selected slots
- **Accessed From**: Booking flow only

**PaymentBloc**:
- **Current**: Not wired at app level
- **Used In**: Payment screens (when implemented)
- **State**: Payment transaction state
- **Accessed From**: Payment flow only

---

## Considered Options

### Option 1: Wire All BLoCs at App Level
**Description**: Provide all 7 BLoCs at app root in main.dart.

**Pros** ✅:
- Single place to see all BLoCs
- All state available everywhere
- No need to think about wiring per screen

**Cons** ❌:
- All BLoCs loaded at app start (memory overhead)
- Feature BLoCs stay in memory even when not used
- Unnecessary coupling between features
- Harder to test screens in isolation
- Payment/Booking BLoCs initialized even if user never books

**Impact**:
- Memory: +5-10MB constant overhead
- Startup time: +500ms
- Complexity: Lower (but worse architecture)

### Option 2: Wire Only Shared BLoCs at App Level ✅ SELECTED
**Description**: Provide BLoCs at app level ONLY if they're truly app-wide. Feature-specific BLoCs provided at screen/feature level.

**App-Level BLoCs**:
- ✅ AuthBloc (needed everywhere)
- ✅ ProfileBloc (needed in many screens)
- ✅ GamificationBloc (points widget in app bar, multiple screens)

**Screen-Level BLoCs**:
- ✅ NavigationBloc (only in MainNavigationScreen)
- ✅ VenueBloc (only in venue screens)
- ✅ BookingBloc (only in booking flow)
- ✅ PaymentBloc (only in payment flow)

**Pros** ✅:
- **Memory Efficient**: Feature BLoCs created only when needed
- **Better Separation**: Features are independent
- **Easier Testing**: Screen tests don't need all app BLoCs
- **Lazy Loading**: Payment/Booking logic loaded on-demand
- **Clear Boundaries**: App-level = shared, Screen-level = feature-specific

**Cons** ❌:
- Need to wire BLoCs at screen level (slight boilerplate)
- Developers must understand the distinction

**Impact**:
- Memory: Optimal (only load what's needed)
- Startup time: Faster (less initialization)
- Complexity: Medium (but better architecture)

### Option 3: Use GetIt Dependency Injection
**Description**: Use a DI container to provide BLoCs instead of BlocProvider.

**Pros** ✅:
- Flexible scoping
- Easy to swap implementations
- Industry standard pattern

**Cons** ❌:
- Additional dependency
- Different pattern from BLoC library recommendations
- Team learning curve
- More setup complexity

**Impact**:
- Time: 1 week migration
- Risk: Medium
- Benefit: Marginal improvement

---

## Decision Outcome

**Chosen Option**: **Option 2 - Wire Only Shared BLoCs at App Level**

### Rationale

We choose to provide BLoCs at app level ONLY when they are truly app-wide, because:

1. **Memory Efficiency**: Feature BLoCs shouldn't stay in memory if the feature isn't being used

2. **Clear Architecture**: Explicit distinction between app-wide and feature-specific state

3. **Better Testing**: Screen tests can provide mock BLoCs without affecting all app tests

4. **Performance**: Lazy loading of feature logic improves startup time

5. **Maintainability**: Clear boundaries make it obvious which state is shared

### Implementation Strategy

#### App-Level BLoCs (Provided in main.dart)

Criteria for app-level provision:
- ✅ Used in 3+ different feature areas
- ✅ State must persist across all navigation
- ✅ Requires initialization at app startup
- ✅ Single source of truth for critical app state

**Current App-Level BLoCs**:
1. **AuthBloc** ✅ - Authentication state (entire app)
2. **ProfileBloc** ✅ - User profile data (many screens)

**Should Be Added to App-Level**:
3. **GamificationBloc** ⚠️ - Points widget in app bar + multiple screens

```dart
// In lib/main.dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc()..add(const AuthStarted()),
    ),
    BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc(),
    ),
    // Add: GamificationBloc for app bar points widget
    BlocProvider<GamificationBloc>(
      create: (context) => GamificationBloc(),
      lazy: false, // Load at startup for app bar
    ),
    // ... Provider implementations ...
  ],
  child: ...,
)
```

#### Screen-Level BLoCs (Provided at Screen/Feature Level)

Criteria for screen-level provision:
- ✅ Used only within a single feature/flow
- ✅ State is temporary (can be disposed when leaving feature)
- ✅ Heavy initialization (should be lazy-loaded)
- ✅ Feature isolation desired

**Screen-Level BLoCs**:

**1. NavigationBloc** - Main navigation only
```dart
// In lib/screens/main_navigation_screen.dart
class MainNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: _MainNavigationView(),
    );
  }
}
```

**2. VenueBloc** - Venue feature screens
```dart
// In lib/screens/venue_search_screen.dart
class VenueSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VenueBloc()..add(LoadVenues()),
      child: _VenueSearchView(),
    );
  }
}
```

**3. BookingBloc** - Booking flow
```dart
// In lib/screens/booking_flow_screen.dart
class BookingFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc(),
      child: _BookingFlowView(),
    );
  }
}
```

**4. PaymentBloc** - Payment flow
```dart
// In lib/screens/payment_screen.dart
class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(),
      child: _PaymentView(),
    );
  }
}
```

### Decision Tree

Use this flowchart to decide BLoC wiring level:

```
Is the BLoC used in 3+ different features?
├─ YES → Is it needed at app startup?
│         ├─ YES → App-level (lazy: false)
│         └─ NO  → App-level (lazy: true)
└─ NO  → Is it accessed from app bar or global widget?
          ├─ YES → App-level
          └─ NO  → Screen-level
```

**Examples**:
- ✅ AuthBloc: Used everywhere, needed at startup → **App-level (lazy: false)**
- ✅ ProfileBloc: Used in 5+ screens, not startup-critical → **App-level (lazy: true)**
- ✅ GamificationBloc: In app bar + multiple screens → **App-level (lazy: false)**
- ✅ VenueBloc: Only venue screens → **Screen-level**
- ✅ PaymentBloc: Only payment flow → **Screen-level**

---

## Consequences

### Positive Consequences ✅

1. **Optimal Memory Usage**: Feature BLoCs loaded only when needed
2. **Faster App Startup**: Less initialization at launch
3. **Better Testing**: Screen tests isolated from app state
4. **Clear Architecture**: Obvious which state is shared vs feature-specific
5. **Feature Independence**: Payment/Booking can be developed/tested independently

### Negative Consequences ⚠️

1. **More Wiring Code**: Need to provide BLoC at screen level
   - **Mitigation**: Create screen BLoC templates
   - **Mitigation**: Document pattern in contributing guide

2. **Developer Decision Required**: Must choose app vs screen level
   - **Mitigation**: Clear decision tree (see above)
   - **Mitigation**: Code review guidelines

### Required Code Changes

#### 1. Add GamificationBloc to App Level
```dart
// lib/main.dart
BlocProvider<GamificationBloc>(
  create: (context) => GamificationBloc(),
  lazy: false,
),
```

**Reason**: Points widget is in app bar (global)

#### 2. Update Main.dart Comment
```dart
// BEFORE
// Legacy Provider support for migration
ChangeNotifierProvider(create: (context) => LocaleProvider()),

// AFTER
// Simple state management with Provider (see ADR-001)
ChangeNotifierProvider(create: (context) => LocaleProvider()),
```

**Reason**: "Legacy" implies it will be removed, but it's intentional

---

## Validation

### Success Criteria

This decision will be considered successful if:
- ✅ App startup time <2 seconds (currently ~1.5s)
- ✅ Memory usage stays under 150MB for idle app
- ✅ Venue/Booking/Payment screens load in <500ms
- ✅ No BLoC-related bugs from incorrect wiring

### Metrics to Monitor

| Metric | Target | Current | Tool |
|--------|--------|---------|------|
| App startup time | <2s | ~1.5s | Flutter DevTools |
| Idle memory usage | <150MB | ~120MB | Flutter DevTools |
| Screen load time | <500ms | TBD | Performance monitoring |
| BLoC initialization time | <100ms | TBD | Custom logging |

### Review Schedule

- **Next Review**: January 2026 (3 months)
- **Trigger for Review**: If memory usage exceeds 200MB or startup time >3s
- **Re-evaluation**: If adding 10+ new BLoCs

---

## References

### Internal Documents
- [ADR-001: Mixed State Management](./ADR-001-mixed-state-management.md)
- Code Analysis: `docs/SESSION_SUMMARY_2025-10-06.md`
- Main App Entry: `lib/main.dart`

### External References
- [BLoC Library Best Practices](https://bloclibrary.dev/#/architecture)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Lazy vs Eager BLoC Providers](https://bloclibrary.dev/#/flutterbloccoreconcepts?id=blocprovider)

### Code Examples

**Good: App-Level BLoC (Shared State)**
```dart
// Provided at app level because used everywhere
BlocProvider<AuthBloc>(
  create: (context) => AuthBloc()..add(const AuthStarted()),
  lazy: false, // Needed at startup
)
```

**Good: Screen-Level BLoC (Feature State)**
```dart
// Provided at screen level because feature-specific
class VenueSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VenueBloc()..add(LoadVenues()),
      child: VenueSearchView(),
    );
  }
}
```

**Good: Lazy App-Level BLoC (Shared But Not Startup-Critical)**
```dart
// Provided at app level but loaded lazily
BlocProvider<ProfileBloc>(
  create: (context) => ProfileBloc(),
  lazy: true, // Will be created on first access
)
```

---

## Implementation Checklist

- [ ] Add GamificationBloc to main.dart (app-level)
- [ ] Update "Legacy" comment in main.dart
- [ ] Document BLoC wiring pattern in CONTRIBUTING.md
- [ ] Create screen BLoC template in docs/templates/
- [ ] Update README.md with architecture diagram
- [ ] Add BLoC wiring checklist to PR template

---

## Notes

- GamificationBloc should be added to app level because the points widget appears in the app bar
- NavigationBloc stays screen-level because it's only used in MainNavigationScreen
- This ADR complements ADR-001 (which covers Provider vs BLoC choice)
- Consider adding architecture diagrams showing BLoC hierarchy

---

**ADR Status**: ✅ Accepted
**Last Updated**: October 6, 2025
**Next Review**: January 2026
**Supersedes**: None
**Superseded By**: None
**Related ADRs**: [ADR-001](./ADR-001-mixed-state-management.md)
