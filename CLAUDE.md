# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains a collection of utility scripts and reusable GitHub Actions workflows designed for CI/CD pipelines. These utilities are used across multiple projects in the `lctech-tw` organization and are designed to be remotely invoked via `curl` or referenced as reusable workflows.

## Key Utilities

### Shell Scripts

**notify_slack.sh** - Slack and Google Chat notification tool
- Posts build status notifications to Slack channels and Google Chat
- Usage: `./notify_slack.sh [-s|-f|-a|-c|-q] [-g=GROUP] [-p=PROJECT] [--tag=USERS]`
- Modes: `-s` (success), `-f` (failure), `-a` (A/B test), `-c` (check), `-q` (quiet)
- Supports multiple Slack groups: `jkf`, `jvid`, `rdc02`, `rdc03`, `rdc04`, `jkface`, `alola`
- Requires GCP authentication to fetch webhook URLs from Google Secret Manager
- Maps GitHub usernames to Slack user IDs via `nametable.sh`

**modify_version.sh** - Package.json version and name updater
- Usage: `./modify_version.sh [-v|-d] [-n] [-c] [-t]`
- Options: `-v` (increment version), `-d` (use date format), `-n` (rename package), `-c` (update changelog)
- Auto-detects repository name from git config and updates `package.json` name to `@org/repo` format
- Sets `TAG_VERSION` environment variable for GitHub Actions

**yq.sh** - YAML manipulation wrapper
- Wrapper around the `yq` tool for parsing and editing YAML files
- Usage: `cat file.yaml | bash yq.sh e '.path.to.key' -`

**scan.sh** - Security audit tool
- Runs security scans on codebases
- Usage: `sh scan.sh --type go`

### Proto Compilation Scripts

Located in `proto/` directory:

**compile.sh** - Main protocol buffer compilation orchestrator
- Supports multiple compilation modes via `COMPILE_MODE` environment variable:
  - Default/`neo`: Uses Buf CLI for modern protobuf compilation
  - `Multi`/`multi`/`MULTI`: Multi-file compilation (build-protoc2.sh)
  - `v3`: Version 3 compilation (build-protoc3.sh)
  - `v4`: Version 4 compilation (build-protoc4.sh)
  - `old`: Legacy compilation (build-protoc.sh)
- Auto-detects `GITHUB_REPOSITORY` from git config if not set
- Manages `go.mod` initialization for Go projects
- Uses Docker-based proto-compiler images from `asia.gcr.io/lc-shared-res/proto-compiler`

**build-protoc*.sh** - Various protobuf compilation implementations
- Different versions support different proto compilation strategies
- Used by `compile.sh` based on `COMPILE_MODE`

**buf.yaml** & **buf.gen.yaml** - Buf configuration files for modern proto compilation

## Reusable GitHub Actions Workflows

All workflows are located in `.github/workflows/` and designed to be called via `workflow_call`.

### Build Workflows

**build.golang.v1.yaml** - Go application build and Docker image creation
- Inputs: `APP_NAME`, `APP_DOCKER_REPOSITORIES`, `GCP_PROJECT`, `ZMODE`, `GO_VERSION`, `GO_BUILD_PATH`, `SERVER_NAME`, `DOCKERFILE_PATH`
- Authenticates to GitHub packages via GitHub App token
- Configures private Go module access for `github.com/lctech-tw/*`
- Builds Go binary, creates multi-platform Docker images (linux/amd64, linux/arm64)
- Tags images with: `latest`, `$ZMODE-latest`, `$ZMODE-$RUN_NUMBER`, `$SHA`, `$BRANCH-$RUN_NUMBER`

**build.node.v1.yaml** (build.web.v1) - Node.js application build
- Uses pnpm for package management
- Authenticates to GitHub npm registry
- Configures `.npmrc` for `@lctech-tw` scope packages
- Runs custom build script via `NODE_RUN_SCRIPT` input (default: `build`)
- Creates and pushes Docker images

**build.av.nuxt.v1.yaml** - Nuxt.js application build (similar to Node.js workflow)

**build.python.v1.yaml** - Python application build and Docker image creation
- Inputs: `APP_NAME`, `APP_DOCKER_REPOSITORIES`, `GCP_PROJECT`, `ZMODE`, `PYTHON_VERSION`, `REQUIREMENTS_FILE`, `DOCKERFILE_PATH`
- Sets up Python environment and installs dependencies
- Runs linting (flake8) and tests (pytest) if available
- Creates multi-platform Docker images (linux/amd64, linux/arm64)
- Same tagging strategy as other build workflows

