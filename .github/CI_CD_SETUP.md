# CI/CD Setup Guide for Yajid

This document explains the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the Yajid Flutter project.

## 📋 Overview

The project uses **GitHub Actions** for automated testing, building, and quality checks on every push and pull request.

## 🚀 Workflows

### 1. Flutter CI (`.github/workflows/flutter_ci.yml`)

**Triggers:** Push to `main` or `develop`, Pull Requests

**Jobs:**
- **Test**: Runs on Ubuntu
  - ✅ Code formatting verification (`dart format`)
  - ✅ Static analysis (`flutter analyze`)
  - ✅ Unit & widget tests with coverage
  - ✅ Coverage upload to Codecov

- **Build Android**: Builds release APK
  - ✅ Sets up Java 17
  - ✅ Builds APK
  - ✅ Uploads artifact (retained 7 days)

- **Build Web**: Builds web version
  - ✅ Builds web release
  - ✅ Uploads artifact (retained 7 days)

- **Code Quality**: Additional quality checks
  - ✅ Detailed analysis output
  - ✅ TODO comment scanning
  - ✅ Large file detection
  - ✅ Dependency audit

### 2. Coverage Badge (`.github/workflows/coverage_badge.yml`)

**Triggers:** Push to `main`

**Purpose:** Generates and updates coverage badge

**Requirements:**
- `GIST_SECRET`: GitHub Personal Access Token with gist scope
- `GIST_ID`: ID of gist to store badge data

## 🔧 Setup Instructions

### Step 1: Enable GitHub Actions

1. Push your code to GitHub
2. Go to **Settings** → **Actions** → **General**
3. Ensure "Allow all actions and reusable workflows" is selected

### Step 2: Configure Secrets (Optional for Coverage Badge)

If you want dynamic coverage badges:

1. Create a [GitHub Personal Access Token](https://github.com/settings/tokens) with `gist` scope
2. Create a new [Gist](https://gist.github.com/) (can be secret)
3. Go to repository **Settings** → **Secrets and variables** → **Actions**
4. Add these secrets:
   - `GIST_SECRET`: Your personal access token
   - `GIST_ID`: The ID from your gist URL (e.g., `abc123...`)

### Step 3: Configure Codecov (Optional)

For Codecov integration:

1. Sign up at [codecov.io](https://codecov.io/)
2. Connect your repository
3. Get your Codecov token
4. Add `CODECOV_TOKEN` to repository secrets

### Step 4: Update README Badges

Add badges to your README.md (see `.github/BADGES.md` for templates):

```markdown
![CI Status](https://github.com/YOUR_USERNAME/yajid/workflows/Flutter%20CI/badge.svg)
![Coverage](https://img.shields.io/badge/coverage-15.94%25-orange)
![Tests](https://img.shields.io/badge/tests-160%20passing-success)
```

## 📊 Coverage Reporting

### Local Coverage Report

Run the coverage script:

```bash
./scripts/coverage_report.sh
```

Or manually:

```bash
flutter test --coverage
python3 -c "
import re
with open('coverage/lcov.info', 'r') as f:
    content = f.read()
    lf_matches = re.findall(r'^LF:(\d+)', content, re.MULTILINE)
    lh_matches = re.findall(r'^LH:(\d+)', content, re.MULTILINE)
    total_lines = sum(int(x) for x in lf_matches)
    hit_lines = sum(int(x) for x in lh_matches)
    percentage = (hit_lines / total_lines * 100) if total_lines > 0 else 0
    print(f'Coverage: {hit_lines}/{total_lines} ({percentage:.2f}%)')
"
```

### HTML Coverage Report

If you have `lcov` installed:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
# or
xdg-open coverage/html/index.html  # Linux
```

Install lcov:
- **macOS**: `brew install lcov`
- **Ubuntu**: `sudo apt-get install lcov`
- **Windows**: Use WSL or Git Bash with lcov from Chocolatey

## 🎯 Current Status

**Coverage:** 15.94% (1,038/6,513 lines)
**Tests:** 160 passing / 40 failing (200 total)
**Target:** 80% coverage

### Test Breakdown
- ✅ RecommendationService: 28 tests
- ✅ GamificationService: 28 tests
- ✅ MessagingService: 22 tests
- ✅ PointsDisplayWidget: 17 tests
- ✅ SharedBottomNav: 23 tests
- ❌ Auth BLoC: Tests failing (Firebase dependencies)
- ❌ Complex widgets: Tests failing (Firebase dependencies)

## 🔍 Troubleshooting

### Tests Failing Locally

```bash
# Clean and reinstall dependencies
flutter clean
flutter pub get

# Run tests
flutter test
```

### Build Failing in CI

1. Check Flutter version matches (3.24.0)
2. Ensure all dependencies are in pubspec.yaml
3. Check for platform-specific code issues
4. Review workflow logs on GitHub Actions tab

### Coverage Not Generated

```bash
# Ensure coverage directory exists
mkdir -p coverage

# Run with verbose output
flutter test --coverage --reporter=expanded
```

## 📈 Improving Coverage

Priority areas to add tests:
1. Fix 40 failing Auth BLoC tests
2. Add widget tests for Badge/Leaderboard screens
3. Add integration tests for user flows
4. Add tests for UserProfileService
5. Add tests for RecommendationService (remaining methods)

Target milestones:
- **Week 2**: 40% coverage
- **Week 3**: 60% coverage
- **Week 4**: 80% coverage

## 🔐 Security Considerations

- Never commit secrets or API keys
- Use GitHub Secrets for sensitive data
- Review third-party actions before use
- Keep dependencies updated
- Enable Dependabot alerts

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Codecov Documentation](https://docs.codecov.com/)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)

## 🤝 Contributing

When submitting PRs:
1. Ensure all tests pass locally
2. Add tests for new features
3. Update documentation if needed
4. Follow existing code style
5. CI must pass before merge

---

**Last Updated:** October 3, 2025
**Maintained by:** Yajid Development Team
