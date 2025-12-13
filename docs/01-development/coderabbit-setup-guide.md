# CodeRabbit セットアップガイド

**作成日**: 2025-12-12  
**対象フェーズ**: Phase 0

---

## 📋 概要

CodeRabbitは、AIを活用したコードレビューツールです。GitHub PRに対して自動的にレビューコメントを提供し、コード品質の向上とレビュー時間の短縮を実現します。

## 🎯 主要機能

- **自動コードレビュー**: PR作成時に自動的に詳細なレビューを実施
- **セキュリティチェック**: SOQL/SQLインジェクション、FLS/CRUD権限などをチェック
- **ベストプラクティス提案**: Salesforce開発のベストプラクティスを提案
- **日本語対応**: 設定により日本語でレビュー結果を表示
- **学習機能**: プロジェクト固有のルールを学習

---

## 🚀 セットアップ手順

### Step 1: CodeRabbit GitHubアプリをインストール

1. [CodeRabbit GitHub App](https://github.com/apps/coderabbitai) にアクセス
2. **Install** または **Configure** をクリック
3. リポジトリ選択:
   - **Only select repositories** を選択
   - `sf-ai-cli-practice-v2` を選択
4. **Install & Authorize** をクリック
5. 必要に応じてGitHubパスワードを入力

### Step 2: 設定ファイル確認

`.coderabbit.yaml` は既にプロジェクトに含まれています ✅

**主要設定内容**:

```yaml
# 言語設定
language: ja  # 日本語でレビュー

# レビュー設定
reviews:
  review_level: assertive  # 詳細なレビュー
  auto_review:
    enabled: true  # 自動レビュー有効

# ファイルフィルタ
path_filters:
  include:
    - "force-app/**/*.cls"     # Apexクラス
    - "force-app/**/*.trigger" # Apexトリガー
    - "force-app/**/*.js"      # LWC JavaScript
    - "**/*.yml"               # GitHub Actions
  exclude:
    - "node_modules/**"
    - "certificates/**"        # セキュリティ: 証明書除外

# PR制限
pr_limits:
  max_files: 80  # 80ファイル超過時に警告
```

### Step 3: 初回PR作成とレビュー確認

CodeRabbitの動作を確認するため、簡単なPRを作成します。

#### 3.1 テストブランチ作成

```bash
cd /Users/takashin/code/sf-ai-cli-practice-v2

# 新しいブランチを作成
git checkout -b test/coderabbit-setup

# 小さな変更を加える（例: READMEに行追加）
echo "" >> README.md
echo "<!-- CodeRabbit setup test -->" >> README.md

# コミット
git add README.md
git commit -m "test: CodeRabbitセットアップ確認"

# プッシュ
git push -u origin test/coderabbit-setup
```

#### 3.2 PR作成

GitHub UIまたはCLIでPR作成:

```bash
gh pr create \
  --base develop \
  --head test/coderabbit-setup \
  --title "test: CodeRabbitセットアップ確認" \
  --body "CodeRabbitの動作確認用テストPR"
```

#### 3.3 CodeRabbitレビュー確認

1. PRページを開く
2. 数分待つとCodeRabbitがレビューコメントを投稿
3. 以下を確認:
   - ✅ CodeRabbitのコメントが日本語で表示される
   - ✅ プロジェクト設定が反映されている
   - ✅ チャット機能が利用可能

#### 3.4 テストPRをクローズ

確認後、テストPRはクローズ（マージ不要）:

```bash
gh pr close test/coderabbit-setup
git checkout develop
git branch -D test/coderabbit-setup
```

---

## 💡 使い方のベストプラクティス

### PR作成時

1. **小さいPR**: 80ファイル以下、変更行数500行以下が理想
2. **明確な説明**: PRテンプレートを活用
3. **テスト含む**: すべての変更にテストを含める
4. **フォーマット**: Prettier/ESLintで統一

### CodeRabbitとのやり取り

#### レビューコメントへの返信

```markdown
# CodeRabbitの提案に同意する場合
@coderabbitai この提案を適用します

# 質問する場合
@coderabbitai この変更の影響範囲を教えてください

# 意見を述べる場合
@coderabbitai この実装はパフォーマンス要件のため必要です
```

#### チャットコマンド

```markdown
# コード説明を依頼
@coderabbitai このクラスの役割を説明してください

# セキュリティチェック
@coderabbitai セキュリティリスクはありますか？

# テストカバレッジ確認
@coderabbitai テストカバレッジは十分ですか？
```

---

## ⚙️ カスタマイズ

### レビュー対象ファイルの追加

`.coderabbit.yaml` の `path_filters.include` に追加:

```yaml
path_filters:
  include:
    - "config/**/*.xml"  # 設定ファイルも追加
```

### カスタムルールの追加

`.coderabbit.yaml` の `custom_instructions` に追加:

```yaml
custom_instructions: |
  ## プロジェクト固有ルール
  
  - Logger.debug()を使用する（System.debug()は禁止）
  - すべてのApexクラスにテストクラスが必要
```

---

## 🔧 トラブルシューティング

### CodeRabbitがレビューしない

**原因**: PRタイトルに`[skip ci]`や`WIP`などが含まれている

**解決**: PRタイトルを変更するか、設定を調整

### レビューが英語で表示される

**原因**: `.coderabbit.yaml` の `language` 設定が反映されていない

**解決**:
1. `.coderabbit.yaml` を確認 → `language: ja` が設定されているか確認
2. PRを再度開く、またはCodeRabbitに `@coderabbitai 日本語でレビューしてください` とコメント

### レビューが遅い

**原因**: PRのファイル数や変更行数が多い

**解決**: PRを小さく分割（80ファイル以下、500行以下推奨）

---

## 📊 効果測定

CodeRabbit導入後の効果を測定:

| 指標 | 目標 |
|------|------|
| レビュー時間短縮 | 50%削減 |
| バグ検出率 | 30%向上 |
| コード品質スコア | 継続的改善 |

---

## 🔗 参考リンク

- [CodeRabbit公式ドキュメント](https://docs.coderabbit.ai/)
- [CodeRabbit設定ガイド](https://docs.coderabbit.ai/guides/configure-coderabbit)
- [.coderabbit.yaml](../.coderabbit.yaml)

---

**次のステップ**: [PRワークフローガイド](pr-workflow-guide.md)