### Deployment Workflows

**deploy.cloudrun.http.v1.yaml** - Deploy HTTP service to Google Cloud Run
- Inputs: `GCP_CLOUD_RUN_NAME`, `GCP_CLOUD_RUN_REGION`, `GCP_CLOUD_RUN_PORT` (default: 8080), `GCP_CLOUD_RUN_VPC`, `GCP_CLOUD_RUN_CPU/MEM`, `GCP_CLOUD_RUN_SIZE_MIN/MAX`, `GCP_CLOUD_RUN_INGRESS_TYPE`
- Supports optional environment variable files: `$GCP_CLOUD_RUN_CONFIG_FILE_PATH/$ZMODE.yaml`
- Deploys with `--allow-unauthenticated` flag
- Service name format: `$GCP_CLOUD_RUN_NAME-http`

**deploy.cloudrun.grpc.v1.yaml** - Deploy gRPC service to Google Cloud Run
- Similar to HTTP deployment but configured for gRPC

**deploy.cloudrun.job.v1.yaml** - Deploy Cloud Run Job
- Additional inputs: `GCP_CLOUD_RUN_TASKS_NUM`, `GCP_CLOUD_RUN_TASK_TIMEOUT`, `GCP_CLOUD_RUN_TASK_RETRIES`, `GCP_CLOUD_RUN_TASKS_PARALLELISM`, `GCP_CLOUD_COMMAND`
- Reads env vars from `./.github/config/$ZMODE.yaml`
- Service name format: `$GCP_CLOUD_RUN_NAME-job`

**deploy.gcs.node.v1.yaml** - Deploy Node.js build artifacts to Google Cloud Storage

**deploy.golang.v1.yaml** - Deploy to GKE (Google Kubernetes Engine)
- Inputs: `K8S_PATH`, `GCP_PROJECT`, `GCP_GKE_NAME`, `GCP_GKE_ZONE`, `ZMODE`
- Uses kustomize for Kubernetes manifests
- Updates image tags in kustomization.yaml using yq
- Applies configurations to GKE cluster

**deploy.firebase.v1.yaml** - Deploy to Firebase Hosting
- Inputs: `FIREBASE_PROJECT`, `ZMODE`, `FIREBASE_HOSTING_CHANNEL`, `BUILD_SCRIPT`, `BUILD_OUTPUT_DIR`, `USE_PNPM`
- Builds web application and deploys to Firebase Hosting
- Supports channel-based deployments (live, preview)
- Environment-specific configurations via `.env.$ZMODE`

**deploy.cloudrun.canary.v1.yaml** - Canary deployment to Cloud Run
- Two-stage deployment: canary deployment + optional promotion
- Deploys new revision with tag `canary` and no initial traffic
- Routes configurable percentage of traffic to canary (default: 10%)
- Manual approval step to promote canary to stable (100% traffic)
- Useful for gradual rollouts and A/B testing

### Testing Workflows

**testing.golang.v1.yaml** - Go application testing with coverage
- Inputs: `DB_TABLE_NAME`, `GO_BUILD_PATH`, `PRE_TEST_SCRIPT_PATH/FILE`, `TEST_COVERAGE_PATH`, `TEST_MAIN_PATH`, `TEST_COVERAGE_THRESHOLD`
- Runs `gosec` security scanner
- Spins up PostgreSQL and Redis containers for integration tests
- Enforces test coverage threshold (default: 70%)
- Fails build if coverage is below threshold

**testing.node.v1.yaml** - Node.js/TypeScript testing with coverage
- Two separate jobs: linting and testing
- Inputs: `NODE_VERSION`, `TEST_SCRIPT`, `LINT_SCRIPT`, `COVERAGE_THRESHOLD`, `USE_PNPM`
- Runs ESLint/linting tools
- Executes tests with coverage reporting (assumes Jest or similar)
- Checks coverage against threshold (default: 80%)
- Uploads coverage reports as artifacts

### Security Workflows

**security.scan.v1.yaml** - Multi-language security scanning
- Inputs: `SCAN_TYPE` (go/node/python/docker/all), `FAIL_ON_SEVERITY`, `DOCKER_IMAGE`
- Multiple scan jobs:
  - **Dependency scan**: Trivy filesystem scanner for vulnerabilities
  - **Go security**: gosec for Go code security issues
  - **Node.js security**: npm audit for npm dependencies
  - **Docker image scan**: Trivy for container image vulnerabilities
  - **Secret scan**: Gitleaks for exposed secrets in git history
