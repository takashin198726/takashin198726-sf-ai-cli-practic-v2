#!/bin/bash
# GitHub ラベル作成スクリプト
# large-pr-approved ラベルをリポジトリに追加

set -e

echo "🏷️  Creating 'large-pr-approved' label in GitHub repository..."

# GitHubリポジトリ情報を取得
REPO_OWNER=$(gh repo view --json owner -q .owner.login)
REPO_NAME=$(gh repo view --json name -q .name)

echo "Repository: $REPO_OWNER/$REPO_NAME"

# ラベルが既に存在するか確認
if gh label list | grep -q "large-pr-approved"; then
  echo "✅ Label 'large-pr-approved' already exists"
else
  # ラベル作成
  gh label create "large-pr-approved" \
    --description "Allows PRs with more than 80 files to pass CI checks" \
    --color "d73a4a"
  
  echo "✅ Label 'large-pr-approved' created successfully"
fi

echo ""
echo "📝 Usage instructions:"
echo "  To allow a large PR (>80 files) to pass CI:"
echo "  1. Add 'large-pr-approved' label to the PR"
echo "  2. CI will automatically re-run and pass"
echo ""
echo "  GitHub UI: PR page → Labels → large-pr-approved"
echo "  GitHub CLI: gh pr edit <PR_NUMBER> --add-label large-pr-approved"
