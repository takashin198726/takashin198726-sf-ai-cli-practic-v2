#!/bin/bash
set -e

# sfdx-hardis Deployment Wrapper
# Replaces: generate-delta-package.sh, quick-deploy.sh, selective-tests.sh
#
# sfdx-hardis automatically handles:
# - Delta deployment (via SGD integration)
# - Smart Apex Test selection
# - Quick deploy (if validation ID exists)
# - PR feedback (GitHub/GitLab/Azure)

echo "🚀 sfdx-hardis Deployment Wrapper"
echo "=================================="

# Parse command line arguments
MODE="${1:-check-only}"  # check-only, quick, full
TARGET_ORG="${SF_TARGET_ORG:-}"

case $MODE in
  check-only)
    echo "📋 Mode: Validation deployment (check-only)"
    echo ""
    
    sf hardis:source:deploy \
      --check true \
      --check-coverage true \
      --debug
    ;;
    
  quick)
    echo "⚡ Mode: Quick deploy"
    echo ""
    
    # sfdx-hardis automatically uses validation ID if available
    sf hardis:source:deploy \
      --check-coverage true \
      --debug
    ;;
    
  full)
    echo "📦 Mode: Full deployment"
    echo ""
    
    sf hardis:source:deploy \
      --no-prompt \
      --check-coverage true \
      --debug
    ;;
    
  *)
    echo "❌ Invalid mode: $MODE"
    echo ""
    echo "Usage: $0 [check-only|quick|full]"
    echo ""
    echo "Modes:"
    echo "  check-only  Validation deployment (default)"
    echo "  quick       Quick deploy using validation ID"
    echo "  full        Full deployment without validation"
    exit 1
    ;;
esac

echo ""
echo "✅ Deployment completed"
