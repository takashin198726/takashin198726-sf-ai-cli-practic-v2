#!/bin/bash
set -e

# Parallel Development with sfdx-hardis Integration
# Combines Jujutsu parallel branch management with sfdx-hardis DevOps

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Help function
show_help() {
  echo "Usage: $0 <command> [options]"
  echo ""
  echo "Commands:"
  echo "  start <feature1> <feature2> ...  Start parallel features with sfdx-hardis setup"
  echo "  status                           Show sfdx-hardis status for all branches"
  echo "  sync                             Sync all branches with main and run sfdx-hardis checks"
  echo "  deploy                           Deploy all branches (check-only)"
  echo ""
  echo "Examples:"
  echo "  $0 start feature-a feature-b feature-c"
  echo "  $0 status"
  echo "  $0 deploy"
  exit 0
}

# Check dependencies
check_dependencies() {
  if ! command -v jj &> /dev/null; then
    echo "❌ Error: Jujutsu (jj) is not installed"
    echo "   Run: npm run parallel:setup"
    exit 1
  fi
  
  if ! command -v sf &> /dev/null; then
    echo "❌ Error: Salesforce CLI (sf) is not installed"
    exit 1
  fi
}

# Start parallel features with sfdx-hardis setup
start_parallel_features() {
  local features=("$@")
  
  if [ ${#features[@]} -eq 0 ]; then
    echo "❌ Error: No features specified"
    show_help
    exit 1
  fi
  
  echo -e "${BLUE}🚀 Starting ${#features[@]} parallel features with sfdx-hardis integration${NC}"
  echo ""
  
  # 1. Create Jujutsu bookmarks
  echo -e "${GREEN}📋 Step 1: Creating Jujutsu bookmarks${NC}"
  for feature in "${features[@]}"; do
    echo "  Creating bookmark: $feature"
    jj new main -m "feat: $feature" > /dev/null 2>&1
    jj bookmark create "$feature" -r @ > /dev/null 2>&1
  done
  echo ""
  
  # 2. Setup sfdx-hardis environment for each branch
  echo -e "${GREEN}📋 Step 2: Setting up sfdx-hardis environments${NC}"
  for feature in "${features[@]}"; do
    echo "  Setting up: $feature"
    jj edit "$feature" > /dev/null 2>&1
    
    # Run sfdx-hardis work setup (if configured)
    if [ -f ".sfdx-hardis.yml" ]; then
      echo "    - Running hardis:work:new..."
      sf hardis:work:new --debug 2>/dev/null || {
        echo "    ⚠️  hardis:work:new not configured, skipping"
      }
    else
      echo "    ℹ️  No .sfdx-hardis.yml found, skipping environment setup"
    fi
    
    echo "    ✅ Ready"
  done
  echo ""
  
  # 3. Launch iTerm2 multi-pane (if available)
  if [ -f "$SCRIPT_DIR/iterm-setup.sh" ]; then
    echo -e "${GREEN}📋 Step 3: Launching iTerm2 multi-pane environment${NC}"
    bash "$SCRIPT_DIR/iterm-setup.sh"
  fi
  
  echo ""
  echo -e "${GREEN}✅ Parallel features started successfully!${NC}"
  echo ""
  echo "Next steps:"
  echo "  - Switch branches: jj edit <feature-name>"
  echo "  - Check status: npm run parallel:status"
  echo "  - View dashboard: npm run parallel:dashboard"
}

# Show sfdx-hardis status for all branches
show_status() {
  echo -e "${BLUE}📊 sfdx-hardis Status for All Branches${NC}"
  echo ""
  
  # Get all feature bookmarks (excluding main/develop)
  local branches
  branches=$(jj bookmark list | grep -v -E '^(main|develop)$')
  
  if [ -z "$branches" ]; then
    echo "ℹ️  No feature branches found"
    return
  fi
  
  for branch in $branches; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}Branch: $branch${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    jj edit "$branch" > /dev/null 2>&1
    
    # Check if sfdx-hardis is configured
    if [ -f ".sfdx-hardis.yml" ]; then
      echo "📋 sfdx-hardis Configuration: ✅"
      
      # Show org info (if authenticated)
      if sf org display 2>/dev/null | grep -q "Username"; then
        echo ""
        echo "🔐 Authenticated Org:"
        sf org display --json | jq -r '.result | "  Username: \(.username)\n  Org ID: \(.id)\n  Instance: \(.instanceUrl)"'
      else
        echo "  ⚠️  No authenticated org"
      fi
    else
      echo "  ℹ️  sfdx-hardis not configured"
    fi
    
    echo ""
  done
  
  # Return to original branch
  jj edit main > /dev/null 2>&1
}

# Sync all branches and run sfdx-hardis checks
sync_branches() {
  echo -e "${BLUE}🔄 Syncing All Branches with Main${NC}"
  echo ""
  
  local branches
  branches=$(jj bookmark list | grep -v -E '^(main|develop)$')
  
  if [ -z "$branches" ]; then
    echo "ℹ️  No feature branches to sync"
    return
  fi
  
  for branch in $branches; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}Syncing: $branch${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Use multi-feature.sh sync if available
    if [ -f "$SCRIPT_DIR/multi-feature.sh" ]; then
      bash "$SCRIPT_DIR/multi-feature.sh" sync "$branch"
    else
      jj edit "$branch"
      jj rebase -d main
    fi
    
    echo ""
  done
  
  echo -e "${GREEN}✅ All branches synced${NC}"
}

# Deploy all branches with sfdx-hardis
deploy_all() {
  echo -e "${BLUE}🚀 Deploying All Branches (Check-Only)${NC}"
  echo ""
  
  local branches
  branches=$(jj bookmark list | grep -v -E '^(main|develop)$')
  
  if [ -z "$branches" ]; then
    echo "ℹ️  No feature branches to deploy"
    return
  fi
  
  for branch in $branches; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}Deploying: $branch${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    jj edit "$branch" > /dev/null 2>&1
    
    # Deploy with sfdx-hardis
    echo "Running: sf hardis:source:deploy --checkonly"
    if sf hardis:source:deploy --checkonly --debug 2>&1; then
      echo -e "${GREEN}✅ Deploy check passed${NC}"
    else
      echo -e "${YELLOW}⚠️  Deploy check failed${NC}"
    fi
    
    echo ""
  done
  
  # Return to main
  jj edit main > /dev/null 2>&1
  
  echo -e "${GREEN}✅ Deployment checks completed${NC}"
}

# Main
check_dependencies

case "$1" in
  start)
    start_parallel_features "${@:2}"
    ;;
  status)
    show_status
    ;;
  sync)
    sync_branches
    ;;
  deploy)
    deploy_all
    ;;
  help|--help|-h|"")
    show_help
    ;;
  *)
    echo "❌ Unknown command: $1"
    show_help
    ;;
esac
