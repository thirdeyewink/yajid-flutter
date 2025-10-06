# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records (ADRs) for the Yajid project. ADRs document important architectural decisions, their context, and their consequences.

## What are ADRs?

Architecture Decision Records are short text documents that capture important architectural decisions made during project development. Each ADR describes:

- **Context**: The problem or situation requiring a decision
- **Decision**: The choice made and why
- **Consequences**: The results of the decision (both positive and negative)

## Format

Each ADR follows this structure:

```markdown
# ADR-XXX: Title

**Status:** [Proposed | Accepted | Deprecated | Superseded]
**Date:** YYYY-MM-DD
**Deciders:** Team/Person
**Technical Story:** Link or description

## Context and Problem Statement
[Description of the problem]

## Decision Drivers
[Factors influencing the decision]

## Considered Options
[List of alternatives considered]

## Decision Outcome
[Chosen option and rationale]

## Consequences
[Positive and negative outcomes]
```

## Current ADRs

| ADR | Title | Status | Date | Summary |
|-----|-------|--------|------|---------|
| [001](./ADR-001-mixed-state-management.md) | Mixed State Management (Provider + BLoC) | ✅ Accepted | 2025-10-06 | Maintain hybrid Provider/BLoC approach with clear guidelines |
| [002](./ADR-002-bloc-wiring-strategy.md) | BLoC Wiring Strategy | ✅ Accepted | 2025-10-06 | Provide BLoCs at app level only if truly shared |

## How to Use

### When to Create an ADR

Create an ADR when you make a decision that:
- Affects the overall architecture
- Is expensive or difficult to reverse
- Establishes a pattern others will follow
- Resolves a significant debate
- Has long-term consequences

### Creating a New ADR

1. Copy the template from an existing ADR
2. Use the next number in sequence (ADR-003, ADR-004, etc.)
3. Fill in all sections completely
4. Discuss with the team
5. Update this README with the new ADR
6. Commit and create PR for review

### Decision Lifecycle

```
Proposed → Accepted → [Later] Deprecated/Superseded
     ↓          ↓
  Rejected   Implemented
```

- **Proposed**: Under discussion
- **Accepted**: Decision is final
- **Rejected**: Considered but not chosen
- **Deprecated**: Still in use but plan to remove
- **Superseded**: Replaced by a newer ADR

## Quick Reference Guide

### ADR-001: Mixed State Management ✅

**Problem**: Should we use Provider or BLoC for state management?

**Decision**: Use both - Provider for simple UI state, BLoC for complex business logic

**When to use Provider**:
- ✅ Simple app-wide state (theme, locale)
- ✅ No complex async operations
- ✅ UI-driven changes

**When to use BLoC**:
- ✅ Complex business logic
- ✅ Multiple async operations
- ✅ Event-driven workflows

**Related Files**:
- `lib/main.dart` (lines 52-66)
- `lib/locale_provider.dart`
- `lib/theme_provider.dart`
- `lib/bloc/auth/auth_bloc.dart`
- `lib/bloc/gamification/gamification_bloc.dart`

### ADR-002: BLoC Wiring Strategy ✅

**Problem**: Which BLoCs should be provided at app level vs screen level?

**Decision**: Provide at app level only if used in 3+ features or in global widgets (app bar)

**App-Level BLoCs**:
- ✅ AuthBloc (used everywhere)
- ✅ ProfileBloc (used in many screens)
- ✅ GamificationBloc (in app bar + multiple screens) *needs to be added*

**Screen-Level BLoCs**:
- ✅ NavigationBloc (only MainNavigationScreen)
- ✅ VenueBloc (only venue screens)
- ✅ BookingBloc (only booking flow)
- ✅ PaymentBloc (only payment flow)

**Decision Tree**:
```
Used in 3+ features?
├─ YES → Needed at startup?
│         ├─ YES → App-level (lazy: false)
│         └─ NO  → App-level (lazy: true)
└─ NO  → In app bar/global widget?
          ├─ YES → App-level
          └─ NO  → Screen-level
```

