# npm Workspace 互換性修正

**作成日:** 2025-12-16

## 問題

`workspace:*`プロトコルはpnpm専用で、npmではサポートされていません。

**エラー:**
```
npm error code EUNSUPPORTEDPROTOCOL
npm error Unsupported URL Type "workspace:": workspace:*
```

## 解決策

npmの`file:`プロトコルを使用してローカルパッケージを参照します。

### Before (pnpm専用)

```json
{
  "dependencies": {
    "@sf-ai-cli/core": "workspace:*"
  }
}
```

### After (npm互換)

```json
{
  "dependencies": {
    "@sf-ai-cli/core": "file:../core"
  }
}
```

## 動作

`file:`プロトコルを使用すると、npmは：
1. シンボリックリンクを作成
2. `node_modules`内で`@sf-ai-cli/core` → `../packages/core`を参照
3. 変更が即座に反映される

## 検証

```bash
npm install
npm run exp:dev
```

互換性が確保されます ✅
