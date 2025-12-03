# Security Policy

## 🔒 セキュリティ方針

sf-ai-cli-practice-v2 プロジェクトはセキュリティを最優先事項と考えています。

## 🛡️ サポートされているバージョン

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## 📢 脆弱性の報告

セキュリティ上の脆弱性を発見した場合は、以下の方法で報告してください：

### 推奨方法: GitHub Private Vulnerability Reporting

1. このリポジトリの **Security** タブに移動
2. **Report a vulnerability** をクリック
3. 詳細を記入して送信

### 代替方法: メール

プロジェクトメンテナーに直接メールで報告：
- **Email**: [your-email@example.com]
- **件名**: `[SECURITY] sf-ai-cli-practice-v2 Vulnerability Report`

### 報告に含めるべき情報

脆弱性報告には以下の情報を含めてください：

- **脆弱性の種類** (例: SQLインジェクション、XSS、権限昇格など)
- **影響を受けるコンポーネント** (ファイル名、関数名など)
- **再現手順** (詳細なステップバイステップ)
- **影響範囲** (どのような被害が発生する可能性があるか)
- **修正提案** (可能であれば)

## ⏱️ 対応プロセス

1. **受領確認**: 報告から24時間以内に受領を確認します
2. **初期評価**: 48時間以内に脆弱性を評価します
3. **修正開発**: 重要度に応じて修正を開発します
   - **Critical**: 24-48時間
   - **High**: 7日以内
   - **Medium**: 30日以内
   - **Low**: 次回リリース
4. **パッチリリース**: 修正をリリースします
5. **開示**: 適切なタイミングで公開します

## 🚫 禁止事項

脆弱性調査において、以下の行為は禁止されています：

- 本番環境への攻撃
- サービス妨害攻撃 (DoS/DDoS)
- 個人情報へのアクセスや流出
- 報告前の公開 (Responsible Disclosure)

## 🔐 セキュリティベストプラクティス

### 開発者向け

1. **シークレット管理**
   - 絶対にコードにシークレットを含めない
   - `.env.local` ファイルは `.gitignore` で除外
   - GitHub Secretsを使用してCI/CD環境で管理

2. **認証情報**
   - JWT認証を使用
   - 証明書は定期的にローテーション（年1回推奨）
   - 秘密鍵は絶対にGitにコミットしない

3. **依存関係**
   - 定期的に `npm audit` を実行
   - Dependabotアラートに迅速に対応
   - 最新のセキュリティパッチを適用

4. **コード品質**
   - PR前にセキュリティスキャン実行
   - PMD静的解析で脆弱性検出
   - FLS/CRUD権限を適切に実装

### 運用者向け

1. **アクセス制御**
   - 最小権限の原則を適用
   - GitHub リポジトリアクセスを適切に管理
   - Salesforce接続アプリの権限を最小限に

2. **監視とログ**
   - Salesforce Event Monitoringを有効化
   - 異常なアクティビティを監視
   - ログには機密情報を含めない

3. **インシデント対応**
   - セキュリティインシデント対応計画を準備
   - 定期的なバックアップ
   - 迅速なパッチ適用体制

## 📚 参考資料

- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [Salesforce Security Guide](https://developer.salesforce.com/docs/atlas.en-us.securityImplGuide.meta/securityImplGuide/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

## 📞 連絡先

セキュリティチーム: security@example.com

---

**最終更新**: 2025-12-03
