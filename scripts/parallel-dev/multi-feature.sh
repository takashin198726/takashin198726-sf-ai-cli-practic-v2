#!/bin/bash
set -e

# Multi-Feature Parallel Development Script
# Manages multiple features in parallel using Jujutsu

COMMAND=$1
shift

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

start_parallel_features() {
  local features=("$@")
  
  if [ ${#features[@]} -eq 0 ]; then
    echo -e "${RED}❌ No features specified${NC}"
    echo "Usage: $0 start <feature1> <feature2> ..."
    exit 1
  fi
  
  echo -e "${GREEN}🚀 Starting parallel development for ${#features[@]} features...${NC}"
  echo ""
  
  for feature in "${features[@]}"; do
    # 各機能用の新しいchangeを作成
    jj new main -m "feat: $feature"
    jj branch create "$feature"
    
    echo -e "${GREEN}✅ Created: $feature${NC}"
  done
  
  echo ""
  echo -e "${YELLOW}📊 Parallel Development Status:${NC}"
  jj log -r 'parallel' --limit 10
  
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}📋 Next Steps:${NC}"
  echo "  jj edit <feature-name>  # Switch to a feature"
  echo "  jj status               # Check current changes"
  echo "  jj commit -m 'msg'      # Commit your work"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

switch_feature() {
  local feature=$1
  
  if [ -z "$feature" ]; then
    echo -e "${RED}❌ No feature specified${NC}"
    echo "Usage: $0 switch <feature-name>"
    echo ""
    echo "Available features:"
    jj branch list | grep -v "main\|develop" || echo "  (none)"
    exit 1
  fi
  
  jj edit "$feature"
  echo -e "${GREEN}✅ Switched to: $feature${NC}"
  echo ""
  jj status
}

sync_and_merge() {
  echo -e "${YELLOW}🔀 Syncing and merging parallel features...${NC}"
  echo ""
  
  # 1. mainの最新を取得
  echo "📥 Fetching latest from remote..."
  jj git fetch
  
  # 2. mainブランチを更新
  jj branch set main -r $(jj log -r 'main@origin' --no-graph -T 'commit_id' | head -1)
  
  # 3. 各並行ブランチをmainに対してリベース
  echo ""
  echo "🔄 Rebasing parallel features onto main..."
  
  for branch in $(jj branch list | grep -v "main\|develop" | awk '{print $1}'); do
    echo -e "${YELLOW}  Rebasing: $branch${NC}"
    jj rebase -b "$branch" -d main
  done
  
  # 4. コンフリクトチェック
  echo ""
  CONFLICTS=$(jj log -r 'conflict()' --no-graph | wc -l)
  
  if [ "$CONFLICTS" -gt 0 ]; then
    echo -e "${RED}⚠️  Conflicts detected!${NC}"
    echo ""
    jj log -r 'conflict()' --limit 5
    echo ""
    echo -e "${YELLOW}💡 Jujutsu stores conflicts as commits.${NC}"
    echo "   You can continue working and resolve later:"
    echo ""
    echo "   1. jj edit <conflicted-branch>"
    echo "   2. Resolve conflicts in files"
    echo "   3. jj commit -m 'Resolve conflicts'"
    echo ""
    echo "   Or run AI auto-resolution:"
    echo "   npx ts-node scripts/parallel-dev/auto-resolve.ts"
  else
    echo -e "${GREEN}✅ No conflicts! All features synced successfully.${NC}"
  fi
}

list_features() {
  echo -e "${YELLOW}📊 Parallel Features:${NC}"
  echo ""
  jj log -r 'parallel' --no-graph -T '
  Feature: ' -T 'branch_name' -T '
  Status:  ' -T 'if(conflict, "⚠️  CONFLICT", "✅ Clean")' -T '
  Updated: ' -T 'committer.timestamp().ago()' -T '
  ─────────────────────────────────────────────
'
  
  echo ""
  echo -e "${YELLOW}Total features:${NC} $(jj branch list | grep -v "main\|develop" | wc -l)"
}

show_help() {
  cat << 'EOF'
Multi-Feature Parallel Development Tool

USAGE:
  ./multi-feature.sh <command> [args]

COMMANDS:
  start <feat1> <feat2> ...  Start parallel development for multiple features
  switch <feature>           Switch to a specific feature
  sync                       Sync with main and rebase all features
  list                       List all parallel features
  help                       Show this help message

EXAMPLES:
  # Start 3 features in parallel
  ./multi-feature.sh start "account-sync" "lead-scoring" "email-campaign"
  
  # Switch to a feature
  ./multi-feature.sh switch account-sync
  
  # After working, sync with main
  ./multi-feature.sh sync
  
  # Check status
  ./multi-feature.sh list

WORKFLOW:
  1. Start parallel features
  2. Switch between features as needed (instant, no stashing)
  3. Commit regularly (jj commit -m "message")
  4. Sync periodically to catch conflicts early
  5. Resolve conflicts (or use auto-resolve.ts)
  6. Create PRs from each feature branch

EOF
}

# Main command dispatcher
case $COMMAND in
  start)
    start_parallel_features "$@"
    ;;
  switch)
    switch_feature "$1"
    ;;
  sync)
    sync_and_merge
    ;;
  list)
    list_features
    ;;
  help|--help|-h)
    show_help
    ;;
  *)
    echo -e "${RED}❌ Unknown command: $COMMAND${NC}"
    echo ""
    show_help
    exit 1
    ;;
esac
