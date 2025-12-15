# Jujutsu + sfdx-hardis Integration Guide

**Phase 3 Week 4の核心機能**

## 🎯 コンセプト

**Jujutsuの並行開発 + sfdx-hardisのDevOps = 最強の開発環境**

Week 4では、2つの強力なツールを統合し、シームレスな並行開発ワークフローを実現します。

---

## 🚀 統合ワークフロー

### 1. 並行機能開始（1コマンド）

```bash
npm run parallel:hardis:start feature-a feature-b feature-c
```

**自動実行内容:**
1. ✅ Jujutsuで3つの並行ブランチ作成
2. ✅ 各ブランチでsfdx-hardis環境初期化
   - `sf hardis:work:new --auto-assign`
   - 依存パッケージインストール
   - データシーディング（SFDMU）
3. ✅ iTerm2マルチペイン起動（オプション）

### 2. 開発中の管理

```bash
# sfdx-hardis状態確認
npm run parallel:hardis:status

# 出力例:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Branch: feature-a
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 📋 sfdx-hardis Configuration: ✅
# 🔐 Authenticated Org:
#   Username: dev@example.com
#   Org ID: 00D...
#   Instance: https://...salesforce.com
```

### 3. 定期同期

```bash
# 全ブランチをmainと同期
npm run parallel:hardis:sync
```

### 4. デプロイテスト

```bash
# 全ブランチをデプロイ検証（check-only）
npm run parallel:hardis:deploy

# 各ブランチで:
# sf hardis:source:deploy --check true
```

---

## 🤖 CI/CD Matrix Build

### 自動並行デプロイ

GitHub Actionsが自動的に：
1. Jujutsu並行ブランチを検出
2. 各ブランチをMatrix buildで並行検証
3. sfdx-hardis PR feedbackを自動投稿

**ワークフロー:** `.github/workflows/02-parallel-deploy.yml`

### Matrix Build の動作

```yaml
# 検出例:
# branches: [feature-a, feature-b, feature-c]

# Matrix buildで3つ並行実行:
deploy-parallel:
  strategy:
    matrix:
      branch: [feature-a, feature-b, feature-c]
  
  steps:
    - jj edit ${{ matrix.branch }}
    - sf hardis:source:deploy --check true
```

### PR Feedback

各ブランチのデプロイ結果がPRに自動コメント：
- ✅ デプロイ成功
- ❌ デプロイ失敗時の詳細
- 📊 カバレッジ情報
- 🔍 Code Quality結果

---

## 📊 統合のメリット

### 開発者体験

| 機能 | Before (Week 1-3) | After (Week 4) | 改善 |
|------|------------------|----------------|------|
| **環境セットアップ** | 手動 | 自動 | +500% |
| **並行デプロイ検証** | 順次 | 並行 | +300% |
| **PR Feedback** | なし | 自動 | 新機能 |

### CI/CD 効率

**3つの並行機能の場合:**

```
Before (順次):
feature-a: 10分
feature-b: 10分
feature-c: 10分
合計: 30分

After (並行):
全ブランチ: 10分
合計: 10分 (-67%)
```

---

## 🔧 使い方

### 基本ワークフロー

```bash
# 1. 並行機能開始
npm run parallel:hardis:start auth-feature ui-feature api-feature

# 2. 各機能で開発
jj edit auth-feature
# ... 開発 ...

jj edit ui-feature
# ... 開発 ...

# 3. 定期的に状態確認
npm run parallel:hardis:status

# 4. mainと同期
npm run parallel:hardis:sync

# 5. デプロイテスト
npm run parallel:hardis:deploy

# 6. PRマージ
# → GitHub Actions Matrix buildが自動検証
# → sfdx-hardis PR feedbackが自動投稿
```

### トラブルシューティング

#### sfdx-hardis環境が初期化されない

**原因:** `.sfdx-hardis.yml`がない

**解決:**
```bash
# プロジェクトルートに作成
sf hardis:project:init
```

#### 認証エラー

**解決:**
```bash
# 各ブランチで再認証
jj edit feature-a
sf org login web
```

---

## 💡 ベストプラクティス

### 1. feature命名規則

```bash
# Good ✅
npm run parallel:hardis:start auth-sso ui-dashboard api-webhook

# Bad ❌
npm run parallel:hardis:start feature1 test abc
```

### 2. 定期的な同期

```bash
# 毎日1回実行
npm run parallel:hardis:sync
```

### 3. デプロイテスト

```bash
# PRマージ前に必ず実行
npm run parallel:hardis:deploy
```

---

## 🎯 Phase 3完成

Week 4で、Phase 3「並行開発基盤」が完成しました：

- ✅ Week 1: Jujutsuセットアップ
- ✅ Week 2: iTerm2マルチペイン
- ✅ Week 3: AI Conflict Advisor
- ✅ **Week 4: sfdx-hardis統合**

**次: Phase 4 - AI駆動品質向上**

---

**Week 4 完了！** 🎉
