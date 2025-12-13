#!/bin/bash
set -e

BASE_BRANCH=${1:-main}

echo "🔍 Detecting changed Apex classes since $BASE_BRANCH..."

# Get changed Apex class files
CHANGED_FILES=$(git diff --name-only origin/$BASE_BRANCH...HEAD | grep "\.cls$" || echo "")

if [ -z "$CHANGED_FILES" ]; then
  echo "ℹ️  No Apex classes changed."
  echo "📋 Running all tests as fallback..."
  
  sf apex run test \
    --test-level RunLocalTests \
    --code-coverage \
    --result-format human \
    --wait 20
  exit 0
fi

echo "📝 Changed Apex files:"
echo "$CHANGED_FILES" | while read file; do echo "  - $file"; done
echo ""

# Extract class names from file paths
CLASS_NAMES=$(echo "$CHANGED_FILES" | sed 's/.*\///' | sed 's/\.cls$//')

# Filter test classes (ending with Test)
TEST_CLASSES=$(echo "$CLASS_NAMES" | grep "Test$" || echo "")

# Filter non-test classes
NON_TEST_CLASSES=$(echo "$CLASS_NAMES" | grep -v "Test$" || echo "")

echo "🧪 Test classes detected:"
if [ -z "$TEST_CLASSES" ]; then
  echo "  None"
else
  echo "$TEST_CLASSES" | while read class; do echo "  - $class"; done
fi
echo ""

echo "📦 Non-test classes detected:"
if [ -z "$NON_TEST_CLASSES" ]; then
  echo "  None"
else
  echo "$NON_TEST_CLASSES" | while read class; do echo "  - $class"; done
fi
echo ""

# Determine which tests to run
if [ -z "$TEST_CLASSES" ]; then
  echo "⚠️  No test classes in changes. Running all tests for safety."
  
  sf apex run test \
    --test-level RunLocalTests \
    --code-coverage \
    --result-format human \
    --wait 20
else
  # Convert newlines to commas for --class-names
  TEST_CLASS_LIST=$(echo "$TEST_CLASSES" | tr '\n' ',' | sed 's/,$//')
  
  echo "🎯 Running selective tests: $TEST_CLASS_LIST"
  echo ""
  
  START_TIME=$(date +%s)
  
  sf apex run test \
    --class-names "$TEST_CLASS_LIST" \
    --code-coverage \
    --result-format human \
    --wait 20
  
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  MINUTES=$((DURATION / 60))
  SECONDS=$((DURATION % 60))
  
  echo ""
  echo "✅ Selective tests completed in ${MINUTES}m ${SECONDS}s"
  echo "💡 Saved time by running only affected tests"
fi
