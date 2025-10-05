# CI/CD Badges for README

Add these badges to your README.md after the existing Flutter/Firebase/Dart badges:

```markdown
![CI Status](https://github.com/YOUR_USERNAME/yajid/workflows/Flutter%20CI/badge.svg)
![Coverage](https://img.shields.io/badge/coverage-15.94%25-orange)
![Tests](https://img.shields.io/badge/tests-160%20passing-success)
![Code Quality](https://img.shields.io/badge/flutter%20analyze-0%20issues-success)
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## Optional: Dynamic Coverage Badge

For a dynamic coverage badge using Codecov:

```markdown
![Coverage](https://codecov.io/gh/YOUR_USERNAME/yajid/branch/main/graph/badge.svg)
```

## Optional: Shields.io Badges

For more customization using shields.io:

```markdown
![Flutter Version](https://img.shields.io/badge/flutter-3.24.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web-lightgrey)
```

## Status Badge Colors

- **Coverage**:
  - 🟢 Green (80%+): success
  - 🟡 Orange (60-79%): orange
  - 🔴 Red (<60%): red

- **Tests**:
  - 🟢 Green (>90% passing): success
  - 🟡 Yellow (70-90%): yellow
  - 🔴 Red (<70%): red
