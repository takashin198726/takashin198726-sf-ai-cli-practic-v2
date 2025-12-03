#!/bin/bash
set -e

echo "🚀 Setting up local development environment..."

# Check prerequisites
echo "Checking prerequisites..."
command -v node >/dev/null 2>&1 || { echo "❌ Node.js is required but not installed."; exit 1; }
command -v sf >/dev/null 2>&1 || { echo "❌ Salesforce CLI is required but not installed."; exit 1; }

# Install npm dependencies
echo "Installing npm dependencies..."
npm install

# Check for .env.local
if [ ! -f .env.local ]; then
    echo "⚠️  .env.local not found. Creating from .env.example..."
    cp .env.example .env.local
    echo "📝 Please edit .env.local with your credentials!"
fi

# Setup git-secrets
echo "Setting up git-secrets..."
if command -v git-secrets &> /dev/null; then
    git secrets --install || echo "git-secrets already installed"
    git secrets --register-aws || echo "AWS patterns already registered"
else
    echo "⚠️  git-secrets not found. Please install it manually."
fi

echo "✅ Local development environment setup completed!"
echo ""
echo "Next steps:"
echo "1. Edit .env.local with your credentials"
echo "2. Generate JWT certificates: cd certificates && bash ../scripts/security/generate-jwt-cert.sh"
echo "3. Authenticate with Salesforce: npm run sf:auth"
