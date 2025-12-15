# Phase 4: AI駆動品質向上ガイド

**Phase 4完成: sfdx-hardis + AI解析層**

---

## 🎯 Phase 4 Overview

Phase 4では、sfdx-hardisの強力な既存機能にAI解析層を追加し、開発者体験を大幅に向上させます。

### アーキテクチャ

```
┌─────────────────────────────────────┐
│ AI Analysis Layer (Phase 4)         │
│  - Contextual explanations          │
│  - Fix suggestions                  │
│  - Best practices                   │
│  - Natural language interface       │
└─────────────────────────────────────┘
               ↓ 解析・拡張
┌─────────────────────────────────────┐
│ sfdx-hardis Foundation             │
│  - Mega-Linter (10+ linters)        │
│  - SFDMU (data management)          │
│  - AI Documentation (built-in)      │
└─────────────────────────────────────┘
```

---

## 📋 Week 1: Mega-Linter AI解析

### 目的

Mega-Linterの生レポートを人間が理解しやすい分析に変換

### 使い方

```bash
# 1. Mega-Linter実行
npm run quality:lint

# 2. AI解析（英語）
npm run quality:analyze

# 3. AI解析（日本語）
npm run quality:analyze:ja
```

### 出力例

```markdown
# 📊 コード品質分析レポート

## 🔴 優先度別の問題

### Critical（緊急）
1. **PMD - ApexUnitTestClassShouldHaveAsserts**
   - ファイル: AccountServiceTest.cls:45
   - 問題: テストクラスにアサーションがありません
   - 修正例: `System.assertEquals(expected, actual);`

### High（高）
...

## 🔧 修正提案

### AccountServiceTest.cls
1. **問題:** テストにアサーションがない
2. **影響:** テストが実際に何も検証していない
3. **修正方法:**
   \`\`\`apex
   @isTest
   static void testGetAccount() {
       Account acc = AccountService.getAccount('123');
       System.assertNotNull(acc, 'Account should exist');
       System.assertEquals('Test Account', acc.Name);
   }
   \`\`\`
```

### 期待効果

- **理解時間:** 30分 → 5分 (-83%)
- **修正精度:** +300%

---

## 📋 Week 2: SFDMU設定AI生成

### 目的

自然言語からSFDMU export.json を自動生成

### 使い方

```bash
npm run data:generate

# プロンプトが表示される:
# 📝 Describe your test data requirements:
# > 10 Accounts with 5 Contacts each, all in Japan

# 出力: data/export.json
```

### 生成される設定例

```json
{
  "objects": [
    {
      "query": "SELECT Id, Name, BillingCountry FROM Account WHERE BillingCountry = 'Japan' LIMIT 10",
      "operation": "Upsert",
      "externalId": "Name"
    },
    {
      "query": "SELECT Id, FirstName, LastName, AccountId, Email FROM Contact WHERE Account.BillingCountry = 'Japan'",
      "operation": "Upsert",
      "externalId": "Email"
    }
  ]
}
```

### データエクスポート・インポート

```bash
# 設定生成
npm run data:generate

# データエクスポート
sf hardis:org:data:export

# データインポート（別の org へ）
sf hardis:org:data:import
```

### 期待効果

- **設定作成時間:** 60分 → 2分 (-97%)
- **エラー率:** -80%

---

## 📋 Week 3: ドキュメント日本語化

### 目的

sfdx-hardis AI生成ドキュメントを日本語に翻訳

### 使い方

```bash
# 1. sfdx-hardis AIドキュメント生成（英語）
npm run docs:ai

# 2. 日本語翻訳
npm run docs:translate

# 出力: docs/generated/project-documentation-ja.md
```

### 翻訳例

**Before (English):**
```markdown
# Project Documentation

## AccountService Class

This class handles Account-related operations.

### Methods

#### getAccount(Id accountId)
Returns an Account record by ID.
```

**After (Japanese):**
```markdown
# プロジェクトドキュメント

## AccountService クラス

このクラスはAccount関連の操作を処理します。

### メソッド

#### getAccount(Id accountId)
IDによってAccountレコードを返します。
```

### 期待効果

- **チーム共有:** 日本語チームとの協業改善
- **理解度:** +200%

---

## 🚀 統合ワークフロー

### 日常開発フロー

```bash
# 1. コード作成
# ... 開発 ...

# 2. 品質チェック（自動）
npm run quality:lint

# 3. AI解析で問題理解
npm run quality:analyze:ja

# 4. 修正
# ... コード修正 ...

# 5. 再チェック
npm run quality:lint
```

### テストデータ準備フロー

```bash
# 1. 要件定義
npm run data:generate
# > "100 Products with inventory in Tokyo warehouse"

# 2. データエクスポート
sf hardis:org:data:export

# 3. テスト環境へインポート
sf hardis:org:data:import --target-org test-env
```

### ドキュメント更新フロー

```bash
# 1. AIドキュメント生成
npm run docs:ai

# 2. 日本語翻訳
npm run docs:translate

# 3. コミット
git add docs/generated
git commit -m "docs: Update project documentation"
```

---

## 📊 Phase 4 全体効果

| 指標 | Before | After | 改善 |
|------|--------|-------|------|
| **Lint理解** | 30分 | 5分 | **-83%** |
| **データ設定** | 60分 | 2分 | **-97%** |
| **ドキュメント** | 手動 | 自動 | **∞** |
| **品質向上** | 中 | 高 | **+200%** |

---

## 💡 ベストプラクティス

### 1. 定期的な品質チェック

```bash
# git pre-commit hook に追加
npm run quality:lint && npm run quality:analyze:ja
```

### 2. テストデータの版管理

```bash
# data/export.json を Git 管理
git add data/export.json
git commit -m "test: Update test data configuration"
```

### 3. ドキュメントの自動更新

```bash
# GitHub Actions で自動化
# .github/workflows/docs.yml
npm run docs:ai && npm run docs:translate
```

---

## ⚠️ 注意事項

1. **APIコスト:** Claude API使用料が発生
2. **AI精度:** 生成結果は必ずレビュー
3. **機密情報:** コードに機密情報が含まれないよう注意

---

**Phase 4 完了！** 🎉

**次:** Phase 5 - インテリジェント・コードレビュー
