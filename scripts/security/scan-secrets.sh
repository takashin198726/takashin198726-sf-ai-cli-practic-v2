#!/bin/bash
set -e

echo "🔒 Running security scans..."

# git-secrets scan
echo "Running git-secrets scan..."
if command -v git-secrets &> /dev/null; then
    git secrets --scan || echo "⚠️  git-secrets found potential secrets!"
else
    echo "⚠️  git-secrets not installed. Skipping..."
fi

# gitleaks scan
echo "Running gitleaks scan..."
if command -v gitleaks &> /dev/null; then
    gitleaks detect --source . --verbose || echo "⚠️  gitleaks found potential secrets!"
else
    echo "⚠️  gitleaks not installed. Skipping..."
fi

echo "✅ Security scan completed"
