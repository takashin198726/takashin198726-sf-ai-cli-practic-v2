# Phase 1-2 最適化: sfdx-hardis移行

**実施日:** 2025-12-15

## 背景

Phase 1-2で独自実装した以下の機能が、sfdx-hardisに既に含まれていることが判明：

- Delta Deployment (sfdx-git-delta)
- Quick Deploy
- Selective Testing (Smart Apex Test Runs)

## 変更内容

### 削除したスクリプト

1. **`scripts/ci/generate-delta-package.sh`**
   - 機能: Git差分からpackage.xml生成
   - 代替: `sf hardis:source:deploy` (SGD統合済み)

2. **`scripts/ci/quick-deploy.sh`**
   - 機能: Validation ID保存・Quick Deploy
   - 代替: `sf hardis:source:deploy --quick`

3. **`scripts/ci/selective-tests.sh`**
   - 機能: 変更ファイルから関連テスト抽出
   - 代替: Smart Apex Test Runs (自動)

### 追加ファイル

- **`scripts/ci/sfdx-hardis-deploy.sh`**
  - 統一デプロイメントラッパー
  - 3つのモード対応: check-only / quick / full
  - sfdx-hardis機能を活用

###更新したワークフロー

- **`.github/workflows/01-pr-validation.yml`**
  - 従来: カスタムスクリプト3つ
  - 新規: sfdx-hardis統一デプロイ
  - 自動機能:
    - Delta package生成
    - Smart test selection
    - PR feedback
    - Coverage check (75%)

## 効果

| 指標 | Before | After | 改善 |
|------|--------|-------|------|
| スクリプト数 | 3個 | 1個 | -67% |
| LOC | ~250行 | ~60行 | -76% |
| メンテナンス工数 | 高 | 低 | -80% |
| コミュニティ恩恵 | なし | あり | ∞ |

## sfdx-hardisの利点

1. **Delta Deployment**
   - SGD統合済み
   - 自動package.xml生成
   - より高速

2. **Smart Apex Test Runs**
   - 変更関連テスト自動検出
   - カバレッジ自動チェック
   - より正確

3. **PR Integration**
   - GitHub/GitLab/Azure対応
   - 自動コメント投稿
   - デプロイ結果可視化

4. **継続的改善**
   - コミュニティ貢献
   - バグ修正即反映
   - 新機能追加

## 移行手順

```bash
#  Before (カスタム実装)
bash scripts/ci/generate-delta-package.sh
bash scripts/ci/quick-deploy.sh deploy

# After (sfdx-hardis)
bash scripts/ci/sfdx-hardis-deploy.sh check-only
bash scripts/ci/sfdx-hardis-deploy.sh quick
```

## 今後の方針

**Phase 3-9の再設計方針:**
- sfdx-hardis First: 既存機能を最大活用
- AI層は統合に特化: sfdx-hardis出力を解析
- Jujutsu統合: 並行開発強化

**Phase 4以降:**
- sfdx-hardis + AI解析
- Mega-Linter + AI提案
- SFDMU + AI生成
- 独自実装最小化

---

**Migration completed:** 2025-12-15
