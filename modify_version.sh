#!/bin/bash
# Purpose: Update package.json version and name
# Author: @lctech-zeki
# Requirements: package.json, jq
# -------------------------------------------------------------------

# 全局變量
RUN_TEST=false
USE_DATE=false
UPDATE_VERSION=false
RENAME_ONLY=false
UPDATE_CHANGELOG=false

# 格式化輸出函數
function fmt_error() {
    RED='\033[0;31m' # RED
    STD='\033[0m'    # Text Reset
    echo -e "$RED [Error] $* ! $STD" >&2
}

function fmt_info() {
    CYAN='\033[0;36m' # CYAN
    STD='\033[0m'     # Text Reset
    echo -e "$CYAN [Info] $* $STD"
}

function fmt_success() {
    GREEN='\033[0;32m' # GREEN
    STD='\033[0m'      # Text Reset
    echo -e "$GREEN [Success] $* $STD"
}
function fmt_debug() {
    YELLOW='\033[0;33m' # YELLOW
    STD='\033[0m'     # Text Reset
    echo -e "$YELLOW [Debug] $* $STD"
}

# 顯示使用方法
function show_usage() {
    echo "用法: $(basename "$0") [選項]"
    echo ""
    echo "選項:"
    echo "  -t, --test       創建測試環境"
    echo "  -d, --date       使用日期格式更新版本"
    echo "  -v, --version    增加版本號 (預設)"
    echo "  -n, --name       只更新套件名稱"
    echo "  -c, --changelog  產生更新日誌"
    echo "  -h, --help       顯示此幫助信息"
    echo "  --debug        顯示調試信息"
    echo ""
    echo "範例:"
    echo "  $(basename "$0") -t -d          # 創建測試環境並使用日期格式更新版本"
    echo "  $(basename "$0") -v -n          # 更新版本號和套件名稱"
    echo "  $(basename "$0") -c             # 只產生更新日誌"
    echo "  $(basename "$0")                # 預設：增加版本號並更新套件名稱"
}

# 檢查依賴
function check_dependencies() {
    if ! command -v jq &>/dev/null; then
        fmt_error "找不到jq命令，請先安裝"
        exit 1
    fi

    if ! command -v git &>/dev/null && [ "$RENAME_ONLY" = true ]; then
        fmt_error "找不到git命令，無法更新套件名稱"
        exit 1
    fi
}

# 創建測試環境
function setup_test_env() {
    fmt_info "設置測試環境"
    if [ ! -f ./package.json ]; then
        fmt_debug "創建demo package.json..."
        fmt_debug '{"name":"test-package","version":"1.2.3"}' >package.json
        fmt_success "已創建demo package.json"
    else
        fmt_debug "package.json文件已存在"
    fi
}

# 使用增量方式更新版本號
function update_version() {
    fmt_info "更新版本號"
    VERSION_OLD=$(jq -r '.version' package.json)
    # 解析版本號
    MAJOR=$(echo "$VERSION_OLD" | cut -f1 -d"." | cut -f1 -d'"')
    MINOR=$(echo "$VERSION_OLD" | cut -f2 -d"." | cut -f1 -d'"')
    PATCH=$(echo "$VERSION_OLD" | cut -f3 -d"." | cut -f1 -d'"')
    # 增加修訂號
    NEW_PATCH=$((PATCH + 1))
    VERSION_NEW="\"$MAJOR.$MINOR.$NEW_PATCH\""
    fmt_debug "🚀 版本更新: $PATCH > $NEW_PATCH / 新版本: $VERSION_NEW"
    # 更新 package.json
    cat <<<"$(jq ".version=$VERSION_NEW" package.json)" >tmp-package.json && mv tmp-package.json package.json

    # 處理 GitHub Actions 環境變數
    if [ -n "$GITHUB_ACTIONS" ]; then
        fmt_debug "TAG_VERSION=v$(jq -r '.version' <package.json)" >>"$GITHUB_ENV"
        fmt_info "已設置GitHub Actions環境變數"
    fi
}

