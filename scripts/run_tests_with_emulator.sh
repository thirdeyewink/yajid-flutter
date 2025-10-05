#!/bin/bash

# Firebase Emulator Test Runner
# This script starts the Firebase emulator and runs Flutter integration tests

set -e  # Exit on error

echo "🔥 Firebase Emulator Test Runner"
echo "================================"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if firebase.json exists
if [ ! -f "firebase.json" ]; then
    echo "❌ firebase.json not found. Make sure you're in the project root."
    exit 1
fi

echo "✅ Firebase CLI found ($(firebase --version))"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping Firebase Emulator..."
    pkill -f "firebase emulators" || true
    echo "✅ Cleanup complete"
}

# Set trap to cleanup on exit
trap cleanup EXIT INT TERM

# Start Firebase Emulator in background
echo "🚀 Starting Firebase Emulator..."
echo "   Auth: http://localhost:9099"
echo "   Firestore: http://localhost:8080"
echo "   Functions: http://localhost:5001"
echo "   Storage: http://localhost:9199"
echo "   UI: http://localhost:4000"
echo ""

# Start emulator in background with only required services
firebase emulators:start --only auth,firestore,functions,storage &

# Wait for emulators to be ready
echo "⏳ Waiting for emulators to start..."
sleep 5

# Check if emulators are running
if ! curl -s http://localhost:4000 > /dev/null 2>&1; then
    echo "⚠️  Emulator UI not accessible yet, waiting longer..."
    sleep 5
fi

echo "✅ Firebase Emulator is ready!"
echo ""

# Run Flutter tests
echo "🧪 Running Flutter integration tests..."
echo ""

if [ "$1" == "--integration" ]; then
    echo "Running integration tests only..."
    flutter test integration_test/
elif [ "$1" == "--all" ]; then
    echo "Running all tests..."
    flutter test --coverage
else
    echo "Running unit and widget tests..."
    flutter test test/ --coverage
fi

TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed (exit code: $TEST_EXIT_CODE)"
fi

echo ""
echo "📊 Test Summary:"
echo "   - Emulator UI: http://localhost:4000"
echo "   - Coverage report: coverage/lcov.info"
echo ""

exit $TEST_EXIT_CODE
