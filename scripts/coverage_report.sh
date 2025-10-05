#!/bin/bash

# Coverage Report Generator for Yajid Project
# Generates test coverage and creates a formatted report

set -e

echo "🧪 Running Flutter tests with coverage..."
flutter test --coverage

if [ ! -f "coverage/lcov.info" ]; then
    echo "❌ Coverage file not generated"
    exit 1
fi

echo ""
echo "📊 Generating coverage report..."

# Calculate coverage using Python (works on all platforms)
COVERAGE=$(python3 -c "
import re
with open('coverage/lcov.info', 'r') as f:
    content = f.read()
    lf_matches = re.findall(r'^LF:(\d+)', content, re.MULTILINE)
    lh_matches = re.findall(r'^LH:(\d+)', content, re.MULTILINE)
    total_lines = sum(int(x) for x in lf_matches)
    hit_lines = sum(int(x) for x in lh_matches)
    percentage = (hit_lines / total_lines * 100) if total_lines > 0 else 0
    print(f'{hit_lines}/{total_lines} ({percentage:.2f}%)')
")

echo ""
echo "================================================"
echo "           YAJID COVERAGE REPORT"
echo "================================================"
echo "Lines covered: $COVERAGE"
echo "Report location: coverage/lcov.info"
echo "================================================"
echo ""

# Generate HTML report if genhtml is available
if command -v genhtml &> /dev/null; then
    echo "📄 Generating HTML report..."
    genhtml coverage/lcov.info -o coverage/html --quiet
    echo "✅ HTML report generated at coverage/html/index.html"

    # Try to open in browser (works on macOS and Linux)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open coverage/html/index.html
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open coverage/html/index.html 2>/dev/null || echo "Open coverage/html/index.html in your browser"
    fi
else
    echo "💡 Install lcov to generate HTML reports:"
    echo "   macOS: brew install lcov"
    echo "   Ubuntu: sudo apt-get install lcov"
fi

echo ""
echo "✅ Coverage report complete!"
