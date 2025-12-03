# GitHub リポジトリ設定ガイド

**作成日**: 2025-12-03  
**対象**: sf-ai-cli-practice-v2

---

## 🎯 目的

個人開発であっても、品質とセキュリティを担保するため、適切なGitHub設定を行います。

---

## 🔒 ブランチ保護ルール設定

### なぜブランチ保護が必要か

**個人開発でも重要な理由:**

1. **品質保証**: CI/CDチェックを必須化
2. **CodeRabbitレビュー**: AIレビューを必ず受ける
3. **セキュリティ**: 誤った直接pushを防ぐ
4. **履歴管理**: すべての変更がPRで記録される
5. **チーム移行**: 将来のチーム開発への準備

### 設定手順

#### Step 1: GitHubリポジトリにアクセス

```
https://github.com/<your-username>/sf-ai-cli-practice-v2
```

#### Step 2: ブランチ保護ルール設定

1. **Settings** タブをクリック
2. 左サイドバーから **Branches** を選択
3. **Add branch protection rule** をクリック

#### Step 3: 保護ルール設定

**Branch name pattern:**
```
main
```

**必須設定（個人開発）:**

- ✅ **Require a pull request before merging**
  - ✅ **Require approvals**: 0（個人開発のため）
  - ⚠️ **Dismiss stale pull request approvals when new commits are pushed**: OFF（個人開発）
  
- ✅ **Require status checks to pass before merging**
  - ✅ **Require branches to be up to date before merging**
  - 必須ステータスチェック:
    - `Security Scan / secrets-scan`
    - `PR Validation / file-count-check`
    - `PR Validation / validate`
  
- ⚠️ **Require conversation resolution before merging**: OFF（個人開発）

- ✅ **Require signed commits**: OFF（個人開発では不要）

- ✅ **Require linear history**: ON（推奨）
  - Squash mergeで履歴を綺麗に保つ

- ❌ **Require deployments to succeed before merging**: OFF

- ✅ **Lock branch**: OFF

- ✅ **Do not allow bypassing the above settings**: ON（重要！）
  - 管理者でもルールを守る

- ⚠️ **Restrict who can push to matching branches**: OFF（個人開発）

#### Step 4: デフォルトブランチ設定（オプション）

**開発ブランチを使う場合:**

1. **Settings > Branches**
2. **Default branch** セクション
3. `develop` ブランチを作成してデフォルトに設定
4. `main` ブランチは本番用として保護

**シンプルな場合（推奨）:**

- `main` ブランチのみ
- feature ブランチから直接PRを作成

---

## 🔐 セキュリティ設定

### Step 1: Secret Scanning有効化

1. **Settings > Code security and analysis**
2. **Secret scanning** を有効化
   - ✅ Enable (Public repositoryは無料)
   - ✅ Push protection（推奨）

### Step 2: Dependabot有効化

1. **Settings > Code security and analysis**
2. **Dependabot alerts** を有効化
3. **Dependabot security updates** を有効化
4. **Dependabot version updates** を有効化（オプション）

### Step 3: Code Scanning（GitHub Advanced Security）

**Note**: Private repositoryでは有料

Public repositoryの場合:
1. **Security > Code scanning**
2. **Set up code scanning**
3. **CodeQL Analysis** を設定

---

## 📋 リポジトリ設定のベストプラクティス

### General設定

1. **Settings > General**
2. **Features**:
   - ✅ Issues
   - ✅ Projects
   - ⚠️ Discussions: OFF（個人開発では不要）
   - ⚠️ Sponsorships: OFF
   
3. **Pull Requests**:
   - ✅ Allow squash merging（推奨）
   - ⚠️ Allow merge commits: OFF
   - ⚠️ Allow rebase merging: OFF
   - ✅ Always suggest updating pull request branches
   - ✅ Allow auto-merge
   - ✅ Automatically delete head branches（PR merge後）

### Actions設定

1. **Settings > Actions > General**
2. **Actions permissions**:
   - ✅ Allow all actions and reusable workflows
   
3. **Workflow permissions**:
   - ✅ Read and write permissions
   - ✅ Allow GitHub Actions to create and approve pull requests

---

## 🔔 通知設定（オプション）

個人開発での推奨設定:

1. **Settings > Notifications**
2. **Email notifications**:
   - ✅ Pull requests
   - ✅ Issues
   - ✅ GitHub Actions
   - ✅ Dependabot alerts

---

## 📱 GitHub Mobile（オプション）

- **GitHub Mobile App**をインストール
- PR通知をモバイルで受け取る
- 外出先でもCodeRabbitレビューを確認

---

## ✅ 設定完了チェックリスト

### 必須設定

- [ ] ブランチ保護ルール（main）設定完了
- [ ] PR before merge必須化
- [ ] ステータスチェック必須化
- [ ] Secret scanning有効化
- [ ] Dependabot alerts有効化

### 推奨設定

- [ ] Linear history有効化
- [ ] Squash merge only設定
- [ ] Auto-delete head branches設定
- [ ] Dependabot security updates有効化
- [ ] 通知設定

### オプション設定

- [ ] Code scanning設定（Public repositoryの場合）
- [ ] GitHub Mobile設定
- [ ] developブランチ作成（必要な場合）

---

## 🚀 設定後の確認

### 1. ブランチ保護テスト

```bash
# mainブランチに直接pushを試みる（失敗するはず）
git checkout main
echo "test" >> test.txt
git add test.txt
git commit -m "test"
git push origin main

# エラーメッセージが表示されればOK:
# ! [remote rejected] main -> main (protected branch hook declined)
```

### 2. PRワークフローテスト

```bash
# featureブランチ作成
git checkout -b feature/test-branch-protection

# 変更を追加
echo "# Test" >> test.txt
git add test.txt
git commit -m "test: ブランチ保護テスト"

# featureブランチをpush
git push origin feature/test-branch-protection

# GitHubでPR作成
# → CI/CDが自動実行されることを確認
# → CodeRabbitがレビューすることを確認
# → Squash mergeできることを確認
```

---

## 📚 参考リンク

- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Security Features](https://docs.github.com/en/code-security)
- [Dependabot](https://docs.github.com/en/code-security/dependabot)

---

**設定完了後**: [PRワークフローガイド](pr-workflow-guide.md)を確認してください。
