# セットアップ前提条件

このプロジェクトを開始する前に、以下のツールとアカウントが必要です。

## 💻 必須ソフトウェア

### 1. Docker Desktop
- **バージョン:** 最新版推奨
- **インストール:** [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **用途:** 開発環境のコンテナ化

### 2. Node.js
- **バージョン:** 18.x 以上
- **インストール:** [Node.js公式サイト](https://nodejs.org/)
- **確認:** `node --version`

### 3. Salesforce CLI v2
- **バージョン:** 最新版
- **インストール:** `npm install -g @salesforce/cli`
- **確認:** `sf --version`

### 4. Git
- **バージョン:** 2.x 以上
- **インストール:** [Git公式サイト](https://git-scm.com/)
- **確認:** `git --version`

### 5. Jujutsu（オプション）
- **バージョン:** 最新版
- **インストール:** `brew install jj` (macOS)
- **確認:** `jj --version`
- **用途:** より高速なローカルバージョン管理

## 🔧 推奨ツール

### 1. VS Code
- **拡張機能:**
  - Salesforce Extension Pack
  - Prettier
  - ESLint
  - GitHub Copilot（オプション）
  - Jest Runner

### 2. git-secrets
- **インストール:** `brew install git-secrets` (macOS)
- **用途:** シークレット情報の誤コミット防止

### 3. gitleaks
- **インストール:** `brew install gitleaks` (macOS)
- **用途:** シークレット検出

## 🌐 必須アカウント

### 1. Salesforce Developer Account
- **取得:** [Salesforce Developer](https://developer.salesforce.com/)
- **環境:** Developer Edition または Sandbox

### 2. GitHub Account
- **取得:** [GitHub](https://github.com/)
- **必要権限:** リポジトリWrite権限

### 3. AI API（オプション）
**選択肢1: Anthropic（推奨）**
- **取得:** [Anthropic Console](https://console.anthropic.com/)
- **用途:** sfdx-hardis AI機能
- **モデル:** claude-3-5-sonnet

**選択肢2: OpenAI**
- **取得:** [OpenAI Platform](https://platform.openai.com/)
- **モデル:** GPT-4

## ✅ 環境確認コマンド

すべての前提条件が満たされているか確認：

```bash
# Node.js
node --version  # v18.x.x以上

# npm
npm --version   # 9.x.x以上

# Salesforce CLI
sf --version    # @salesforce/cli/2.x以上

# Git
git --version   # 2.x以上

# Docker
docker --version
docker-compose --version

# Jujutsu（オプション）
jj --version

# git-secrets（オプション）
git-secrets --version

# gitleaks（オプション）
gitleaks version
```

## 📝 次のステップ

前提条件が整ったら、以下のドキュメントに進んでください：

1. [Dockerセットアップ](02-docker-setup.md)
2. [JWT認証設定](03-jwt-authentication.md)
3. [GitHub Secrets設定](04-github-secrets.md)
