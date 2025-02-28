# Dify ワークフロー環境

このリポジトリには、Dify をローカル開発環境で Docker を使用して実行するための設定と、AWS デプロイ用の Infrastructure as Code（IaC）を提供する構成が含まれています。

## 概要

Dify は、AI アプリケーションの構築、デプロイ、運用を迅速に行うための LLMOps プラットフォームです。このセットアップには以下が含まれます

1. Docker Compose を使用したローカル開発環境
2. AWS デプロイ用の Infrastructure as Code（IaC）
3. データベースのバックアップおよび復元スクリプト
4. 環境の分離（開発環境と本番環境）
5. セキュリティのベストプラクティス

## ディレクトリ構成

```
dify-workflow/
├── config/                  # 設定ファイル
│   ├── dev/                 # 開発環境の設定
│   └── prod/                # 本番環境の設定
├── infrastructure/          # Infrastructure as Code
│   └── aws/                 # AWS デプロイ用設定
│       └── terraform/       # AWS 向けの Terraform ファイル
├── scripts/                 # ユーティリティスクリプト
│   └── db/                  # データベース管理スクリプト
├── .env.template            # 環境変数テンプレート
├── docker-compose.yml       # Docker Compose 設定
├── Makefile                 # よく使う操作のショートカット
└── README.md                # このファイル
```

## ローカル開発環境のセットアップ

### 前提条件

- Docker および Docker Compose
- Make（オプション、Makefile コマンドの使用に必要）
- Git

### セットアップ手順

1. このリポジトリをクローン

   ```bash
   git clone https://github.com/yourusername/dify-workflow.git
   cd dify-workflow
   ```

2. 環境をセットアップ

   ```bash
   make setup
   ```

   これにより、テンプレートから .env ファイルが作成されます。このファイルを編集して、API キーを追加し、設定をカスタマイズしてください。

3. サービスを起動

   ```bash
   make start
   ```

   これにより、すべての Dify サービスが Docker コンテナ内で起動します。

4. Dify の Web インターフェースにアクセス 
http://localhost:3000

### よく使う操作

Makefile を使うと、以下のような便利なショートカットが利用できます。

- `make help` - 使用可能なコマンドを表示
- `make start` - すべてのサービスを起動
- `make stop` - すべてのサービスを停止
- `make restart` - すべてのサービスを再起動
- `make logs` - すべてのサービスのログを表示
- `make backup` - データベースをバックアップ
- `make restore file=path/to/backup.sql.gz` - バックアップからデータベースを復元
- `make clean` - すべてのコンテナ、ボリューム、データを削除（破壊的！）

## 環境変数

`.env` ファイルにはすべての設定オプションが含まれています。主な変数は次のとおりです。

- `ENVIRONMENT`：開発環境の場合は `dev`、本番環境の場合は `prod` に設定
- `DIFY_SECRET_KEY`：Dify のシークレットキー
- `POSTGRES_*`：データベースの設定
- `OPENAI_API_KEY`：OpenAI API キー
- `STORAGE_TYPE`：ストレージタイプ（`local` または `s3`）

すべての利用可能なオプションについては `.env.template` ファイルを参照してください。

## データベース管理

### バックアップ

データベースのバックアップを作成するには

```bash
make backup
```

これにより、`backups/db/` ディレクトリにタイムスタンプ付きのバックアップファイルが作成されます。

### 復元

バックアップから復元するには

```bash
make restore file=backups/db/dify_db_backup_20250228_123456.sql.gz
```

## AWS デプロイメント

### 前提条件

- AWS CLIが適切な認証情報で設定されていること
- Terraformがインストールされていること

### デプロイメント手順

1. AWS デプロイメント設定を構成

   ```bash
   make aws-configure
   ```

2. `infrastructure/aws/terraform/terraform.tfvars` ファイルを編集し、AWS設定を行う。

3. AWSにデプロイ

   ```bash
   make aws-deploy
   ```

## セキュリティ上の考慮事項

### APIキー

- APIキーをバージョン管理システムにコミットしないこと
- 機密情報には環境変数を使用すること
- 本番環境では、AWS Secrets Managerなどのサービスの使用を検討すること

### データベースセキュリティ

- データベースアクセスには強力なパスワードを使用すること
- データベースアクセスを必要最小限のサービスに制限すること
- データベースを定期的にバックアップすること

### ネットワークセキュリティ

- 本番環境では、適切なSSL証明書を使用してHTTPSを利用すること
- ファイアウォールを設定し、必要なポートのみにアクセスを制限すること
- データベースやその他の内部サービスには、プライベートサブネットを使用すること

## Dify API 使用例

### 認証

```bash
# APIトークンを取得
curl -X POST http://localhost:5001/v1/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username": "あなたのユーザー名", "password": "あなたのパスワード"}'
```

### ワークフローの作成

```bash
# 新しいワークフローを作成
curl -X POST http://localhost:5001/v1/workflows \
  -H "Authorization: Bearer あなたのAPIトークン" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "マイワークフロー",
    "description": "サンプルワークフロー"
  }'
```

### ワークフローの実行

```bash
# ワークフローを実行
curl -X POST http://localhost:5001/v1/workflows/{ワークフローID}/runs \
  -H "Authorization: Bearer あなたのAPIトークン" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": {
      "キー1": "値1",
      "キー2": "値2"
    }
  }'
```

## AWSへの移行

ローカル開発環境からAWSへ移行する際

1. `.env`ファイルをAWSサービス用に更新
   - `STORAGE_TYPE`を`local`から`s3`に変更
   - S3バケット設定を構成
   - データベース接続設定を更新

2. Terraformでインフラストラクチャをデプロイ

   ```bash
   make aws-deploy
   ```

3. Dockerイメージをコンテナレジストリ（ECRまたはDocker Hub）にプッシュ

4. ECSタスク定義を使用するイメージに更新

5. DNS設定を変更し、AWSリソースを指定

## トラブルシューティング

### よくある問題

- **サービスが起動しない**: `make logs` で Docker ログを確認
- **データベース接続エラー**: `.env` でデータベースの認証情報を確認
- **API エラー**: API ログを確認し、API キーが正しく設定されていることを確認

### ヘルプ

問題が発生した場合

1. ログを確認: `make logs`
2. `.env` の設定を確認
3. [Dify ドキュメント](https://docs.dify.ai/)を参照
# dify-workflow
