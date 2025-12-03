# Architecture Decision Records (ADR)

**プロジェクト**: sf-ai-cli-practice-v2  
**作成日**: 2025-12-03  
**最終更新**: 2025-12-03

---

## 📋 目次

1. [Decision 1: Service層アーキテクチャ](#decision-1-service層アーキテクチャ)
2. [Decision 2: AI Provider](#decision-2-ai-provider)
3. [Decision 3: Query Builder](#decision-3-query-builder)

---

## Decision 1: Service層アーキテクチャ

### ステータス: 🟡 暫定決定（Phase 2で再評価）

### コンテキスト

Salesforce開発におけるビジネスロジック層の設計方針を決定する必要がある。

### 選択肢

#### A. fflib-apex-common（エンタープライズパターン）
```yaml
利点:
  - Service/Domain/Selector層の明確な分離
  - UnitOfWorkパターンでトランザクション管理
  - 依存性注入（Force-DI）
  - 大規模プロジェクトで実績

欠点:
  - 学習曲線が急
  - 小規模プロジェクトには過剰
  - ボイラープレートコード増加
```

#### B. Simple Architecture with Trigger Actions Framework
```yaml
利点:
  - シンプルで理解しやすい
  - メタデータ駆動（コードデプロイ不要）
  - Flow統合可能
  - 小〜中規模プロジェクトに最適

欠点:
  - 大規模化時のリファクタリング必要
  - トランザクション管理は手動
```

### 決定: **B. Simple Architecture（Phase 0-1）**

#### 理由

1. **個人開発フェーズ**: 現時点では複雑性が不要
2. **学習コスト**: 即座に生産性を発揮可能
3. **柔軟性**: Phase 2以降でfflibへ移行可能
4. **Trigger Actions Framework**: メタデータ駆動で変更容易

#### Phase 0-1 実装方針

```yaml
アーキテクチャ:
  Trigger Layer:
    - Apex Trigger Actions Framework使用
    - メタデータでハンドラー制御
  
  Business Logic Layer:
    - シンプルなServiceクラス（必要時のみ）
    - Utility/Helperクラス
  
  Data Access Layer:
    - Query Builder（Decision 3で選定）
    - Dynamic SOQL with FLS/CRUD checks
```

#### Phase 2 再評価ポイント

```yaml
fflibへ移行検討する条件:
  - ビジネスロジックが複雑化（クラス数50+）
  - 複数開発者の協業開始
  - トランザクション整合性が重要になる
  - テスタビリティ向上の必要性
```

---

## Decision 2: AI Provider

### ステータス: 🟢 決定（Phase 0）

### コンテキスト

sfdx-hardisのAI機能（Flow/Apexドキュメント自動生成、デプロイアシスタント）で使用するAI Providerを選定。

### 選択肢

#### A. Anthropic Claude
```yaml
利点:
  - sfdx-hardis公式推奨
  - claude-3-5-sonnet: 高性能
  - コンテキスト長大（200K tokens）
  - コストパフォーマンス良好

欠点:
  - 日本語対応は英語より劣る（改善中）
```

#### B. OpenAI GPT-4
```yaml
利点:
  - 高品質な日本語対応
  - 広範な知識ベース
  - 豊富なエコシステム

欠点:
  - Claude比でコスト高
  - コンテキスト長制限（128K tokens）
```

#### C. Agentforce（Salesforce AI）
```yaml
利点:
  - Salesforce統合
  - データセキュリティ（Salesforce内）
  - Trust Layer

欠点:
  - Salesforce Foundations必要（コスト）
  - 個人開発には過剰
```

### 決定: **A. Anthropic Claude（Phase 0-2）**

#### 理由

1. **sfdx-hardis推奨**: 公式で最適化済み
2. **コストパフォーマンス**: 個人開発予算に適合
3. **高性能**: claude-3-5-sonnetは最新世代
4. **将来性**: Phase 3以降でAgentforce検討可可能

#### 設定

```yaml
# .env.local
ANTHROPIC_API_KEY=sk-ant-...
ANTHROPIC_MODEL=claude-3-5-sonnet
PROMPTS_LANGUAGE=ja
AI_MAXIMUM_CALL_NUMBER=5000

月間コスト見積:
  ドキュメント生成: ~$5-10/月
  デプロイアシスタント: ~$3-5/月
  合計: ~$10-15/月
```

#### Phase 3 再評価ポイント

```yaml
Agentforceへ移行検討する条件:
  - チーム3人以上に拡大
  - Salesforce Foundations導入
  - コンプライアンス要件強化
  - 月間AI利用コスト$100超過
```

---

## Decision 3: Query Builder

### ステータス: 🔶 評価中（Phase 1-2で決定）

### コンテキスト

動的SOQLクエリの構築方法を統一し、保守性・セキュリティ・テスタビリティを向上させる。

### 選択肢

#### A. SOQL Lib
```yaml
GitHub: beyond-the-cloud-dev/soql-lib
特徴:
  - Fluent Interface（メソッドチェーン）
  - 型安全
  - モック対応良好
  - 軽量（依存関係最小）

利点:
  - 学習コスト低
  - パフォーマンス良好
  - テストしやすい

欠点:
  - コミュニティ小規模
  - 機能が基本的
```

#### B. Nebula Query & Search
```yaml
GitHub: jongpie/NebulaQueryAndSearch
特徴:
  - Nebulaエコシステム統合
  - FLS自動チェック
  - 豊富な機能
  - 複雑クエリ対応

利点:
  - セキュア（FLS自動）
  - Nebula Loggerと統合
  - 高機能

欠点:
  - Nebulaエコシステム依存
  - 学習コスト高
  - オーバーヘッド
```

### Phase 1-2 評価計画

```yaml
評価方法:
  1. 両方インストール（Phase 1）
  2. 同一クエリを実装
     - Account検索（条件複数）
     - 関連オブジェクト取得
     - 集計クエリ
  3. 比較評価
     - コード可読性
     - テストモック性
     - パフォーマンス
     - 学習コスト

決定基準（Phase 2）:
  シンプル重視: SOQL Lib
  セキュリティ/統合重視: Nebula Query
```

---

## 決定のトレーサビリティ

| Decision | Phase 0 | Phase 1 | Phase 2 | Phase 3+ |
|----------|---------|---------|---------|----------|
| Service層 | Simple ✅ | Simple継続 | 再評価 | fflib検討 |
| AI Provider | Claude ✅ | Claude継続 | 再評価 | Agentforce検討 |
| Query Builder | 両方試用 | 評価実施 | 決定 🎯 | - |

---

## 参考資料

### Service層
- [fflib-apex-common](https://github.com/apex-enterprise-patterns/fflib-apex-common)
- [Apex Trigger Actions Framework](https://github.com/mitchspano/apex-trigger-actions-framework)

### AI Providers
- [Anthropic Claude](https://www.anthropic.com/claude)
- [sfdx-hardis AI Guide](https://sfdx-hardis.cloudity.com/hardis/doc/ai/)

### Query Builders
- [SOQL Lib](https://github.com/beyond-the-cloud-dev/soql-lib)
- [Nebula Query & Search](https://github.com/jongpie/NebulaQueryAndSearch)

---

**次回更新**: Phase 2開始時（2025 Q2予定）
