# AI Conflict Advisor

**Phase 3 Week 3の核心機能**

## 📋 コンセプト

AIは「アドバイザー」であり、「自動解決者」ではない

- Jujutsuの哲学を尊重
- ユーザーが最終判断
- Phase 6-9への準備

## 🎯 3つのモード

### Mode 1: Advisor（デフォルト・推奨）

**目的:** 分析と提案のみ。解決はしない。

```bash
npm run parallel:resolve
```

**動作:**
1. コンフリクトを検出
2. AIで分析（タイプ、複雑度、リスク）
3. 解決提案を表示
4. ユーザーが選択:
   - 提案を見る
   - クリップボードにコピー
   - 次へ進む

**特徴:**
- ✅ Jujutsuの哲学を完全尊重
- ✅ ファイルを変更しない
- ✅ 学習機会を提供
- ✅ 安全

**使用例:**
```
📝 Conflict 1/3: AccountService.cls
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Conflict Analysis:
  Type:       Method additions from parallel branches
  Complexity: Low
  Risk:       Low

💡 Reasoning:
  Both branches add independent methods.
  No overlapping logic or dependencies.
  Safe to merge both changes.

✨ AI Suggestion:
  (Use option 1 below to view full code)

❓ Actions:
  1. Show full suggested code
  2. Copy suggestion to clipboard
  3. Next conflict
  q. Quit

Choose [1/2/3/q]:
```

---

### Mode 2: Interactive

**目的:** AI提案の即時適用（確認あり）

```bash
npm run parallel:resolve:interactive
```

**動作:**
1. コンフリクトを検出
2. AIで分析
3. 提案を表示
4. **各ファイルで確認**
5. ユーザーが選択:
   - 適用する (y)
   - 詳細を見る (d)
   - スキップ (n)
  - 終了 (q)

**特徴:**
- ⚠️ ファイルを変更する
- ✅ 各ファイルで確認
- ✅ ユーザーが最終判断

**使用例:**
```
📝 Conflict 1/3: AccountService.cls

📊 Analysis:
  Type: Method additions | Complexity: Low | Risk: Low

💡 Reasoning:
  Both branches add independent methods...

✨ Suggested Resolution:
  public class AccountService {
      // ... (preview)
  }
  ... (45 lines total)

❓ Apply this suggestion?
  [y] Yes, apply and continue
  [d] Show full diff
  [n] No, skip this conflict
  [q] Quit

Choose [y/d/n/q]:
```

---

### Mode 3: Auto（実験的・危険）

**目的:** 完全自動解決（Phase 6-9準備）

```bash
npm run parallel:resolve:auto
```

**動作:**
1. **明示的な警告**と確認
2. 全コンフリクトを自動解決
3. 確認なし

**特徴:**
- 🔴 完全自動
- 🔴 確認なし
- ⚠️ 実験的
- ✅ Phase 6-9のプロトタイプ

**使用例:**
```
⚠️  WARNING: AUTO MODE
This will automatically resolve ALL conflicts without confirmation.
This mode is experimental and intended for Phase 6-9 preparation.

Are you absolutely sure? Type 'YES' to continue: YES

⚡ Auto-resolving: AccountService.cls
   Type: Method additions | Risk: Low
✅ Resolved

⚡ Auto-resolving: AccountController.cls
   Type: Logic changes | Risk: Medium
✅ Resolved

✅ Conflict advisor completed!
```

---

## 📊 モード比較

| 機能 | Advisor | Interactive | Auto |
|------|---------|-------------|------|
| ファイル変更 | ❌ No | ✅ Yes | ✅ Yes |
| 確認 | 毎回 | 毎回 | なし |
| Jujutsu哲学 | 完全尊重 | 尊重 | 一部妥協 |
| 推奨シーン | 学習・検討 | 通常作業 | 自動化テスト |
| Phase 3価値 | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| Phase 6-9準備 | - | ⭐ | ⭐⭐⭐ |

---

## 🚀 使い方

### 基本ワークフロー

```bash
# 1. 並行開発
npm run parallel:start feature-1 feature-2 feature-3

# 2. 開発中にコンフリクト発生
# （Jujutsuなのでコンフリクトしたまま作業継続可能）

# 3. 必要なときにアドバイザー起動
npm run parallel:resolve

# 4. AIの提案を見て判断
# - 提案を採用
# - 手動で解決
# - スキップして後で対応

# 5. 解決したいときにInteractiveモード
npm run parallel:resolve:interactive
```

### ベストプラクティス

**Advisorモードで始める:**
```bash
npm run parallel:resolve  # 提案を見る
```

**納得したらInteractiveで適用:**
```bash
npm run parallel:resolve:interactive  # 適用
```

**Autoは慎重に:**
```bash
# 本当に必要なときだけ
npm run parallel:resolve:auto
```

---

## 🎯 Phase 3-9の位置付け

### Phase 3（Week 3）

**AIの役割:** アドバイザー  
**主体:** 人間  
**価値:** 並行開発の促進

### Phase 6-9

**AIの役割:** 実行者  
**主体:** AI  
**価値:** 完全自律化

**Week 3 = 橋渡し**
- Advisorモード: Phase 3の完成形
- Autoモード: Phase 6-9のプロトタイプ

---

## 🔧 技術詳細

### 依存関係

- `@anthropic-ai/sdk`: Claude API
- `tsx`: TypeScript実行
- `readline`: インタラクティブプロンプト

### 環境変数

```bash
export ANTHROPIC_API_KEY='your-api-key'
```

### AI分析項目

- **Type:** コンフリクトの種類
- **Complexity:** 複雑度（Low/Medium/High）
- **Risk:** リスクレベル（Low/Medium/High）
- **Reasoning:** 発生理由と解決方法
- **Suggestion:** 解決済みコード

---

## ⚠️ 注意事項

1. **APIコスト:** Claude API使用料が発生
2. **レビュー推奨:** AI解決後は必ず人間がレビュー
3. **バックアップ:** `jj undo`で戻せる
4. **Jujutsu推奨:** コンフリクトと共存する開発スタイル

---

## 💡 Jujutsuの哲学

**Conflict-as-first-class-object:**
- コンフリクトは「問題」ではなく「状態」
- コンフリクトしたまま作業継続可能
- 解決は「必要なとき」に

**AI Advisorはこの哲学を尊重:**
- Advisorモード: コンフリクトを解決しない
- Interactiveモード: ユーザーが選択
- Autoモード: Phase 6-9への準備

---

**Week 3 完了！** 🎉

次: Week 4 - 統合テスト
