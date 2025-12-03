# JWT認証設定ガイド

Salesforce組織への安全な認証のため、JWT（JSON Web Token）認証を設定します。

## 📋 概要

JWT認証を使用すると、パスワードを使わずに自動的にSalesforceに認証できます。CI/CDパイプラインで必須です。

## 🔐 Step 1: 証明書と秘密鍵の生成

### 自動生成（推奨）

```bash
cd certificates
bash ../scripts/security/generate-jwt-cert.sh
```

### 手動生成

```bash
cd certificates

# 秘密鍵生成
openssl genrsa -out server.key 2048

# 証明書生成（有効期限1年）
openssl req -new -x509 -nodes -sha256 -days 365 \
  -key server.key \
  -out server.crt \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Personal/OU=Dev/CN=takashin"

# GitHub Secrets用にbase64エンコード
cat server.key | base64 > server.key.base64
```

## 🔌 Step 2: Salesforce接続アプリ作成

### 2.1 Salesforceにログイン

個人Salesforce組織にログインします。

### 2.2 接続アプリ作成

1. **Setup** > **App Manager** に移動
2. **New Connected App** をクリック
3. 以下の情報を入力：

**基本情報**
```
Connected App Name: sf-ai-cli-practice-v2 CI/CD
API Name: sf_ai_cli_practice_v2_cicd
Contact Email: あなたのメールアドレス
```

**API （OAuth設定を有効化）**
- ✅ Enable OAuth Settings
- Callback URL: `http://localhost:1717/OauthRedirect`
- ✅ Use digital signatures
  - **証明書アップロード**: `certificates/server.crt` をアップロード

**Selected OAuth Scopes**（以下を追加）:
- Access the identity URL service (id, profile, email, address, phone)
- Manage user data via APIs (api)
- Perform requests at any time (refresh_token, offline_access)
- Access and manage your data (full)

4. **Save** をクリック
5. **Continue** をクリック

### 2.3 Consumer Key取得

保存後、以下の情報をコピー：
- **Consumer Key**: これをGitHub Secretsに設定します

## 🧪 Step 3: ローカルでテスト

```bash
# .env.localファイルを編集
SF_CONSUMER_KEY=<Consumer Keyを貼り付け>
SF_USERNAME=your-salesforce-username@your-org.com
SF_INSTANCE_URL=https://test.salesforce.com

# JWT認証テスト
sf org login jwt \
  --client-id "$SF_CONSUMER_KEY" \
  --jwt-key-file certificates/server.key \
  --username "$SF_USERNAME" \
  --instance-url "$SF_INSTANCE_URL" \
  --alias default \
  --set-default

# 認証確認
sf org display --target-org default
```

成功すれば、組織情報が表示されます。

## 📤 Step 4: GitHub Secretsに設定

次のステップ: [GitHub Secrets設定](04-github-secrets.md)

## 🔄 証明書ローテーション

証明書は年1回ローテーションすることを推奨します。

### ローテーション手順

1. 新しい証明書を生成
2. Salesforce接続アプリで証明書を更新
3. GitHub Secretsを更新
4. 古い証明書を削除

## ⚠️ トラブルシューティング

### エラー: "Grant invalid"

**原因**: 接続アプリの設定が完了していない  
**解決**: 接続アプリ作成後、最大10分待ってから再試行

### エラー: "Invalid JWT"

**原因**: 証明書と秘密鍵のペアが一致していない  
**解決**: 証明書を再生成し、接続アプリにアップロードし直す

### エラー: "User hasn't approved this app"

**原因**: 接続アプリがユーザーに承認されていない  
**解決**: 
1. Setup > Manage Connected Apps > <アプリ名>
2. Edit Policies
3. Permitted Users: "Admin approved users are pre-authorized"
4. 対象ユーザーにPermission Setを割り当て
