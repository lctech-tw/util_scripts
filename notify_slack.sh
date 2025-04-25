#!/bin/bash
# Purpose: Post slack notify
# Author: @lctech-zeki
# Requirments: Bash v3.x+ and curl running on Linux/Unix-like systems
# -------------------------------------------------------------------

#* Need gcp auth

#* declare
# func 0 -> Nothing / 1 -> Do / < 1 -> close
declare MODE_COUNT=0
# test mode
declare TEST_MODE=false
# msg tag user
declare TAG=""
# setting icon
declare ICON=""
# setting CI_SERVER_NAME
declare CI_SERVER_NAME="GitHub Actions"
# setting PROJECT
declare PROJECT=""

# 顯示幫助資訊
show_help() {
  cat >&2 <<"EOF"
Description:
  此腳本用於根據各種條件和模式向 Slack 和 Google Chat 發送通知。
  最初改編自 Jenkins tesk3.sh 腳本。
USAGE:
  shell.sh [-acfgpqstux] 
  - REQUIRED:
    @ Mode (only one mode can be selected at a time) (一次只能選擇一種模式)
      - a , --ab      AB test mode
      - s , --success    Success mode
      - f , --fail    Failure mode
      - c , --check   Check mode
      - q , --quiet   Quiet mode (No notifications)
  - OPTIONAL:
    @ Project 
      - p , --project Setting project name (Specify the project name)
    @ Debug use
      - t , --test    Test mode (mock data for testing)
      - x , --x bool  [true] GitHub Actions mode
    @ Env setting
      - u , --url     Specify a URL (e.g., -u=URL)
    @ Slack Post Setting
      - g , --group   Specify the Slack group to post to (e.g., -g=jvid)
            --tag     Tag users in the Slack message (e.g., --tag='<!channel> <!here> <@zeki>')
    @ Arg  
      --aburl         $AB_LINK   = A/B test's link
      --abheader      $AB_HEADER = A/B test's header
EXAMPLE:
  [GitHub Actions]
    SHELL.sh -s
  [Jenkins, other CI Env]
    SHELL.sh -s -x -p=jkforum
  [Test]
    SHELL.sh -t -x -u="https://google.com" -s --tag='<@zeki>' -p="projectＡ"

EOF
  exit 1
}

# 處理參數
parse_arguments() {
  for i in "$@"; do
    case $i in
    -x | --x)
      GITHUB_ACTIONS=true
      shift # past argument=value
      ;;
    -u=* | --url=*)
      URL="${i#*=}"
      ;;
    -g=* | --group=*)
      SLACK_GROUP="${i#*=}"
      ;;
    -p=* | --project=*)
      PROJECT="${i#*=}"
      ;;
    -t | --test)
      # mock testing
      setup_test_environment
      ;;
    -s | --success)
      mode="s"
      MODE_COUNT=$((MODE_COUNT + 1))
      ;;
    -f | --fail)
      mode="f"
      MODE_COUNT=$((MODE_COUNT + 1))
      ;;
    -a | --ab)
      mode="a"
      MODE_COUNT=$((MODE_COUNT + 1))
      ;;
    --aburl=*)
      AB_LINK="${i#*=}"
      ;;
    --abheader=*)
      AB_HEADER="${i#*=}"
      ;;
    -c | --check)
      mode="c"
      MODE_COUNT=$((MODE_COUNT + 1))
      ;;
    -q | --quiet)
      mode="q"
      MODE_COUNT=$((MODE_COUNT + 1))
      echo "Disable" && exit 0
      ;;
    --tag=*)
      TAG="${i#*=}"
      ;;
    -h | --help)
      show_help
      ;;
    *)
      # unknown option
      ;;
    esac
  done
}

# 設置測試環境
setup_test_environment() {
  TEST_MODE=true
  GITHUB_REPOSITORY="lctech-tw/test_repo"
  BRANCH_NAME="test_main"
  GITHUB_HEAD_REF="test_test"
  GITHUB_EVENT_NAME="test_push"
  GITHUB_ACTOR="test_actorname"
  # GITHUB_JOB="test_job_name"
  AB_LINK="https://ablink.net"
  AB_HEADER="teststest"
}

# 檢查模式數量
check_mode_count() {
  if [ $MODE_COUNT -gt 1 ]; then
    echo "@ ERROR - You have entered multiple modes"
    echo "@ 錯誤 - 您輸入了多個模式"
    echo "@ MODE_COUNT -> $MODE_COUNT" && exit 1
  fi
}

# 檢查是否為假日
check_weekend() {
  if [ "$(date +%u)" -gt 5 ] && [ "${GITHUB_ACTOR}" == "lctech-zeki" ]; then
    echo "@ Skip notify because it's weekend !"
    exit 0
  fi
}

