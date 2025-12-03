# Nebula Logger セットアップガイド

**作成日**: 2025-12-03  
**対象**: sf-ai-cli-practice-v2

---

## 📋 概要

[Nebula Logger](https://github.com/jongpie/NebulaLogger) は、Salesforce向けの包括的なロギングフレームワークです。Apex、Flow、LWCからの統一されたログ管理を提供します。

## 🎯 なぜNebula Loggerか

### 利点

```yaml
統合性:
  - Apex/Flow/LWC統一インターフェース
  - Platform Events経由で非同期保存
  - カスタマイズ可能なログレベル

可視性:
  - リアルタイムログ監視
  - Lightning App Builderでダッシュボード構築
  - 高度な検索・フィルタリング

パフォーマンス:
  - Governor Limits影響最小化
  - バッファリングでDML削減
  - 非同期処理

セキュリティ:
  - ユーザー情報自動記録
  - トランザクションID追跡
  - 機密情報マスキング
```

---

## 🚀 インストール

### オプション1: Unlocked Package（推奨）

```bash
# 最新バージョンのPackage IDを確認
# https://github.com/jongpie/NebulaLogger/releases

# インストール
sf package install --package 04t5Y000001T6nTQAS \
  --target-org default \
  --wait 20 \
  --security-type AdminsOnly
```

### オプション2: Git Submodule（開発用）

```bash
# サブモジュールとして追加
git submodule add https://github.com/jongpie/NebulaLogger.git force-app/nebula-logger

# 初期化
git submodule update --init --recursive
```

---

## ⚙️ 設定

### 1. Custom Settings設定

**Setup > Custom Settings > Logger Settings > Manage**

推奨設定（個人開発用）:

```yaml
General Settings:
  Enable System Messages: true
  Default Log Level: DEBUG
  Default Save Method: EVENT_BUS  # Platform Events使用
  
Performance:
  Enable Batch Purge: true
  Days to Retain Logs: 30  # 30日間保持
  
Security:
  Enable Log Sharing: false  # 個人開発では不要
  Store IP Address: true
```

### 2. Platform Events設定

Nebula LoggerはPlatform Eventsを使用します。自動的に作成されます：

- `LogEntryEvent__e`: ログエントリ
- `LogEvent__e`: ログトランザクション

### 3. sfdx-hardis統合

`config/.sfdx-hardis.yml`に追加：

```yaml
# Logging
logging:
  framework: "nebula-logger"
  defaultLevel: "DEBUG"
  retentionDays: 30
  
  # ログ出力先
  outputs:
    - platform_events  # Platform Events
    - debug_log       # Salesforce Debug Log
```

---

## 💻 使用方法

### Apexでの使用

#### 基本的な使用

```apex
// Logger初期化（クラスごとに1回）
public class AccountService {
    
    public static void createAccount(String name) {
        // ログ開始
        Logger.info('Account作成開始', name);
        
        try {
            Account acc = new Account(Name = name);
            insert acc;
            
            // 成功ログ
            Logger.info('Account作成成功')
                .setRecordId(acc.Id)
                .addTag('Success');
                
        } catch (Exception e) {
            // エラーログ
            Logger.error('Account作成失敗', e);
        } finally {
            // ログ保存（必須！）
            Logger.saveLog();
        }
    }
}
```

#### 詳細なログ

```apex
public class OpportunityService {
    
    public static void processOpportunity(Id oppId) {
        Logger.setParentLogTransactionId();  // トランザクション追跡
        
        // DEBUGレベル
        Logger.debug('処理開始', oppId);
        
        // INFOレベル（タグ付き）
        Logger.info('商談取得')
            .setRecordId(oppId)
            .addTag('Opportunity')
            .addTag('Processing');
        
        // WARNレベル
        if (someCondition) {
            Logger.warn('警告: 条件に一致')
                .setField('Stage', 'Closed Won');
        }
        
        // ERRORレベル（例外付き）
        try {
            // 処理
        } catch (Exception e) {
            Logger.error('エラー発生', e)
                .setRecordId(oppId)
                .addTag('Error');
        }
        
        Logger.saveLog();
    }
}
```

### Flowでの使用

#### Flow Action追加

1. **Process Builder/Flow**で「Action」を追加
2. **Logger - Add Log Entry**を選択
3. パラメータ設定：
   ```
   Log Level: INFO
   Message: フロー開始
   Record ID: {!recordId}
   Save Log: true  # 最後のActionでtrueに設定
   ```

### LWCでの使用

#### logger.jsインポート

```javascript
import { LightningElement } from 'lwc';
import { createLogger } from 'c/logger';

export default class MyComponent extends LightningElement {
    logger = createLogger(this);
    
    connectedCallback() {
        this.logger.info('Component初期化');
    }
    
    handleClick() {
        try {
            this.logger.debug('ボタンクリック');
            // 処理
            this.logger.info('処理成功');
        } catch (error) {
            this.logger.error('エラー発生', error);
        } finally {
            this.logger.saveLog();
        }
    }
}
```

---

## 🔍 ログの確認

### Lightning Appで確認

1. **App Launcher** > **Nebula Logger**
2. **Logs**タブでログ一覧表示
3. フィルタリング・検索

### Apex実行

```apex
// 直近のログ取得
List<Log__c> recentLogs = [
    SELECT Id, StartTime__c, LoggedBy__c, TotalERRORLogEntries__c
    FROM Log__c
    ORDER BY StartTime__c DESC
    LIMIT 10
];
```

---

## 🧪 テストでの使用

### ログ出力をテスト

```apex
@isTest
private class AccountServiceTest {
    
    @isTest
    static void testCreateAccount_Success() {
        // Given
        String accountName = 'Test Account';
        
        // When
        Test.startTest();
        AccountService.createAccount(accountName);
        Test.stopTest();
        
        // Then
        // ログが保存されたか確認
        List<Log__c> logs = [SELECT Id FROM Log__c];
        Assert.areEqual(1, logs.size(), 'ログが1件保存されるはず');
        
        // ログエントリ確認
        List<LogEntry__c> entries = [
            SELECT Message__c, LoggingLevel__c
            FROM LogEntry__c
            WHERE Log__c = :logs[0].Id
        ];
        Assert.isTrue(entries.size() > 0, 'ログエントリが存在するはず');
    }
}
```

---

## 🛠️ トラブルシューティング

### ログが保存されない

**原因**: `Logger.saveLog()`を呼び忘れ

**解決**: 必ず`finally`ブロックで`Logger.saveLog()`を実行

### Platform Eventsが動作しない

**原因**: Event Busのキューが詰まっている

**解決**: 
```bash
# Event Bus Monitor確認
Setup > Platform Events > Event Bus Monitor
```

### ログが多すぎる

**原因**: DEBUGレベルで大量ログ

**解決**: Custom Settingsでログレベルを調整
```
Default Log Level: INFO or WARN
```

---

## 📊 ベストプラクティス

### 1. ログレベルの使い分け

```yaml
FINEST/FINER/FINE: 詳細デバッグ（開発時のみ）
DEBUG: 通常のデバッグ情報
INFO: 重要な処理の開始/終了
WARN: 警告（処理は継続）
ERROR: エラー（処理失敗）
```

### 2. タグの活用

```apex
// 機能別タグ
Logger.info('処理開始')
    .addTag('Integration')
    .addTag('API');

// 環境別タグ
Logger.debug('デバッグ情報')
    .addTag('Development');
```

### 3. トランザクション追跡

```apex
// 親トランザクションID設定
Logger.setParentLogTransactionId();

// 複数メソッド間で同じトランザクションIDを共有
service1.process();  // 同じトランザクションID
service2.process();  // 同じトランザクションID

Logger.saveLog();
```

---

## 🔐 セキュリティ

### 機密情報のマスキング

```apex
// 機密情報をログに含める前にマスク
String maskedSSN = '***-**-' + ssn.substring(ssn.length() - 4);
Logger.info('SSN確認').setField('SSN', maskedSSN);
```

### ログアクセス制御

個人開発では不要ですが、チーム移行時：

```
Setup > Sharing Settings > Log__c
- Private（所有者のみ）
- または Permission Set経由
```

---

## 📚 参考資料

- [Nebula Logger GitHub](https://github.com/jongpie/NebulaLogger)
- [公式ドキュメント](https://jongpie.github.io/NebulaLogger/)
- [Wiki](https://github.com/jongpie/NebulaLogger/wiki)

---

**次のステップ**: サンプルログ出力テスト実施
