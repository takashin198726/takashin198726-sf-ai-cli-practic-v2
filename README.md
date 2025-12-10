# sf-ai-cli-practice-v2

**Version:** 2.0  
**Created:** 2025-12-03  
**Purpose:** AI駆動型Salesforce CI/CDプラットフォーム

## 🎯 プロジェクト概要

実用的で持続可能なSalesforce CI/CDプラットフォーム。OSSツールを最大限活用し、個人開発からチーム開発へスムーズに移行できる柔軟な基盤を構築します。

## 🚀 主要機能

- **sfdx-hardis**: CI/CDオーケストレーション
- **Golden Stack**: モダンなApexアーキテクチャ
- **TDD実践**: Test-Driven Developmentの徹底
- **AI統合**: sfdx-hardisのAI機能活用
- **GitHub Projects**: タスク管理統合

## 📋 開発方針

```yaml
Phase 0-2（当面）:
  - 個人開発環境の最適化
  - 個人Salesforceアカウント使用
  - GitHub Projects統合
  - AI活用（Antigravity）でFlow→Apex変換

Phase 3以降（将来）:
  - チーム移行可能な設計
  - スケーラブルなアーキテクチャ
```

## 🛠️ 技術スタック

### Core
- **Salesforce CLI**: v2
- **sfdx-hardis**: CI/CDオーケストレーション
- **Git/Jujutsu**: バージョン管理

### Testing
- **Apex Test Framework**: TDD実践
- **ApexBluePrint**: テストデータビルダー
- **apex-mockery**: モックフレームワーク
- **Jest**: LWC単体テスト
- **Playwright**: E2Eテスト

### Code Quality
- **PMD**: Apex静的解析
- **Salesforce Code Analyzer**: 包括的解析
- **ESLint**: LWC
- **Prettier**: フォーマット

### Infrastructure
- **Docker**: コンテナ化
- **GitHub Actions**: CI/CD
- **git-secrets/gitleaks**: セキュリティスキャン

## 📁 ディレクトリ構造

```
sf-ai-cli-practice-v2/
├── .github/          # GitHub Actions workflows
├── .devcontainer/    # VS Code Dev Container
├── config/           # 設定ファイル
├── docs/             # ドキュメント
├── docker/           # Docker設定
├── force-app/        # Salesforceメタデータ
├── scripts/          # CI/CDスクリプト
└── tests/            # テストコード
```

## 🏁 クイックスタート

### 前提条件

詳細な前提条件は [Prerequisites Guide](docs/00-setup/01-prerequisites.md) を参照してください。

- Docker Desktop
- Node.js 18+
- Salesforce CLI v2
- Git

### セットアップ

```bash
# リポジトリをクローン
git clone <repository-url>
cd sf-ai-cli-practice-v2

# 自動セットアップスクリプト実行
bash scripts/dev/setup-local.sh

# ドキュメントに従ってセットアップ
# 1. 環境変数設定（.env.local）
# 2. JWT認証設定
# 3. Docker環境構築
```

**📚 詳細なセットアップ手順:**
- [環境変数設定](docs/00-setup/01-prerequisites.md)
- [GitHub Repository Setup](docs/00-setup/02-github-repository-setup.md) ⭐
- [JWT認証設定](docs/00-setup/03-jwt-authentication.md)
- [GitHub Secrets設定](docs/00-setup/04-github-secrets.md)
- [PRワークフローガイド](docs/01-development/pr-workflow-guide.md) ⭐

## 📚 ドキュメント

詳細なドキュメントは`docs/`ディレクトリを参照してください。

- [セットアップガイド](docs/00-setup/)
- [開発ガイド](docs/01-development/)
- [CI/CDガイド](docs/02-cicd/)
- [セキュリティガイド](docs/03-security/)

## 🔄 ワークフロー

### 開発フロー（TDD）

1. **Red**: テスト作成（失敗確認）
2. **Green**: 最小実装
3. **Refactor**: リファクタリング
4. **PR作成**: CodeRabbitレビュー

### デプロイフロー

1. PRマージ → GitHub Actions
2. セキュリティスキャン
3. 静的解析
4. テスト実行
5. Quick Deploy
6. 本番デプロイ

## 📊 主要目標

| 指標 | Phase 2 (2025 Q2) |
|------|-------------------|
| デプロイ頻度 | 日1回 |
| リードタイム | 3日 |
| 変更失敗率 | 5% |
| コードカバレッジ | 90% |
| TDD導入率 | 60% |

## 🤝 コントリビューション

このプロジェクトは現在個人開発用ですが、将来的にチーム開発への移行を想定しています。

## 🔒 セキュリティ

セキュリティ上の脆弱性を発見した場合は、[SECURITY.md](SECURITY.md) をご確認の上、適切な方法で報告してください。

## 📄 ライセンス

このプロジェクトは [MIT License](LICENSE) の下で公開されています。

## 📧 連絡先

プロジェクトオーナー: takashin

---

**Last Updated:** 2025-12-03

## ✅ Setup Completed
- JWT Authentication configured
- CI/CD ready