# 使用日期更新版本號
function update_with_date() {
    fmt_info "使用日期更新版本號"
    # 使用亞洲/上海時區（UTC+8）格式化日期
    VERSION_NEW="\"0.0.$(TZ=Asia/Shanghai date +%Y%m%d)\""
    # 更新 package.json
    cat <<<"$(jq ".version=$VERSION_NEW" package.json)" >tmp-package.json && mv tmp-package.json package.json
    fmt_debug "📅 新版本: $VERSION_NEW"
    # 處理 GitHub Actions 環境變數
    if [ -n "$GITHUB_ACTIONS" ]; then
        echo "TAG_VERSION=v$(jq -r '.version' <package.json)" >>"$GITHUB_ENV"
        fmt_info "已設置GitHub Actions環境變數"
    fi
}

# 更新套件名稱
function rename_package() {
    fmt_info "更新套件名稱"
    # 從git配置獲取倉庫URL
    GIT_URL=$(git config --get remote.origin.url)
    if [ -z "$GIT_URL" ]; then
        fmt_error "無法獲取git倉庫URL，請確保在git倉庫中執行"
        return 1
    fi

    # 提取倉庫名稱
    NAME_NEW=$(echo "$GIT_URL" | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
    fmt_debug "📦 新套件名稱: @$NAME_NEW"
    cat <<<"$(jq '.name="@'"$NAME_NEW"'"' package.json)" >tmp-package.json && mv tmp-package.json package.json
    fmt_success "套件名稱已更新"
    # 返回包名以便其他函數使用
    echo "$NAME_NEW"
}

# 更新變更日誌
function update_changelog() {
    fmt_info "更新變更日誌"
    # 獲取包名
    local pkg_name=${1:-$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')}

    if [ ! -f ./CHANGELOG.md ]; then
        fmt_debug "創建 CHANGELOG.md..."
        echo "# @$pkg_name Changelog" >CHANGELOG.md
        fmt_success "已創建 CHANGELOG.md"
    fi

    if [ -n "$GITHUB_ACTIONS" ]; then
        fmt_debug "📚 更新變更日誌"
        local version
        local date
        version=$(jq -r '.version' package.json)
        date=$(date +"%Y-%m-%d")

        # 確保更新兼容不同系統
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "1s/^/# @$pkg_name Changelog\n\n## v$version - $date\n\n/" CHANGELOG.md
        else
            sed -i "1s/^/# @$pkg_name Changelog\n\n## v$version - $date\n\n/" CHANGELOG.md
        fi
        fmt_success "變更日誌已更新"
    fi
}

# 解析命令行參數
function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
        -t | --test)
            RUN_TEST=true
            shift
            ;;
        -d | --date)
            USE_DATE=true
            shift
            ;;
        -v | --version)
            UPDATE_VERSION=true
            shift
            ;;
        -n | --name)
            RENAME_ONLY=true
            shift
            ;;
        -c | --changelog)
            UPDATE_CHANGELOG=true
            shift
            ;;
        -h | --help)
            show_usage
            exit 0
            ;;
        1) # 兼容舊版參數
            RUN_TEST=true
            USE_DATE=true
            shift
            ;;
        test) # 兼容舊版參數
            RUN_TEST=true
            shift
            ;;
        *)
            fmt_error "未知選項: $1"
            show_usage
            exit 1
            ;;
        esac
    done

    # 設置默認值
    if [ "$UPDATE_VERSION" = false ] && [ "$USE_DATE" = false ] && [ "$RENAME_ONLY" = false ] && [ "$UPDATE_CHANGELOG" = false ]; then
        UPDATE_VERSION=true
    fi
    RENAME_ONLY=true
}

# 主函數
function main() {
    # 解析參數
    parse_arguments "$@"

    # 檢查依賴
    check_dependencies

    # 測試環境設置
    if [ "$RUN_TEST" = true ]; then
        setup_test_env
    fi

    # 檢查package.json是否存在
    if [ ! -f ./package.json ]; then
        fmt_error "需要package.json文件"
        fmt_error "請使用 -t/--test 選項創建測試文件"
        exit 88
    fi

    local pkg_name=""

    # 執行操作
    if [ "$USE_DATE" = true ]; then
        update_with_date
    elif [ "$UPDATE_VERSION" = true ]; then
        update_version
    fi

    if [ "$RENAME_ONLY" = true ]; then
        pkg_name=$(rename_package)
    fi

    if [ "$UPDATE_CHANGELOG" = true ]; then
        update_changelog "$pkg_name"
    fi

    fmt_success "所有操作已完成"
}

# 執行主函數
main "$@"
