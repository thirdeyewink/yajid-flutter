# Firebase Emulator Setup Guide

**Project:** Yajid Platform
**Purpose:** Run integration tests locally without affecting production data
**Date:** October 5, 2025

---

## 📋 Overview

The Firebase Emulator Suite allows you to run Firebase services locally for testing:
- **Firestore Database** - NoSQL data storage
- **Authentication** - User authentication
- **Cloud Functions** - Server-side logic
- **Cloud Storage** - File storage
- **Emulator UI** - Web interface to view and manage emulated data

---

## ✅ Prerequisites

1. **Firebase CLI** (already installed: v14.14.0)
   ```bash
   firebase --version
   ```

2. **Node.js** (v18+)
   ```bash
   node --version
   ```

3. **Java JDK** (v11+) - Required for Firestore emulator
   ```bash
   java --version
   ```

---

## 🚀 Quick Start

### 1. Install Emulators

First-time setup (downloads emulator binaries):

```bash
firebase init emulators
```

**Select the following emulators:**
- ✅ Authentication Emulator
- ✅ Firestore Emulator
- ✅ Functions Emulator
- ✅ Storage Emulator

**Ports (already configured in firebase.json):**
- Auth: 9099
- Firestore: 8080
- Functions: 5001
- Storage: 9199
- Emulator UI: 4000

### 2. Start the Emulator

**Option A: All Services**
```bash
firebase emulators:start
```

**Option B: Specific Services**
```bash
firebase emulators:start --only auth,firestore
```

**Option C: With Import/Export**
```bash
# Export data on shutdown
firebase emulators:start --export-on-exit=./emulator-data

# Import data on startup
firebase emulators:start --import=./emulator-data
```

### 3. Access the Emulator UI

Open in your browser:
```
http://localhost:4000
```

The UI provides:
- View Firestore documents
- View authenticated users
- Monitor Cloud Functions logs
- Browse Storage files
- Clear all data

---

## 🧪 Running Tests with Emulator

### Using the Automated Script

**Run unit and widget tests:**
```bash
bash scripts/run_tests_with_emulator.sh
```

**Run integration tests:**
```bash
bash scripts/run_tests_with_emulator.sh --integration
```

**Run all tests:**
```bash
bash scripts/run_tests_with_emulator.sh --all
```

### Manual Testing

**Terminal 1 - Start Emulator:**
```bash
firebase emulators:start
```

**Terminal 2 - Run Tests:**
```bash
flutter test --coverage
```

**Terminal 3 - Run Integration Tests:**
```bash
flutter test integration_test/
```

---

## 🔧 Configuration

### firebase.json (Already Configured)

```json
{
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8080
    },
    "functions": {
      "port": 5001
    },
    "storage": {
      "port": 9199
    },
    "ui": {
      "enabled": true,
      "port": 4000
    },
    "singleProjectMode": true
  }
}
```

### Test Configuration

Update test files to use emulator:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// In setUp():
await Firebase.initializeApp();

// Use emulator in tests
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```

---

## 📊 Current Test Status

### Tests That Need Emulator (56 failing)

These tests fail because they try to connect to real Firebase:

**Integration Tests:**
- Authentication flow tests
- Firestore CRUD operation tests
- Cloud Functions invocation tests
- Real-time listener tests

### Tests That DON'T Need Emulator (342 passing)

These tests use mocks or TestApp:
- Unit tests (service logic)
- Widget tests (UI components)
- BLoC tests (state management)
- Model tests (data structures)

---

## 🎯 Benefits of Using Emulator

### For Development
1. **No Cost** - Free local testing, no Firebase quota usage
2. **Faster** - No network latency
3. **Offline** - Works without internet
4. **Isolated** - No risk to production data
5. **Deterministic** - Consistent test environment

### For Testing
1. **Integration Tests** - Test real Firebase operations
2. **Security Rules** - Validate Firestore rules locally
3. **Cloud Functions** - Test functions before deployment
4. **Data Seeding** - Create test data quickly

### For CI/CD
1. **Automated Testing** - Run in GitHub Actions
2. **No Credentials** - No need for service account keys
3. **Parallel Tests** - Multiple emulator instances

---

## 🐛 Troubleshooting

### Emulator Won't Start

**Issue:** Port already in use
```
Error: Port 8080 is already in use
```

**Solution:**
```bash
# Find process using port
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Kill the process or change port in firebase.json
```

### Java Not Found

**Issue:** Firestore emulator needs Java
```
Error: java: command not found
```

**Solution:**
```bash
# Install Java 11+
# macOS
brew install openjdk@11

# Ubuntu
sudo apt install openjdk-11-jdk

# Windows
choco install openjdk11
```

### Tests Can't Connect

**Issue:** Tests try to connect to real Firebase instead of emulator

**Solution:** Ensure emulator configuration in tests:
```dart
// BEFORE Firebase.initializeApp()
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

### Data Not Persisting

**Issue:** Emulator data cleared on restart

**Solution:** Use export/import
```bash
firebase emulators:start --export-on-exit=./emulator-data
```

---

## 📚 Useful Commands

```bash
# Check emulator status
firebase emulators:exec --help

# Run emulator with specific import/export
firebase emulators:start --import=./seed-data --export-on-exit=./test-data

# Execute command with emulator
firebase emulators:exec "flutter test" --import=./test-data

# View emulator logs
firebase emulators:start --debug

# Clear all emulator data
# (Stop emulator, delete .firebase/ folder, restart)
```

---

## 🎓 Best Practices

### 1. Seed Test Data
Create `scripts/seed_emulator_data.dart` to populate test data:
```dart
void main() async {
  await Firebase.initializeApp();
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  // Create test users
  await FirebaseFirestore.instance.collection('users').add({
    'name': 'Test User',
    'email': 'test@example.com',
  });
}
```

### 2. Use Export for Baseline Data
```bash
# Create baseline data manually in UI
firebase emulators:start

# Export baseline
firebase emulators:export ./baseline-data

# Always start with baseline
firebase emulators:start --import=./baseline-data
```

### 3. CI/CD Integration

**GitHub Actions (.github/workflows/flutter-ci.yml):**
```yaml
- name: Start Firebase Emulator
  run: firebase emulators:start --only auth,firestore &

- name: Wait for Emulator
  run: sleep 5

- name: Run Integration Tests
  run: flutter test integration_test/
```

### 4. Test Isolation
```dart
setUp(() async {
  // Clear data before each test
  await FirebaseFirestore.instance.clearPersistence();
});
```

---

## 🔗 Resources

- [Firebase Emulator Docs](https://firebase.google.com/docs/emulator-suite)
- [Emulator Security Rules](https://firebase.google.com/docs/rules/emulator-setup)
- [Testing Cloud Functions](https://firebase.google.com/docs/functions/local-emulator)
- [Flutter Firebase Testing](https://firebase.flutter.dev/docs/testing/)

---

## ✅ Next Steps

1. **Install Emulators** (if not done):
   ```bash
   firebase init emulators
   ```

2. **Update Integration Tests**:
   - Add emulator configuration
   - Update test/integration/ files

3. **Run Tests**:
   ```bash
   bash scripts/run_tests_with_emulator.sh
   ```

4. **Fix Failing Tests**:
   - Update tests to use emulator
   - Verify 56 failing tests now pass

5. **Add to CI/CD**:
   - Update flutter-ci.yml
   - Enable emulator in GitHub Actions

---

**Status:** Configuration complete, emulator ready to use
**Last Updated:** October 5, 2025