**Related Files**:
- `lib/main.dart`
- `lib/screens/main_navigation_screen.dart`
- `lib/screens/venue_search_screen.dart`

## Best Practices

### Writing Good ADRs

1. **Be Specific**: Provide concrete examples and code snippets
2. **Be Honest**: Document negative consequences too
3. **Be Timely**: Write ADRs when making the decision, not months later
4. **Be Brief**: 1-3 pages maximum
5. **Be Actionable**: Include implementation checklist if applicable

### ADR Anti-Patterns

❌ **Don't**:
- Write ADRs for trivial decisions
- Make ADRs too long (>5 pages)
- Skip the "Consequences" section
- Leave status as "Proposed" indefinitely
- Write ADRs after implementation is done

✅ **Do**:
- Focus on "why" not "how"
- Include alternatives considered
- Update ADRs when superseded
- Link related ADRs
- Review ADRs during code review

## Reviewing ADRs

### ADR Review Checklist

When reviewing an ADR PR:

- [ ] Problem statement is clear
- [ ] At least 2 alternatives were considered
- [ ] Decision is well-justified
- [ ] Consequences (positive AND negative) are documented
- [ ] Implementation path is clear
- [ ] README is updated with new ADR
- [ ] Related ADRs are linked
- [ ] Code examples are provided (if applicable)
- [ ] Review schedule is set

### Review Schedule

All ADRs should be reviewed:
- **Initial**: During PR review
- **Periodic**: 3-6 months after acceptance
- **Triggered**: If problems arise from the decision
- **Annual**: Yearly architecture review

## Contributing

### For New Developers

When joining the project:
1. **Read all ADRs** to understand architectural decisions
2. **Follow the patterns** established in ADRs
3. **Ask questions** if something is unclear
4. **Propose new ADRs** if you see a gap

### For Maintainers

When maintaining the project:
1. **Reference ADRs** in code reviews
2. **Update ADRs** when patterns evolve
3. **Create ADRs** for new patterns
4. **Deprecate ADRs** when superseded

## Resources

### External Links

- [ADR GitHub Organization](https://adr.github.io/)
- [Joel Parker Henderson's ADR templates](https://github.com/joelparkerhenderson/architecture-decision-record)
- [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [Michael Nygard's original ADR article](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)

### Internal Links

- [CLAUDE.md](../../../CLAUDE.md) - Project overview
- [TODO.md](../../TODO.md) - Current tasks and improvements
- [SESSION_SUMMARY_2025-10-06.md](../../SESSION_SUMMARY_2025-10-06.md) - Latest analysis

## Template

```markdown
# ADR-XXX: [Title]

**Status:** Proposed
**Date:** YYYY-MM-DD
**Deciders:** [Name/Team]
**Technical Story:** [Link or description]

---

## Context and Problem Statement

[Describe the problem or situation]

---

## Decision Drivers

- [Factor 1]
- [Factor 2]
- [Factor 3]

---

## Considered Options

### Option 1: [Name]
**Pros** ✅:
- [Pro 1]

**Cons** ❌:
- [Con 1]

### Option 2: [Name] ✅ SELECTED
**Pros** ✅:
- [Pro 1]

**Cons** ❌:
- [Con 1]

---

## Decision Outcome

**Chosen Option**: Option 2

### Rationale
[Why this option was chosen]

---

## Consequences

### Positive ✅
- [Positive 1]

### Negative ⚠️
- [Negative 1]
- **Mitigation**: [How to address]

---

## Validation

- **Success Criteria**: [How to measure success]
- **Review Schedule**: [When to review]

---

## References

- [Link 1]
- [Code example](../../../lib/example.dart)

---

**ADR Status**: ✅ Accepted
**Last Updated**: YYYY-MM-DD
**Next Review**: YYYY-MM-DD
```

---

**Last Updated**: October 6, 2025
**Total ADRs**: 2
**Status**: All Accepted ✅
