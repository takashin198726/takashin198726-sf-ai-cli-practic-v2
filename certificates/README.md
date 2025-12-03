# 証明書ディレクトリ

このディレクトリには、Salesforce JWT認証で使用する証明書と秘密鍵を配置します。

## ⚠️ 重要: セキュリティ

- このディレクトリ内の `.key`, `.crt`, `.pem`, `.p12`, `.base64` ファイルは **絶対にGitにコミットしないでください**
- `.gitignore` で自動的に除外されています
- 証明書は個人/チームで安全に管理してください

## 証明書生成方法

```bash
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

## GitHub Secrets設定

以下のSecretsをGitHubリポジトリに設定してください：

- `SF_CONSUMER_KEY`: 接続アプリのConsumer Key
- `SF_USERNAME`: Salesforceユーザー名
- `SERVER_KEY_BASE64`: `server.key.base64`の内容
- `SF_INSTANCE_URL`: Salesforceインスタンス URL

## ファイル一覧（例）

```
certificates/
├── README.md          # このファイル
├── server.key         # 秘密鍵（.gitignore除外）
├── server.crt         # 証明書（.gitignore除外）
└── server.key.base64  # base64エンコード済み秘密鍵（.gitignore除外）
```

## ローテーション

証明書は定期的にローテーションしてください（推奨: 年1回）