- Uploads results to GitHub Security tab (SARIF format)
- Configurable severity threshold for build failures

### Release Workflows

**release.version.v1.yaml** - Automated version bumping and release
- Inputs: `VERSION_TYPE` (major/minor/patch), `CREATE_RELEASE`, `UPDATE_CHANGELOG`, `RELEASE_BRANCH`
- Automatically bumps version in package.json
- Generates changelog from git commits
- Creates git tag and pushes to repository
- Optionally creates GitHub release with auto-generated release notes
- Uses modify_version.sh and changelog.sh utilities

### Utility Workflows

**compile.v1.yaml** - Protocol buffer compilation workflow
- Inputs: `stable-mode`, `compile-mode`, `buf-build`, `buf-format`, `buf-lint`, `buf-breaking`
- Auto-increments package.json version
- Renames package to `@org/repo` format
- Uses `lctech-tw/protobuf-codegen-action@main` custom action
- Publishes to GitHub npm registry
- Creates git tags with version

**notify.v1.yaml** - Slack notification workflow
- Inputs: `CI_STATUS` (success/failure/skipped/cancelled), `GROUP` (slack group), `TAG_USER`
- Fetches Slack webhook URLs from GitHub variables (`NOTIFY_SLACK_URL_*`)
- Supports multiple notification groups with different icons and error contacts
- Uses `nametable.sh` to map GitHub usernames to Slack user IDs

## Common Patterns

### GitHub App Authentication
All workflows use a custom GitHub App for authentication to access private repositories:
```bash
TOKEN=$(npx obtain-github-app-installation-access-token ci ${{secrets.GH_APP_CREDENTIALS_TOKEN}})
git config --global url."https://oauth2:$GITHUB_TOKEN@github.com/lctech-tw".insteadOf "https://github.com/lctech-tw"
```

### GCP Authentication
Workflows authenticate to GCP using a service account key stored in secrets:
```yaml
uses: google-github-actions/auth@v2
with:
  credentials_json: ${{secrets.GCP_SA_KEY_GITHUB_CI}}
```

### Docker Image Tagging Strategy
Multi-tag strategy for versioning:
- `latest` - Latest build
- `$SHA` - Git commit SHA
- `$ZMODE-latest` - Latest for environment (dev/prod)
- `$ZMODE-$RUN_NUMBER` - Environment + build number
- `$BRANCH-$RUN_NUMBER` - Branch + build number

### Remote Script Usage
Scripts can be used directly from GitHub:
```bash
# Direct execution
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/util_scripts/main/notify_slack.sh)"

# Download then execute
curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/notify_slack.sh
./notify_slack.sh -s
```

## Environment Variables

**Required for GitHub Actions context:**
- `GITHUB_REPOSITORY` - Auto-set by GitHub Actions, or derived from git config
- `GITHUB_ACTOR` - GitHub username triggering the action
- `GITHUB_RUN_NUMBER` - Build number
- `GITHUB_WORKFLOW` - Workflow name
- `GITHUB_EVENT_NAME` - Event type (push/pull_request)

**Common custom inputs:**
- `ZMODE` - Deployment environment (dev/prod/staging)
- `COMPILE_MODE` - Proto compilation mode (neo/Multi/v3/v4/old)
- `APP_NAME` - Application identifier
- `APP_DOCKER_REPOSITORIES` - Docker registry URL
- `GCP_PROJECT` - Google Cloud project ID

## Secret Management

Secrets are stored in:
1. GitHub repository secrets (`secrets.*`)
   - `GCP_SA_KEY_GITHUB_CI` - GCP service account key
   - `GH_APP_CREDENTIALS_TOKEN` - GitHub App credentials
2. GitHub repository variables (`vars.*`)
   - `NOTIFY_SLACK_URL_*` - Slack webhook URLs
3. Google Cloud Secret Manager (accessed at runtime via `gcloud secrets`)
   - `cicd_chat_url` - Google Chat webhook
   - `slack_url*` - Slack webhooks for different groups

## Development Workflow

When modifying workflows or scripts:
1. Test changes locally where possible
2. For workflows, test with a sample repository that calls the reusable workflow
3. Scripts should maintain backward compatibility as they're used across many projects
4. Update version in `package.json` when making changes
5. Consider whether changes affect existing consumers
