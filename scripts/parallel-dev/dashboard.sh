#!/bin/bash
set -e

# リアルタイム並行開発ダッシュボード
# watchコマンドで2秒ごとに更新

clear

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

display_dashboard() {
  clear
  
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  🚀 Parallel Development Dashboard${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo ""
  
  # 現在時刻
  echo -e "${YELLOW}🕐 $(date '+%Y-%m-%d %H:%M:%S')${NC}"
  echo ""
  
  # アクティブな並行機能
  echo -e "${YELLOW}📊 Active Parallel Features:${NC}"
  echo "─────────────────────────────────────────────────────────"
  
  if command -v jj &> /dev/null; then
    # parallel alias excludes main and develop with exact matching
    jj log -r "parallel" --no-graph -T '
  🎯 ' -T 'branch_name.fill(20)' -T ' │ ' -T 'if(conflict, "⚠️  CONFLICT", "✅ Clean")' -T ' │ ' -T 'author.email().local().fill(15)' -T ' │ ' -T 'committer.timestamp().ago()' -T '
' 2>/dev/null | head -10 || echo "  No parallel features (run: npm run parallel:start)"
  else
    echo "  ⚠️  Jujutsu not installed"
  fi
  
  echo ""
  
  # 最近の変更
  echo -e "${YELLOW}🔄 Recent Changes:${NC}"
  echo "─────────────────────────────────────────────────────────"
  
  if command -v jj &> /dev/null; then
    jj log -r "recent" --limit 5 --no-graph -T '
  ' -T 'change_id.shortest(8)' -T ' │ ' -T 'description.first_line().fill(40)' -T ' │ ' -T 'committer.timestamp().ago()' -T '
' 2>/dev/null || echo "  No recent changes"
  fi
  
  echo ""
  
  # コンフリクト状況
  echo -e "${YELLOW}⚠️  Conflicts:${NC}"
  echo "─────────────────────────────────────────────────────────"
  
  if command -v jj &> /dev/null; then
    CONFLICTS=$(jj log -r 'conflict()' --no-graph 2>/dev/null | wc -l | tr -d ' ')
    if [ "$CONFLICTS" -gt 0 ]; then
      echo -e "  ${RED}Found $CONFLICTS conflicted commits${NC}"
      jj log -r 'conflict()' --limit 3 --no-graph -T '
  ⚠️  ' -T 'branch_name' -T ' │ ' -T 'description.first_line()' -T '
' 2>/dev/null
      echo ""
      echo "  💡 Resolve with: npx ts-node scripts/parallel-dev/auto-resolve.ts"
    else
      echo -e "  ${GREEN}✅ No conflicts${NC}"
    fi
  fi
  
  echo ""
  
  # Git統計
  echo -e "${YELLOW}📈 Statistics:${NC}"
  echo "─────────────────────────────────────────────────────────"
  
  if command -v jj &> /dev/null; then
    TOTAL_FEATURES=$(jj branch list 2>/dev/null | grep -v -E '^(main|develop)$' | wc -l | tr -d ' ')
    echo "  Parallel features: $TOTAL_FEATURES"
  fi
  
  if command -v git &> /dev/null; then
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$UNCOMMITTED" -gt 0 ]; then
      echo -e "  Uncommitted changes: ${YELLOW}$UNCOMMITTED files${NC}"
    else
      echo -e "  Uncommitted changes: ${GREEN}None${NC}"
    fi
  fi
  
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo "  Press Ctrl+C to exit | Updating every 2 seconds..."
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

# メインループ（2秒ごとに更新）
if [ "$1" == "--once" ]; then
  # 1回だけ表示
  display_dashboard
else
  # 継続的に更新
  while true; do
    display_dashboard
    sleep 2
  done
fi