# 獲取 Slack 和 Google Chat URLs
get_notification_urls() {
  if [ -z ${GITHUB_ACTIONS+x} ]; then
    echo "🐥 Not from GitHub Actions" && exit 1
  else
    if $TEST_MODE; then
      echo "@ TEST"
      GITHUB_ACTOR="lctech-zeki"
    else
      # 從 GCP 獲取 URL
      CHAT_URL=$(gcloud secrets versions access latest --secret=cicd_chat_url --project=jkf-servers)
      # 根據群組設置 Slack URL 和圖示
      set_slack_group_config
    fi
  fi
}

# 設置 Slack 群組配置
set_slack_group_config() {
  case $SLACK_GROUP in
  avplus|rdc02)
    echo "@ SLACK_GROUP -> rdc02"
    SLACK_URL=$(gcloud secrets versions access latest --secret=slack_url_rdc02-cicd --project=jkf-servers)
    ICON=":github:"
    ERROR_USER='freddie9527'
    ;;
  jvid|rdc03)
    echo "@ SLACK_GROUP -> jvid"
    SLACK_URL=$(gcloud secrets versions access latest --secret=slack_url_jvid-cicd --project=jkf-servers)
    ICON=":jvid-rd:"
    ERROR_USER=''
    ;;
  jkface|rdc04)
    echo "@ SLACK_GROUP -> jkface"
    printenv
    echo "NOTIFY_SLACK_URL_RDC04: ${NOTIFY_SLACK_URL_RDC04}"
    SLACK_URL=$(gcloud secrets versions access latest --secret=slack_url_txg-cicd --project=jkf-servers)
    ICON=":hehe:"
    ERROR_USER='ray'
    ;;
  *)
    echo "@ SLACK_GROUP -> default"
    SLACK_URL=$(gcloud secrets versions access latest --secret=slack_url --project=jkf-servers)
    ERROR_USER='zeki'
    ;;
  esac
}

# 獲取 Git 信息
get_git_info() {
  if [ "${GITHUB_EVENT_NAME:-"not-github"}" == 'pull_request' ]; then
    # shellcheck disable=SC2296
    GITMSG=$(git log --format=%B -n 1 "${{github.sha}}")
    BRANCH_NAME="${GITHUB_HEAD_REF//\//-}"
  else
    GITMSG=$(git log -1 --pretty=format:"%s")
    GITMSG_BODY=$(git log -1 --pretty=format:"%b")
    BRANCH_NAME=$(git symbolic-ref --short HEAD 2>/dev/null || echo "unknown")
  fi

  GITMSG=${GITMSG:-"N/A"}
  GITMSG_BODY=${GITMSG_BODY:-"N/A"}
}

# 設置 Jenkins 環境
setup_jenkins_env() {
  if [ -z ${GITHUB_REPOSITORY+x} ] ;then
    echo "JENKINS_MODE"
    CI_SERVER_NAME="Jenkins"
    GITHUB_REPOSITORY=$JOB_NAME
    GITHUB_ACTOR="${CHANGE_AUTHOR:-Jenkins}"
    GITHUB_RUN_NUMBER=$BUILD_ID
    GITHUB_EVENT_NAME="push"
    ICON=":sad-jenkins:"
    GITHUB_WORKFLOW="jenkins-flow"
  fi
}

# 獲取作者名稱
get_author_name() {
  curl -sLJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/nametable.sh
  AUTHOR_NAME=$(bash ./nametable.sh "$GITHUB_ACTOR")
  echo "@ AUTHOR_NAME = $GITHUB_ACTOR -> $AUTHOR_NAME"
}

# 設置 URL 和圖示
setup_url_and_icon() {
  # URL link
  if [ "$URL" != "" ]; then
    echo "@ URL = $URL"
    JSONURL=',{"text": ":chrome: '"$URL"'","color": "#FFBB77"}'
  fi

  # 選擇適合的圖示
  if [ "$ICON" == "" ]; then
    ICON=":doge:"
    if [ "$AUTHOR_NAME" == "ray" ] || [ "$AUTHOR_NAME" == "freddie9527" ]; then
      ICON=":pissed:"
    fi
    if [ "$AUTHOR_NAME" == "jack" ]; then
      ICON=":squirrel:"
    fi
  fi
}

# 顯示環境信息
print_environment() {
  if $TEST_MODE; then
    echo " -- T E S T - - "
    BRANCH_NAME="master"
  fi
  echo "@ CI_SERVER_NAME = $CI_SERVER_NAME"
  echo "@ GITMSG = $GITMSG"
  GITMSG_BODY="$(echo "$GITMSG_BODY" | xargs)"
  echo "@ GITMSG_BODY = $GITMSG_BODY"
  echo "@ B/E = $BRANCH_NAME / $GITHUB_EVENT_NAME"
  echo "@ TAG = $TAG"
  echo "@ ICON = $ICON"
  echo "@ PROJECT = $PROJECT"
}

