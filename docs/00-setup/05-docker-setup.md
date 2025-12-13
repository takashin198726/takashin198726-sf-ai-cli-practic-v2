# Docker環境セットアップガイド

**作成日**: 2025-12-12  
**対象フェーズ**: Phase 0

---

## 📋 概要

このプロジェクトでは、Docker Composeを使用して開発環境を構築します。これにより、ローカル環境に依存せず、一貫した開発環境を提供できます。

## 🎯 Docker環境の利点

- **環境の一貫性**: チーム全員が同じ環境で開発
- **依存関係の管理**: Node.js、Salesforce CLI、Javaなどを自動インストール
- **クリーンな環境**: ローカル環境を汚さない
- **簡単なセットアップ**: `docker-compose up`だけで環境構築

---

## 📦 必須要件

### Docker Desktop

- **バージョン**: 最新版推奨
- **インストール**: [Docker Desktop](https://www.docker.com/products/docker-desktop/)

#### インストール確認

```bash
# Dockerバージョン確認
docker --version
# 出力例: Docker version 28.5.1

# Docker Composeバージョン確認
docker-compose --version
# 出力例: Docker Compose version v2.40.2
```

---

## 🚀 セットアップ手順

### Step 1: Docker Desktopを起動

1. Docker Desktopアプリケーションを起動
2. Docker Engineが起動するまで待つ（数秒〜1分）
3. メニューバーにDockerアイコンが表示され、"Docker Desktop is running"と表示されることを確認

### Step 2: 設定ファイル確認

プロジェクトには以下のDockerファイルが含まれています:

- `docker-compose.yml`: サービス定義
- `docker/Dockerfile`: コンテナイメージ定義

#### docker-compose.yml の内容

```yaml
services:
  dev:
    build:
      context: .
      dockerfile: docker/Dockerfile
    container_name: sf-ai-cli-practice-v2-dev
    volumes:
      - .:/workspace
      - ~/.sf:/root/.sf
      - ~/.jj:/root/.jj
      - ./certificates:/workspace/certificates:ro
    environment:
      - NODE_ENV=development
      - SF_AUTOUPDATE_DISABLE=true
    ports:
      - "1717:1717"  # Salesforce local dev server
      - "9229:9229"  # Node.js debugging
    working_dir: /workspace
    command: /bin/bash
    stdin_open: true
    tty: true
```

### Step 3: Docker設定の確認

```bash
cd /Users/takashin/code/sf-ai-cli-practice-v2

# Docker Compose設定の検証
docker-compose config
```

### Step 4: Dockerイメージのビルド

初回のみイメージをビルドします:

```bash
# イメージビルド（初回は数分かかる）
docker-compose build

# ビルド完了確認
docker images | grep sf-ai-cli-practice-v2
```

### Step 5: コンテナの起動

```bash
# バックグラウンドで起動
docker-compose up -d

# 起動確認
docker-compose ps
```

**期待される出力**:

```
NAME                           COMMAND       SERVICE   STATUS     PORTS
sf-ai-cli-practice-v2-dev      /bin/bash     dev       running    0.0.0.0:1717->1717/tcp, 0.0.0.0:9229->9229/tcp
```

### Step 6: コンテナに接続

```bash
# コンテナ内のbashシェルに接続
docker-compose exec dev bash

# コンテナ内でSalesforce CLIを確認
sf --version

# コンテナ内でNode.jsを確認
node --version

# 終了
exit
```

---

## 💻 日常的な使い方

### コンテナの起動・停止

```bash
# 起動
docker-compose up -d

# 停止
docker-compose down

# 再起動
docker-compose restart
```

### コンテナ内でコマンド実行

```bash
# 方法1: execで直接実行
docker-compose exec dev sf org list

# 方法2: コンテナ内に入って実行
docker-compose exec dev bash
> sf org list
> exit
```

### ログ確認

```bash
# すべてのログを表示
docker-compose logs

# 特定のサービスのログ
docker-compose logs dev

# リアルタイムでログを監視
docker-compose logs -f dev
```

### コンテナの再ビルド

設定変更後やパッケージ更新時:

```bash
# 停止 → 再ビルド → 起動
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## 🔧 VS Code Dev Container（オプション）

### Dev Container拡張機能

VS Codeで直接コンテナ内で開発できます。

1. VS Code拡張機能「Dev Containers」をインストール
2. コマンドパレット（Cmd+Shift+P）→ "Dev Containers: Open Folder in Container"
3. プロジェクトフォルダを選択

### 設定ファイル

`.devcontainer/devcontainer.json` が既に用意されています。

---

## 🐛 トラブルシューティング

### エラー: "Cannot connect to Docker daemon"

**原因**: Docker Desktopが起動していない

**解決**:
1. Docker Desktopアプリを起動
2. メニューバーのDockerアイコンが緑色になるまで待つ
3. 再度 `docker-compose up -d` を実行

### エラー: "port 1717 already in use"

**原因**: ポート1717が既に使用されている

**解決**:

```bash
# ポート使用状況確認
lsof -i :1717

# プロセスを停止
kill -9 <PID>

# または、docker-compose.ymlのポート番号を変更
# "1718:1717" など
```

### エラー: "no space left on device"

**原因**: Dockerのディスク容量不足

**解決**:

```bash
# 未使用のイメージ・コンテナ・ボリュームを削除
docker system prune -a --volumes

# Docker Desktopの設定でディスク容量を増やす
# Settings → Resources → Disk image size
```

### コンテナが起動しない

**デバッグ方法**:

```bash
# コンテナのログを確認
docker-compose logs dev

# コンテナを強制削除して再作成
docker-compose down -v
docker-compose up -d
```

---

## 📊 Docker環境の確認コマンド

### システム情報

```bash
# Docker情報
docker info

# ディスク使用状況
docker system df
```

### イメージ・コンテナ管理

```bash
# イメージ一覧
docker images

# コンテナ一覧（すべて）
docker ps -a

# ボリューム一覧
docker volume ls
```

---

## 🎯 次のステップ

Docker環境が正常に動作したら:

1. [JWT認証設定](../00-setup/03-jwt-authentication.md)でSalesforce認証
2. [PRワークフローガイド](pr-workflow-guide.md)で開発フロー確認

---

## 🔗 参考リンク

- [Docker公式ドキュメント](https://docs.docker.com/)
- [Docker Compose公式ドキュメント](https://docs.docker.com/compose/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)

---

**最終更新**: 2025-12-12
