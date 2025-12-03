# GitHub Secrets設定ガイド

GitHub ActionsでSalesforce認証を行うため、必要な認証情報をGitHub Secretsに安全に保存します。

## 🔐 必須Secrets

以下のSecretsをGitHubリポジトリに設定します。

### 1. SF_CONSUMER_KEY

**説明**: Salesforce接続アプリのConsumer Key  
**取得方法**: 
1. Salesforce Setup > App Manager
2. 作成した接続アプリの右側の▼ > View
3. Consumer Keyをコピー

**値の例**: `3MVG9...（非常に長い文字列）`

### 2. SF_USERNAME

**説明**: Salesforce組織のユーザー名  
**個人開発の場合**: `your-salesforce-username@your-org.com`  
**チーム開発の場合**: 共通サービスアカウントのUsername

### 3. SERVER_KEY_BASE64

**説明**: JWT認証用の秘密鍵（base64エンコード済み）  
**取得方法**:

```bash
# certificates/server.key.base64の内容をコピー
cat certificates/server.key.base64
```

**注意**: 改行も含めてすべてコピーしてください

### 4. SF_INSTANCE_URL

**説明**: Salesforceインスタンスのログイン URL  
**Sandbox環境**: `https://test.salesforce.com`  
**本番環境**: `https://login.salesforce.com`

## 📝 GitHub Secretsの設定手順

### Step 1: GitHubリポジトリに移動

```
https://github.com/<your-username>/sf-ai-cli-practice-v2
```

### Step 2: Settings > Secrets and variables > Actions

1. リポジトリページの **Settings** タブをクリック
2. 左サイドバーの **Secrets and variables** > **Actions** をクリック
3. **New repository secret** をクリック

### Step 3: 各Secretを追加

**SF_CONSUMER_KEY**
```
Name: SF_CONSUMER_KEY
Secret: <接続アプリのConsumer Key>
```

**SF_USERNAME**
```
Name: SF_USERNAME
Secret: your-salesforce-username@your-org.com
```

**SERVER_KEY_BASE64**
```
Name: SERVER_KEY_BASE64
Secret: <server.key.base64の内容>
```

**SF_INSTANCE_URL**
```
Name: SF_INSTANCE_URL
Secret: https://test.salesforce.com
```

## 🎯 オプションSecrets

### AI統合（sfdx-hardis）

**ANTHROPIC_API_KEY** (推奨)
```
Name: ANTHROPIC_API_KEY
Secret: <AnthropicのAPI Key>
```

または

**OPENAI_API_KEY**
```
Name: OPENAI_API_KEY
Secret: <OpenAIのAPI Key>
```

### GitHub Projects統合

**GITHUB_TOKEN**
- **自動設定**: GitHub Actionsで自動的に利用可能
- **手動設定不要**: デフォルトで使えます

必要に応じてPersonal Access Token (PAT)を作成:
```
Name: GH_PAT
Secret: <GitHub Personal Access Token>
Scopes: repo, project
```

## ✅ 設定確認

Secretsが正しく設定されたか確認する方法：

### 方法1: GitHub Actions実行

1. テスト用のPRを作成
2. GitHub Actionsが自動実行されます
3. ワークフローログで認証成功を確認

### 方法2: 手動トリガー

1. Actions タブに移動
2. ワークフローを選択
3. "Run workflow" をクリック
4. 実行ログを確認

## 🔄 Secretsのローテーション

セキュリティのため、定期的にSecretsをローテーションしてください。

### 推奨スケジュール

- **証明書（SERVER_KEY_BASE64）**: 年1回
- **API Keys（ANTHROPIC_API_KEY等）**: 6ヶ月ごと
- **Consumer Key**: セキュリティ侵害時のみ

### ローテーション手順

1. 新しい値を生成
2. GitHub Secretsを更新
3. ローカル環境の `.env.local` も更新
4. テスト実行で確認
5. 古い値を無効化/削除

## ⚠️ セキュリティベストプラクティス

### ✅ やるべきこと
- Secretsは絶対にコードに含めない
- `.env.local` は必ず `.gitignore` に含める
- 定期的にローテーションする
- 最小権限の原則を適用

### ❌ やってはいけないこと
- Secretsをログに出力する
- Secretsをコミットする
- Secretsを平文でSlack等に貼り付ける
- 複数プロジェクトで同じSecretを共有する

## 🧪 テスト

Secretsが正しく設定されているかテスト：

```bash
# ローカルでGitHub Actions環境を模倣
export SF_CONSUMER_KEY="<GitHub Secretsの値>"
export SF_USERNAME="your-salesforce-username@your-org.com"
export SF_INSTANCE_URL="https://test.salesforce.com"

# SERVER_KEY_BASE64をデコード
echo "$SERVER_KEY_BASE64" | base64 -d > /tmp/test-server.key

# JWT認証テスト
sf org login jwt \
  --client-id "$SF_CONSUMER_KEY" \
  --jwt-key-file /tmp/test-server.key \
  --username "$SF_USERNAME" \
  --instance-url "$SF_INSTANCE_URL" \
  --alias test-org

# クリーンアップ
rm /tmp/test-server.key
sf org logout --target-org test-org --no-prompt
```

## 📚 関連ドキュメント

- [JWT認証設定](03-jwt-authentication.md)
- [GitHub Actions - Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
