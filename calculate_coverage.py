#!/usr/bin/env python3
"""Calculate test coverage from lcov.info file."""

import sys
import re

def calculate_coverage(lcov_file):
    """Parse lcov.info and calculate coverage percentage."""
    total_lines = 0
    covered_lines = 0

    try:
        with open(lcov_file, 'r', encoding='utf-8') as f:
            for line in f:
                if line.startswith('LF:'):
                    # LF = Lines Found (total lines)
                    total_lines += int(line.split(':')[1].strip())
                elif line.startswith('LH:'):
                    # LH = Lines Hit (covered lines)
                    covered_lines += int(line.split(':')[1].strip())

    except FileNotFoundError:
        print(f"Error: Coverage file '{lcov_file}' not found")
        return None
    except Exception as e:
        print(f"Error parsing coverage file: {e}")
        return None

    if total_lines == 0:
        print("Warning: No lines found in coverage report")
        return 0.0

    coverage_percent = (covered_lines / total_lines) * 100

    print(f"Lines found: {total_lines}")
    print(f"Lines hit: {covered_lines}")
    print(f"Coverage: {coverage_percent:.1f}%")

    return coverage_percent

if __name__ == '__main__':
    lcov_file = sys.argv[1] if len(sys.argv) > 1 else 'coverage/lcov.info'
    coverage = calculate_coverage(lcov_file)

    if coverage is not None:
        target = 40.0
        if coverage >= target:
            print(f"\n✅ Coverage target achieved! ({coverage:.1f}% >= {target}%)")
            sys.exit(0)
        else:
            print(f"\n⚠️  Coverage below target ({coverage:.1f}% < {target}%)")
            print(f"   Need {target - coverage:.1f}% more coverage")
            sys.exit(1)
