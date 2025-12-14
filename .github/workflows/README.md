# Reusable GitHub Actions Workflows

本目錄包含可重複使用的 GitHub Actions 工作流程模板，供 `lctech-tw` 組織內的專案使用。這些模板標準化了建置、測試、部署和安全掃描流程。

## 目錄

- [使用方式](#使用方式)
- [建置工作流程](#建置工作流程)
- [部署工作流程](#部署工作流程)
- [測試工作流程](#測試工作流程)
- [安全工作流程](#安全工作流程)
- [發佈工作流程](#發佈工作流程)
- [通知工作流程](#通知工作流程)
- [編譯工作流程](#編譯工作流程)
- [常見問題](#常見問題)

---

## 使用方式

### 在你的專案中引用工作流程

在你的專案的 `.github/workflows/` 目錄下創建一個工作流程文件：

```yaml
name: Build and Deploy

on:
  push:
    branches: [main, dev]

jobs:
  build:
    uses: lctech-tw/util_scripts/.github/workflows/build.golang.v1.yaml@main
    secrets: inherit
    with:
      APP_NAME: my-app
      APP_DOCKER_REPOSITORIES: asia.gcr.io/my-project
      GCP_PROJECT: my-gcp-project
      ZMODE: dev

  deploy:
    needs: build
    uses: lctech-tw/util_scripts/.github/workflows/deploy.cloudrun.http.v1.yaml@main
    secrets: inherit
    with:
      APP_NAME: my-app
      APP_DOCKER_REPOSITORIES: asia.gcr.io/my-project
      GCP_PROJECT: my-gcp-project
      GCP_CLOUD_RUN_NAME: my-service
      GCP_CLOUD_RUN_REGION: asia-east1
      ZMODE: dev
```

### 必要的 Secrets

你的專案需要設定以下 secrets：

- `GCP_SA_KEY_GITHUB_CI` - GCP 服務帳號金鑰（JSON 格式）
- `GH_APP_CREDENTIALS_TOKEN` - GitHub App 憑證 token
- `FIREBASE_SERVICE_ACCOUNT` - Firebase 服務帳號（僅 Firebase 部署需要）

### 必要的 Variables

- `NOTIFY_SLACK_URL_*` - Slack webhook URLs（通知功能需要）

---

## 建置工作流程

### build.golang.v1.yaml

建置 Go 應用程式並創建 Docker 映像。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `APP_NAME` | ✅ | - | 應用程式名稱 |
| `APP_DOCKER_REPOSITORIES` | ✅ | - | Docker registry URL |
| `GCP_PROJECT` | ✅ | - | GCP 專案 ID |
| `ZMODE` | ❌ | `dev` | 環境模式 (dev/prod/staging) |
| `GO_VERSION` | ❌ | `1.23` | Go 版本 |
| `GO_BUILD_PATH` | ❌ | `./cmd/server` | main.go 路徑 |
| `SERVER_NAME` | ❌ | `server` | 伺服器二進位檔名稱 |
| `DOCKERFILE_PATH` | ❌ | `.github/docker/Dockerfile` | Dockerfile 路徑 |

**功能：**

- 使用 GitHub App 認證私有模組
- 建置 Go 應用程式
- 創建多平台 Docker 映像 (amd64/arm64)
- 自動標記映像：`latest`, `$ZMODE-latest`, `$ZMODE-$RUN_NUMBER`, `$SHA`

**使用範例：**

```yaml
jobs:
  build:
    uses: lctech-tw/util_scripts/.github/workflows/build.golang.v1.yaml@main
    secrets: inherit
    with:
      APP_NAME: my-go-app
      APP_DOCKER_REPOSITORIES: asia.gcr.io/my-project
      GCP_PROJECT: my-gcp-project
      GO_VERSION: "1.23"
      GO_BUILD_PATH: "./cmd/api"
```

---

### build.node.v1.yaml

建置 Node.js/TypeScript 應用程式並創建 Docker 映像。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `APP_NAME` | ✅ | - | 應用程式名稱 |
| `APP_DOCKER_REPOSITORIES` | ✅ | - | Docker registry URL |
| `GCP_PROJECT` | ✅ | - | GCP 專案 ID |
| `ZMODE` | ❌ | `dev` | 環境模式 |
| `NODE_RUN_SCRIPT` | ❌ | `build` | 建置腳本名稱 |

**功能：**

- 使用 pnpm 安裝依賴
- 配置 GitHub npm registry 認證
- 執行自訂建置腳本
- 創建並推送 Docker 映像

**使用範例：**

```yaml
jobs:
  build:
    uses: lctech-tw/util_scripts/.github/workflows/build.node.v1.yaml@main
    secrets: inherit
    with:
      APP_NAME: my-web-app
      APP_DOCKER_REPOSITORIES: asia.gcr.io/my-project
      GCP_PROJECT: my-gcp-project
      NODE_RUN_SCRIPT: build:prod
```

---

### build.python.v1.yaml

建置 Python 應用程式並創建 Docker 映像。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `APP_NAME` | ✅ | - | 應用程式名稱 |
| `APP_DOCKER_REPOSITORIES` | ✅ | - | Docker registry URL |
| `GCP_PROJECT` | ✅ | - | GCP 專案 ID |
| `ZMODE` | ❌ | `dev` | 環境模式 |
| `PYTHON_VERSION` | ❌ | `3.11` | Python 版本 |
| `REQUIREMENTS_FILE` | ❌ | `requirements.txt` | 依賴文件路徑 |
| `DOCKERFILE_PATH` | ❌ | `.github/docker/Dockerfile` | Dockerfile 路徑 |

**功能：**

- 設定 Python 環境
- 安裝依賴並執行測試
- 運行 flake8 和 pytest（如果可用）
- 創建多平台 Docker 映像

---

## 部署工作流程

### deploy.cloudrun.http.v1.yaml

部署 HTTP 服務到 Google Cloud Run。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `APP_NAME` | ✅ | - | 應用程式名稱 |
| `APP_DOCKER_REPOSITORIES` | ✅ | - | Docker registry URL |
| `GCP_PROJECT` | ✅ | - | GCP 專案 ID |
| `GCP_CLOUD_RUN_NAME` | ✅ | - | Cloud Run 服務名稱 |
| `GCP_CLOUD_RUN_REGION` | ✅ | - | Cloud Run 區域 |
| `ZMODE` | ❌ | `dev` | 環境模式 |
| `GCP_CLOUD_RUN_PORT` | ❌ | `8080` | 服務埠號 |
| `GCP_CLOUD_RUN_VPC` | ❌ | - | VPC connector |
| `GCP_CLOUD_RUN_CPU` | ❌ | `1` | CPU 配置 |
| `GCP_CLOUD_RUN_MEM` | ❌ | `1Gi` | 記憶體配置 |
| `GCP_CLOUD_RUN_SIZE_MIN` | ❌ | `1` | 最小實例數 |
| `GCP_CLOUD_RUN_SIZE_MAX` | ❌ | `3` | 最大實例數 |
| `GCP_CLOUD_RUN_INGRESS_TYPE` | ❌ | `internal-and-cloud-load-balancing` | Ingress 類型 |
| `GCP_CLOUD_RUN_CONFIG_FILE_PATH` | ❌ | - | 環境變數檔案路徑 |

**使用範例：**

```yaml
jobs:
  deploy:
    uses: lctech-tw/util_scripts/.github/workflows/deploy.cloudrun.http.v1.yaml@main
    secrets: inherit
    with:
      APP_NAME: my-api
      APP_DOCKER_REPOSITORIES: asia.gcr.io/my-project
      GCP_PROJECT: my-gcp-project
      GCP_CLOUD_RUN_NAME: my-api
      GCP_CLOUD_RUN_REGION: asia-east1
      GCP_CLOUD_RUN_VPC: my-vpc-connector
      GCP_CLOUD_RUN_CPU: "2"
      GCP_CLOUD_RUN_MEM: "2Gi"
      GCP_CLOUD_RUN_CONFIG_FILE_PATH: .github/config
```

---

### deploy.cloudrun.job.v1.yaml

部署批次任務到 Google Cloud Run Jobs。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| 基本參數同 HTTP 部署 | - | - | - |
| `GCP_CLOUD_RUN_TASKS_NUM` | ❌ | `1` | 任務數量 |
| `GCP_CLOUD_RUN_TASK_TIMEOUT` | ❌ | `10s` | 任務超時時間 |
| `GCP_CLOUD_RUN_TASK_RETRIES` | ❌ | `0` | 重試次數 |
| `GCP_CLOUD_RUN_TASKS_PARALLELISM` | ❌ | `1` | 並行任務數 |
| `GCP_CLOUD_COMMAND` | ❌ | - | 覆寫容器命令 |
| `GCP_CLOUD_RUN_SA` | ❌ | - | 服務帳號 |

---

### deploy.cloudrun.canary.v1.yaml

金絲雀部署到 Cloud Run（漸進式流量切換）。

**功能：**

- 部署新版本但不接收流量（標記為 `canary`）
- 將可配置百分比的流量導向金絲雀版本
- 需要手動批准才能將金絲雀提升為穩定版本
- 適合 A/B 測試和漸進式推出

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| 基本參數同 HTTP 部署 | - | - | - |
| `CANARY_TRAFFIC_PERCENT` | ❌ | `10` | 金絲雀流量百分比 (0-100) |

**使用範例：**

```yaml
jobs:
  canary-deploy:
    uses: lctech-tw/util_scripts/.github/workflows/deploy.cloudrun.canary.v1.yaml@main
    secrets: inherit
    with:
      APP_NAME: my-api
      GCP_PROJECT: my-gcp-project
      GCP_CLOUD_RUN_NAME: my-api
      GCP_CLOUD_RUN_REGION: asia-east1
      CANARY_TRAFFIC_PERCENT: "20"
```

---

### deploy.firebase.v1.yaml

部署到 Firebase Hosting。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `FIREBASE_PROJECT` | ✅ | - | Firebase 專案 ID |
| `ZMODE` | ❌ | `dev` | 環境模式 |
| `FIREBASE_HOSTING_CHANNEL` | ❌ | `live` | Hosting 頻道 |
| `BUILD_SCRIPT` | ❌ | `build` | NPM 建置腳本 |
| `BUILD_OUTPUT_DIR` | ❌ | `dist` | 建置輸出目錄 |
| `USE_PNPM` | ❌ | `true` | 使用 pnpm |

---

### deploy.golang.v1.yaml

部署到 Google Kubernetes Engine (GKE)。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `GCP_PROJECT` | ✅ | - | GCP 專案 ID |
| `GCP_GKE_NAME` | ✅ | - | GKE 集群名稱 |
| `GCP_GKE_ZONE` | ✅ | - | GKE 區域 |
| `K8S_PATH` | ❌ | `.github/k8s` | Kubernetes 配置路徑 |
| `ZMODE` | ❌ | `dev` | 環境模式 |

**功能：**

- 使用 kustomize 管理 Kubernetes 配置
- 使用 yq 更新映像標籤
- 應用配置到 GKE 集群

---

## 測試工作流程

### testing.golang.v1.yaml

Go 應用程式測試與覆蓋率檢查。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `DB_TABLE_NAME` | ✅ | - | 資料庫名稱 |
| `GO_BUILD_PATH` | ❌ | `./cmd/server/` | main.go 路徑 |
| `PRE_TEST_SCRIPT_PATH` | ❌ | `./.github/testing` | 測試前腳本路徑 |
| `PRE_TEST_SCRIPT_FILE` | ❌ | `psql-init.sh` | 測試前腳本檔名 |
| `TEST_COVERAGE_PATH` | ✅ | `./transport/...,./internal/service,./internal/repo` | 覆蓋率檢測路徑 |
| `TEST_MAIN_PATH` | ✅ | `./test/integration` | 測試主路徑 |
| `TEST_COVERAGE_THRESHOLD` | ❌ | `70` | 覆蓋率門檻 (%) |

**功能：**

- 執行 gosec 安全掃描
- 啟動 PostgreSQL 和 Redis 容器
- 運行整合測試
- 強制執行覆蓋率門檻（低於門檻則失敗）

**使用範例：**

```yaml
jobs:
  test:
    uses: lctech-tw/util_scripts/.github/workflows/testing.golang.v1.yaml@main
    secrets: inherit
    with:
      DB_TABLE_NAME: test_db
      TEST_COVERAGE_PATH: "./pkg/...,./internal/..."
      TEST_MAIN_PATH: "./test/..."
      TEST_COVERAGE_THRESHOLD: 80
```

---

### testing.node.v1.yaml

Node.js/TypeScript 測試與覆蓋率檢查。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `NODE_VERSION` | ❌ | - | Node.js 版本（空則使用 .nvmrc） |
| `TEST_SCRIPT` | ❌ | `test` | 測試腳本名稱 |
| `LINT_SCRIPT` | ❌ | `lint` | Lint 腳本名稱 |
| `COVERAGE_THRESHOLD` | ❌ | `80` | 覆蓋率門檻 (%) |
| `USE_PNPM` | ❌ | `true` | 使用 pnpm |

**功能：**

- 分別執行 lint 和 test 任務
- 運行覆蓋率檢查（假設使用 Jest）
- 上傳覆蓋率報告為 artifacts
- 低於門檻則失敗

---

## 安全工作流程

### security.scan.v1.yaml

多語言安全掃描工作流程。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `SCAN_TYPE` | ❌ | `all` | 掃描類型：go/node/python/docker/all |
| `FAIL_ON_SEVERITY` | ❌ | `HIGH` | 失敗嚴重等級：CRITICAL/HIGH/MEDIUM/LOW |
| `DOCKER_IMAGE` | ❌ | - | Docker 映像（docker 掃描需要） |

**掃描項目：**

1. **依賴掃描** - Trivy 文件系統掃描
2. **Go 安全** - gosec 掃描 Go 程式碼
3. **Node.js 安全** - npm audit 掃描依賴
4. **Docker 映像掃描** - Trivy 掃描容器映像
5. **秘密掃描** - Gitleaks 掃描暴露的秘密

**使用範例：**

```yaml
jobs:
  security:
    uses: lctech-tw/util_scripts/.github/workflows/security.scan.v1.yaml@main
    secrets: inherit
    with:
      SCAN_TYPE: all
      FAIL_ON_SEVERITY: HIGH
      DOCKER_IMAGE: asia.gcr.io/my-project/my-app:latest
```

---

## 發佈工作流程

### release.version.v1.yaml

自動化版本升級與發佈。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `VERSION_TYPE` | ❌ | `patch` | 版本類型：major/minor/patch |
| `CREATE_RELEASE` | ❌ | `true` | 創建 GitHub release |
| `UPDATE_CHANGELOG` | ❌ | `true` | 更新 CHANGELOG |
| `RELEASE_BRANCH` | ❌ | `main` | 發佈分支 |

**功能：**

- 自動升級 package.json 版本
- 從 git commits 生成 changelog
- 創建 git tag 並推送
- 創建 GitHub release（附自動生成的 release notes）

**使用範例：**

```yaml
jobs:
  release:
    uses: lctech-tw/util_scripts/.github/workflows/release.version.v1.yaml@main
    secrets: inherit
    with:
      VERSION_TYPE: minor
      CREATE_RELEASE: true
      UPDATE_CHANGELOG: true
```

---

## 通知工作流程

### notify.v1.yaml

Slack 通知工作流程。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `CI_STATUS` | ✅ | - | CI 狀態：success/failure/skipped/cancelled |
| `GROUP` | ❌ | `jkf` | Slack 群組：jkf/jvid/jkface/alola/skip |
| `TAG_USER` | ❌ | - | 強制標記使用者 |

**支援的群組：**

- `jkf` / `rdc02` - AVPLUS 團隊
- `jvid` / `rdc03` - JVID 團隊
- `jkface` / `rdc04` - JKFace 團隊
- `alola` - Alola 團隊
- `skip` - 跳過通知

**使用範例：**

```yaml
jobs:
  notify:
    if: always()
    needs: [build, test, deploy]
    uses: lctech-tw/util_scripts/.github/workflows/notify.v1.yaml@main
    secrets: inherit
    with:
      CI_STATUS: ${{ job.status }}
      GROUP: jvid
```

---

## 編譯工作流程

### compile.v1.yaml

Protocol Buffer 編譯工作流程。

**輸入參數：**

| 參數 | 必填 | 預設值 | 說明 |
|------|------|--------|------|
| `stable-mode` | ❌ | `true` | Markdown 格式 |
| `compile-mode` | ❌ | `neo` | 編譯模式：neo/Multi/v3/v4/old |
| `buf-build` | ❌ | `false` | 執行 buf build |
| `buf-format` | ❌ | `false` | 執行 buf format |
| `buf-lint` | ❌ | `false` | 執行 buf lint |
| `buf-breaking` | ❌ | `false` | 執行 buf breaking |

**功能：**

- 自動升級版本號
- 編譯 protobuf 檔案
- 發佈到 GitHub npm registry
- 創建 git tag

---

## 常見問題

### Q: 如何在本地測試工作流程？

A: 使用 [act](https://github.com/nektos/act) 工具：

```bash
# 安裝 act
brew install act

# 運行工作流程
act -W .github/workflows/your-workflow.yaml
```

### Q: 如何更新到最新版本的工作流程？

A: 將引用從 `@main` 改為特定版本標籤，或保持 `@main` 自動使用最新版本：

```yaml
uses: lctech-tw/util_scripts/.github/workflows/build.golang.v1.yaml@v1.0.0
```

### Q: 如何自訂 Docker 映像標籤？

A: 所有建置工作流程使用標準標籤策略：

- `latest` - 最新建置
- `$ZMODE-latest` - 環境的最新版本
- `$ZMODE-$RUN_NUMBER` - 環境 + 建置編號
- `$SHA` - Git commit SHA

### Q: 如何設定多環境部署？

A: 使用 GitHub Environments 和環境特定的配置檔案：

```yaml
jobs:
  deploy-dev:
    uses: lctech-tw/util_scripts/.github/workflows/deploy.cloudrun.http.v1.yaml@main
    with:
      ZMODE: dev
      GCP_CLOUD_RUN_CONFIG_FILE_PATH: .github/config

  deploy-prod:
    needs: deploy-dev
    environment: production
    uses: lctech-tw/util_scripts/.github/workflows/deploy.cloudrun.http.v1.yaml@main
    with:
      ZMODE: prod
      GCP_CLOUD_RUN_CONFIG_FILE_PATH: .github/config
```

配置檔案結構：

```tree
.github/
└── config/
    ├── dev.yaml
    └── prod.yaml
```

### Q: 如何處理私有依賴？

A: 所有工作流程都配置了 GitHub App 認證，自動處理私有 npm 包和 Go 模組：

```yaml
# 自動配置
git config --global url."https://oauth2:$TOKEN@github.com/lctech-tw".insteadOf "https://github.com/lctech-tw"
```

### Q: 金絲雀部署如何推廣到生產環境？

A: 金絲雀部署分為兩個階段：

1. **自動部署金絲雀**：部署新版本並路由少量流量
2. **手動推廣**：需要在 GitHub Actions 中手動批准 `production-promote` environment

---

## 貢獻指南

### 新增工作流程

1. 遵循現有命名規範：`<category>.<name>.v<version>.yaml`
2. 使用 `workflow_call` 觸發器
3. 詳細記錄所有輸入參數
4. 提供使用範例
5. 更新此 README

### 版本控制

- 主要變更（破壞性更改）：遞增版本號（如 v1 → v2）
- 次要變更（新功能）：更新文檔
- 修復（bug fixes）：直接更新現有版本

---

## 聯絡方式

如有問題或建議，請在 [GitHub Issues](https://github.com/lctech-tw/util_scripts/issues) 中提出。
