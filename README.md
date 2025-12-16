# sf-ai-cli-practice-v2

**AI-driven Salesforce Development Platform**

---

## 🏗️ Monorepo Structure

This project uses npm Workspaces to separate stable and experimental code:

```
sf-ai-cli-practice-v2/
├── packages/
│   ├── core/              # Phase 0-4（安定版・本番使用可能）
│   └── experimental/      # Phase 5-9（実験版）
├── force-app/             # Salesforceメタデータ（共通）
└── package.json           # Workspace設定
```

---

## 📦 Packages

### @sf-ai-cli/core（安定版）

**Phase 0-4 完了機能:**
- ✅ **CI/CD基盤** - sfdx-hardis統合
- ✅ **並行開発** - Jujutsu + iTerm2
- ✅ **AI Conflict Advisor** - 3モード対応
- ✅ **AI品質向上** - Lint分析、データ生成、ドキュメント翻訳

**使用方法:**
```bash
# ルートから実行（推奨）
npm run core:dashboard
npm run core:quality:analyze

# または直接実行
npm run parallel:dashboard --workspace=@sf-ai-cli/core
```

### @sf-ai-cli/experimental（実験版）

**Phase 5-9 計画中:**
- 🔬 Phase 5: インテリジェント・コードレビュー
- 🔬 Phase 6: 自律型デプロイメント
- 🔬 Phase 7: 完全自律開発
- 🔬 Phase 8-9: エンタープライズAI統合

**使用方法:**
```bash
npm run exp:dev
```

---

## 🚀 Quick Start

### インストール

```bash
npm install
```

### 主要コマンド

**並行開発（Jujutsu）:**
```bash
npm run core:dashboard           # リアルタイムダッシュボード
npm run core:hardis:start        # 並行機能開始 + sfdx-hardis初期化
npm run core:resolve             # AI Conflict Advisor
```

**コード品質:**
```bash
npm run core:quality:lint        # Mega-Linter実行
npm run core:quality:analyze     # AI分析（日本語）
```

**テストデータ:**
```bash
npm run core:data:generate       # SFDMU設定AI生成
```

**Salesforce共通:**
```bash
npm run test:apex                # Apexテスト
npm run prettier                 # コード整形
```

---

## 📚 Documentation

**安定版（Phase 0-4）:**
- [Phase 1-2: CI/CD基盤](packages/core/docs/MIGRATION-PHASE1-2.md)
- [Phase 3: Jujutsu並行開発](packages/core/scripts/parallel-dev/README.md)
- [Phase 4: AI品質向上](packages/core/docs/PHASE4-AI-QUALITY.md)

**実験版（Phase 5-9）:**
- [Roadmap](packages/experimental/README.md)

**アーキテクチャ:**
- [設計決定](packages/core/docs/architecture-decisions.md)

---

## 🎯 プロジェクト進捗

- ✅ Phase 0: セットアップ完了
- ✅ Phase 1-2: sfdx-hardis統合完了
- ✅ Phase 3: Jujutsu並行開発完了
- ✅ Phase 4: AI品質向上完了
- 📋 Phase 5-9: 計画中（experimental/）

**進捗率:** 45% 完了

---

## 💡 Workspace活用

### パッケージ間の参照

experimentalはcoreの機能を再利用:

```typescript
// packages/experimental/scripts/ai/example.ts
import { analyzeConflict } from '@sf-ai-cli/core';

// coreの機能を使用
const analysis = await analyzeConflict(...);
```

### CI/CD分離

- **core-ci.yml** - 安定版（厳格なテスト）
- **experimental-ci.yml** - 実験版（失敗OK）

---

## 🔧 開発

### ブランチ戦略

- `main` - 安定版リリース
- `refactor/monorepo-structure` - Monorepo移行
- `experimental/*` - 実験的機能

### バージョン管理

- `v1.0-before-monorepo` - Monorepo移行前バックアップ
- `v1.0.0` - Phase 0-4完了版（安定）
- `v2.0.0-alpha` - Phase 5実験版

---

## 📝 License

Private - 学習用プロジェクト

---

**Built with:** sfdx-hardis + Jujutsu + Claude AI
