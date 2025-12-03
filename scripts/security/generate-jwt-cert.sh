#!/bin/bash
set -e

echo "🔐 Generating JWT certificate and key..."

# Check if we're in the certificates directory
if [ ! -f "README.md" ]; then
    echo "❌ Please run this script from the certificates/ directory"
    exit 1
fi

# Generate private key
echo "Generating private key (server.key)..."
openssl genrsa -out server.key 2048

# Generate certificate (valid for 1 year)
echo "Generating certificate (server.crt)..."
openssl req -new -x509 -nodes -sha256 -days 365 \
  -key server.key \
  -out server.crt \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Personal/OU=Dev/CN=sf-developer"

# Generate base64 encoded key for GitHub Secrets
echo "Generating base64 encoded key (server.key.base64)..."
cat server.key | base64 > server.key.base64

echo ""
echo "✅ Certificate generation completed!"
echo ""
echo "Files created:"
echo "  - server.key (private key)"
echo "  - server.crt (certificate)"
echo "  - server.key.base64 (for GitHub Secrets)"
echo ""
echo "⚠️  IMPORTANT: These files are automatically excluded from Git (.gitignore)"
echo ""
echo "Next steps:"
echo "1. Upload server.crt to Salesforce Connected App"
echo "2. Copy server.key.base64 content to GitHub Secrets (SERVER_KEY_BASE64)"
echo "3. Never commit these files to Git!"
