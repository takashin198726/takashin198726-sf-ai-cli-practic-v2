#!/bin/bash
set -e

echo "🔍 Generating delta package manifest..."

# Base branch (default to main if not specified)
BASE_BRANCH=${1:-origin/main}

echo "📌 Comparing against: $BASE_BRANCH"

# Generate delta using sfdx-git-delta
sf sgd:source:delta \
  --to HEAD \
  --from "$BASE_BRANCH" \
  --output changed-sources \
  --generate-delta \
  --source force-app

# Check if package.xml was generated
if [ -f "changed-sources/package/package.xml" ]; then
  echo "✅ Delta package generated successfully"
  echo ""
  echo "📦 Package contents:"
  cat changed-sources/package/package.xml
  echo ""
  
  # Count metadata items
  ITEM_COUNT=$(grep -c "<members>" changed-sources/package/package.xml || echo "0")
  echo "📊 Total metadata items: $ITEM_COUNT"
else
  echo "ℹ️  No Salesforce metadata changes detected"
  echo "Creating empty package.xml for workflow compatibility"
  
  mkdir -p changed-sources/package
  cat > changed-sources/package/package.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <version>59.0</version>
</Package>
EOF
fi
