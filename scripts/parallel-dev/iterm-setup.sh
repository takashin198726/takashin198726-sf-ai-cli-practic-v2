#!/bin/bash
set -e

# iTerm2マルチペイン環境セットアップ
# 各ペインで異なる機能を並行開発

echo "🖥️  Setting up iTerm2 multi-pane environment for parallel development..."

# iTerm2がインストールされているか確認
if ! osascript -e 'id "com.googlecode.iterm2"' &>/dev/null; then
  echo "❌ iTerm2 not found. Please install iTerm2 first:"
  echo "   brew install --cask iterm2"
  exit 1
fi

echo "✅ iTerm2 detected"

# 並行開発中の機能を取得（情報表示のみ）
FEATURES=$(jj branch list 2>/dev/null | grep -v -E '^(main|develop)$' | head -5 || echo "")

if [ -z "$FEATURES" ]; then
  echo "📋 No parallel features found. Creating example layout..."
else
  echo "📋 Found parallel features. Creating custom layout..."
  echo "$FEATURES"
fi

echo ""
echo "🚀 Creating iTerm2 multi-pane layout..."

# AppleScriptでiTerm2マルチペイン環境を構築
osascript <<EOF
tell application "iTerm2"
  -- 新しいウィンドウ作成
  set newWindow to (create window with default profile)
  
  tell current session of newWindow
    -- タイトル設定
    set name to "🚀 Parallel Development Dashboard"
    
    -- 垂直分割（左: 作業エリア、右: 監視エリア）
    set rightPane to (split vertically with default profile)
    
    -- 左側（作業エリア）を3分割
    set pane2 to (split horizontally with default profile)
    tell pane2
      set pane3 to (split horizontally with default profile)
    end tell
  end tell
  
  -- 各ペインに機能を割り当て
  tell first session of current tab of newWindow
    set name to "Feature 1"
    write text "echo '🎯 Feature 1 Development Pane'"
    write text "echo 'Switch to feature: jj edit <feature-name>'"
    write text ""
  end tell
  
  tell second session of current tab of newWindow
    set name to "Feature 2"
    write text "echo '🎯 Feature 2 Development Pane'"
    write text "echo 'Switch to feature: jj edit <feature-name>'"
    write text ""
  end tell
  
  tell third session of current tab of newWindow
    set name to "Feature 3"
    write text "echo '🎯 Feature 3 Development Pane'"
    write text "echo 'Switch to feature: jj edit <feature-name>'"
    write text ""
  end tell
  
  tell fourth session of current tab of newWindow
    set name to "📊 Monitor"
    write text "echo '📊 Parallel Development Monitor'"
    write text "echo '================================'"
    write text ""
    write text "# Real-time parallel development status"
    write text "watch -c -n 2 'jj log -r parallel --limit 10'"
  end tell
  
  -- ウィンドウを前面に
  activate
end tell
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ iTerm2 multi-pane environment created!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Layout:"
echo "  ┌─────────────┬─────────────┐"
echo "  │  Feature 1  │             │"
echo "  ├─────────────┤   Monitor   │"
echo "  │  Feature 2  │   (Watch)   │"
echo "  ├─────────────┤             │"
echo "  │  Feature 3  │             │"
echo "  └─────────────┴─────────────┘"
echo ""
echo "💡 Usage:"
echo "  - In each pane: jj edit <feature-name>"
echo "  - Monitor pane: Real-time status updates (Ctrl+C to stop)"
echo "  - Switch between panes: Cmd+[ or Cmd+]"
echo ""
echo "🎯 Pro tip:"
echo "  Save this layout: iTerm2 → Window → Save Window Arrangement"