# 發送 Slack 和 Google Chat 通知
send_notification() {
  if [ -n "$mode" ]; then
    case $mode in
    s) # Success mode
      echo " -- success mode -- "
      curl -s -X POST -H 'Content-type: application/json' \
        --data '{"attachments":[{"color":"#36a64f","pretext":"[ '"$CI_SERVER_NAME"' ] :approved: \n '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_WORKFLOW"' / '"$GITHUB_RUN_NUMBER"' / '"<@$AUTHOR_NAME>"' '" $TAG"' ","author_name":"'"$ICON $GITHUB_ACTOR"'","title":"'"✅  $GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"💬 ${GITMSG}"'"}'"$JSONURL"']}' \
        "$SLACK_URL"
      # google chat  
      echo " -- google chat -- "
      curl -X POST -H "Content-Type: application/json" --no-progress-meter -q \
        -d '{"cards": [{
          "header": {
            "title": "Github Actions",
            "subtitle": "'"$GITHUB_REPOSITORY"'",
            "imageUrl": "https://emoji.slack-edge.com/T2BCVHVK2/approved/334666dff8892a75.png"
          },
          "sections": {
            "header": "<font color=\"#006400\"> '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_WORKFLOW"' / '"$GITHUB_RUN_NUMBER"' / '"$GITHUB_ACTOR"' </font>",
            "widgets": [{"textParagraph": {"text": "'"$GITMSG"'",},}]}}]}' \
        "$CHAT_URL"
      ;;
    f) # Fail mode
      echo " -- fail mode -- "
      curl -s -X POST -H 'Content-type: application/json' \
        --data '{"attachments":[{"color":"#EA0000","pretext":"[ '"$CI_SERVER_NAME"' ] :github-changes-requested: \n '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_WORKFLOW"' / '"$GITHUB_RUN_NUMBER"' / '"<@$AUTHOR_NAME>"' / '"<@$ERROR_USER>"'  ","author_name":"'":rdrr_pa: $GITHUB_ACTOR"'","title":"'"⚠️  $GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"💬 $GITMSG"'"}]}' \
        "$SLACK_URL"
      # google chat  
      echo " -- google chat -- "
      curl -X POST -H "Content-Type: application/json" --no-progress-meter -q \
        -d '{"cards": [{
          "header": {
            "title": "Github Actions",
            "subtitle": "'"$GITHUB_REPOSITORY"'",
            "imageUrl": "https://emojis.slackmojis.com/emojis/images/1596524162/9907/blobfail.png?1596524162"
          },
          "sections": {
            "header": "<font color=\"#EA0000\"> '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_WORKFLOW"' / '"$GITHUB_RUN_NUMBER"' / '"$GITHUB_ACTOR"' </font>",
            "widgets": [{"textParagraph": {"text": "'"$GITMSG"'",},}]}}]}' \
        "$CHAT_URL"
      ;;
    a) # AB test mode
      echo " -- ab mode -- "
      curl -s -X POST -H 'Content-type: application/json' \
        --data '{"attachments":[{"color":"#36a64f","pretext":"[ '"$CI_SERVER_NAME"' ] :github-check-mark: \n '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_WORKFLOW"' / '"$GITHUB_RUN_NUMBER"' / '"<@$AUTHOR_NAME>"' '" $TAG"' ","author_name":"'"$ICON $GITHUB_ACTOR"'","title":"'"✅  $GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"💬 $GITMSG"'"},{"color":"#FFBB77","title":" :ab: '"$AB_LINK"' ","title_link":"'"$AB_LINK"'","text":"Inspect Header: '"$AB_HEADER"'"}]}' \
        "$SLACK_URL"
      ;;
    c) # Check mode
      echo " -- check mode -- "
      curl -s -X POST -H 'Content-type: application/json' \
        --data '{"attachments":[{"color":"#0B6FFF","pretext":"[ '"$CI_SERVER_NAME"' ] :github-check-mark: \n '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_WORKFLOW"' / '"$GITHUB_RUN_NUMBER"' ","callback_id":"confirmaction","text":"Are you sure to confirm deployment to GA?","attachment_type":"default","actions":[{"name":"reject","text":"Reject","type":"button","style":"danger","value":"rejectaction"},{"name":"ga","text":"GA","type":"button","style":"primary","value":"confirmaction"}]}]}' \
        "$SLACK_URL"
      ;;
    esac
  fi
}

# 主函數
main() {
  # 檢查是否顯示幫助
  if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
    show_help
  fi
  
  # 處理參數
  parse_arguments "$@"
  
  # 檢查模式數量
  check_mode_count
  
  # 檢查是否為週末
  check_weekend
  
  # 獲取通知 URLs
  get_notification_urls
  
  # 獲取 Git 信息
  get_git_info
  
  # 設置 Jenkins 環境(如果適用)
  setup_jenkins_env
  
  # 獲取作者名稱
  get_author_name
  
  # 設置 URL 和圖示
  setup_url_and_icon
  
  # 顯示環境信息
  print_environment
  
  # 發送通知
  send_notification
}

# 執行主函數
main "$@"

