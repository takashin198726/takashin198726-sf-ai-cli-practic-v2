#!/bin/bash
set -e

echo "🔧 Setting up Jujutsu for parallel development..."

# 1. Jujutsuインストールチェック
if ! command -v jj &> /dev/null; then
  echo "📦 Jujutsu not found. Installing via Homebrew..."
  brew install jj
else
  echo "✅ Jujutsu already installed: $(jj --version)"
fi

# 2. 既存Gitリポジトリを Jujutsu化（colocate mode）
if [ ! -d ".jj" ]; then
  echo "🔄 Initializing Jujutsu in colocate mode..."
  jj git init --colocate
else
  echo "✅ Jujutsu repository already initialized"
fi

# 3. 並行開発用の設定
echo "⚙️  Configuring Jujutsu for parallel development..."

cat > .jjconfig.toml << 'EOF'
[template-aliases]
# Short commit IDs
'format_short_id(id)' = 'id.shortest(8)'

[revset-aliases]
# 並行開発中のブランチを表示
'parallel' = 'branches() & mine() & ~(main | develop)'

# 最近の作業
'recent' = 'mine() & ~(root() | main) & (@ | descendants(@))' 

# コンフリクト中のコミット
'conflicts' = 'conflict()'

[ui]
default-command = "log"
pager = "less -FRX"
diff-format = "git"

[git]
auto-local-branch = true
push-branch-prefix = ""

[colors]
"working_copy" = { bold = true, fg = "green" }
"conflict" = { bold = true, fg = "red" }
"description" = "yellow"
EOF

echo "✅ Jujutsu configuration created: .jjconfig.toml"

# 4. .gitignoreに.jjconfigを追加
if ! grep -q ".jjconfig.toml" .gitignore 2>/dev/null; then
  echo "" >> .gitignore
  echo "# Jujutsu personal config" >> .gitignore
  echo ".jjconfig.toml" >> .gitignore
  echo "✅ Added .jjconfig.toml to .gitignore"
fi

# 5. 使い方ガイド表示
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Jujutsu Parallel Development Setup Complete! 🎉           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Quick Start Guide:"
echo ""
echo "1. 並行開発開始:"
echo "   bash scripts/parallel-dev/multi-feature.sh start \"feature-1\" \"feature-2\" \"feature-3\""
echo ""
echo "2. 機能の切り替え:"
echo "   jj edit feature-1"
echo ""
echo "3. 並行開発状況確認:"
echo "   jj log -r parallel"
echo ""
echo "4. 変更をコミット:"
echo "   jj commit -m \"Your message\""
echo ""
echo "5. 同期とマージ:"
echo "   bash scripts/parallel-dev/multi-feature.sh sync"
echo ""
echo "📚 More info: jj help"
