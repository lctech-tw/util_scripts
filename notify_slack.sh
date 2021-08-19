#!/bin/bash
# Purpose: Post slack notify
# Author: @lctech-zeki
# Requirments: Bash v3.x+ and curl running on Linux/Unix-like systems
# -------------------------------------------------------------------

#* Need gcp auth

#* Env
# check is GITHUB_ACTIONS
GITHUB_ACTIONS_MODE=true
# func 0 -> Nothing / 1 -> Do / < 1 -> close
MODECOUNT=0
# test mode
TEST_MODE=false
# msg tag user
TAG=""
# setting icon
ICON=""
# setting PROJECT
PROJECT=""
# setting PRECI
PRECI="false"

#* help
if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
  cat >&2 <<"EOF"
Description:
  由原本 jenkins tesk3.sh 調整
USAGE:
  SHELL.sh [-acfgpqstux] 
  @ Mode (only)
    - a , --ab      AB test mode
    - s , --secc    succ mode
    - f , --fail    fail mode
    - c , --check   check mode
    - q , --quiet   quiet mode
  @ Project 
    - p , --project projectname
  @ Debug use
    - t , --test    test mode
    - x , --x bool  [true] github mode
  @ Env setting
    - u , --url     use URL     ( Ex: -u=URL )
  @ Slack Post Setting
    - g , --group   post group  ( Ex: -g=jvid )
          --tag     TAG who  ( Ex: --tag='<!channel> <!here> <@zeki>' )
  @ Pre-CI
    --pre-ci
  @ Arg  
    $AB_LINK   = A/B test's link
    $AB_HEADER = A/B test's header
EXAMPLE:
  [github action]
    SHELL.sh -s
  [other]
    SHELL.sh -t -x -u="https://google.com" -s --tag='<@zeki>' -p="產品Ａ"

EOF
  exit 1
fi

#* get env
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
  --pre-ci)
    PRECI="true"
    ;;
  -t | --test)
    # mock testing
    TEST_MODE=true
    GITHUB_REPOSITORY="lctech-tw/test_repo"
    BRANCH_NAME="test_main"
    GITHUB_HEAD_REF="test_test"
    GITHUB_EVENT_NAME="test_push"
    GITHUB_ACTOR="test_actorname"
    GITHUB_JOB="test_job_name"
    AB_LINK="https://ablink.net"
    AB_HEADER="teststest"
    ;;
  -s | --secc)
    mode="s"
    MODECOUNT=$((MODECOUNT + 1))
    ;;
  -f | --fail)
    mode="f"
    MODECOUNT=$((MODECOUNT + 1))
    ;;
  -a | --ab)
    MODECOUNT=$((MODECOUNT + 1))
    ;;
  -c | --check)
    MODECOUNT=$((MODECOUNT + 1))
    ;;
  -q | --quiet)
    mode="q"
    MODECOUNT=$((MODECOUNT + 1))
    echo "88"
    exit 0
    ;;
  --tag=*)
    TAG="${i#*=}"
    ;;
  *)
    # unknown option
    ;;
  esac
done

#* 檢查 MODE 變數
if [ $MODECOUNT -gt 1 ]; then
  echo "@ ERROR - You enter mode the wrong "
  echo "@ MODECOUNT -> $MODECOUNT"
  exit 1
fi

#* 檢查 GITHUB ACTION & 獲取 URL
if "$GITHUB_ACTIONS_MODE"; then
  if [ -z ${GITHUB_ACTIONS+x} ]; then
    echo "🐥 Not from github action"
    exit 1
  else
    if $TEST_MODE; then
      echo "@ TEST"
      GITHUB_ACTOR="lctech-zeki"
      # SLACK_URL=""
    else
      # url -> gcp / secrets
      case $SLACK_GROUP in
      jvid)
        echo "@ SLACK_GROUP -> jvid"
        SLACK_URL=$(gcloud secrets versions access latest --secret=slack_url_jvid-cicd --project=jkf-servers)
        ICON=":jvid-rd:"
        ;;
      *)
        echo "@ SLACK_GROUP -> default"
        SLACK_URL=$(gcloud secrets versions access latest --secret=slack_url --project=jkf-servers)
        ;;
      esac
    fi
  fi
fi

#* 取得作者
curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/nametable.sh
AURTHOR_NAME=$(bash ./nametable.sh $GITHUB_ACTOR)
echo "@ AURTHOR_NAME = $GITHUB_ACTOR -> $AURTHOR_NAME"

#* 檢查 EVENT MODE ( Use .git info )
if [ "$GITHUB_EVENT_NAME" == 'pull_request' ]; then
  GITMSG=$(git log --format=%B -n 1 "${{ github.event.after }}" )
  BRANCH_NAME=$(echo "${GITHUB_HEAD_REF}" | tr / -)
else
  GITMSG=$(git log -1 --pretty=format:"%s")
  GITMSG_BODY=$(git log -1 --pretty=format:"%b")
  #BRANCH_NAME=$(echo "${GITHUB_REF#refs/heads/}" | tr / -)
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi

if [ "$GITMSG_BODY" == "" ] ;then
  GITMSG_BODY="N/A"
fi

#* 檢查 GITHUB_REPOSITORY
if [ -z ${GITHUB_REPOSITORY+x} ] ;then
  echo "JENKINS_MODE"
  GITHUB_REPOSITORY=$JOB_NAME
fi

#* URL link
if [ "$URL" != "" ]; then
  echo "@ URL = $URL"
  JSONURL=',{"text": ":chrome: '"$URL"'","color": "#FFBB77"}'
fi

#* icon
if [ "$ICON" == "" ]; then
  ICON=":doge:"
fi

#* print env
if $TEST_MODE; then
  echo " -- T E S T - - "
  BRANCH_NAME="master"
fi
echo "@ GITMSG = $GITMSG"
echo "@ GITMSG_BODY = $GITMSG_BODY"
echo "@ B/E = $BRANCH_NAME / $GITHUB_EVENT_NAME"
echo "@ TAG = $TAG"
echo "@ ICON = $ICON"
echo "@ PROJECT =  $PROJECT"

#* json post mode
if [ -n "$mode" ];then
case $mode in
s)
  echo " -- secc mode -- "
  curl -s -X POST -H 'Content-type: application/json' \
    --data '{"attachments":[{"color":"#36a64f","pretext":"[ Github Action ] :github-check-mark: \n '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_RUN_NUMBER"' / '"<@$AURTHOR_NAME>"' '" $TAG"' ","author_name":"'"$ICON $GITHUB_ACTOR"'","title":"'"📦 $GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"💬 $GITMSG"'"}'"$JSONURL"']}' \
    "$SLACK_URL"
  ;;
f)
  echo " -- fail mode -- "
  curl -s -X POST -H 'Content-type: application/json' \
    --data '{"attachments":[{"color":"#EA0000","pretext":"[ Github Action ] :github-changes-requested: \n '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_RUN_NUMBER"' / '"<@zeki>"'  ","author_name":"'":imdead: $GITHUB_ACTOR"'","title":"'"📦 $GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"💬 $GITMSG"'"}]}' \
    "$SLACK_URL"
  ;;
a)
  echo " -- ab mode -- "
  curl -s -X POST -H 'Content-type: application/json' \
    --data '{"attachments":[{"color":"#36a64f","pretext":"[ Github Action ] :github-check-mark: \n '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_RUN_NUMBER"' ","author_name":"'"$GITHUB_ACTOR"'","title":"'"$GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"$GITHUB_WORKFLOW"' / '"$GITHUB_JOB"'"},{"color":"#FFBB77","pretext":"AB Test","title":" A/B WEB-Link ","title_link":"'"$AB_LINK"'","text":"Inspect Header: '"$AB_HEADER"'"}]}' \
    "$SLACK_URL"
  ;;
c)
  echo " -- check mode -- "
  curl -s -X POST -H 'Content-type: application/json' \
    --data '{"attachments":[{"color":"#0B6FFF","pretext":"[ Github Action ] :github-check-mark: \n '"$GITHUB_EVENT_NAME"' / '"$BRANCH_NAME"' / '"$GITHUB_RUN_NUMBER"' ","callback_id":"confirmaction","text":"Are you sure to confirm deployment to GA?","attachment_type":"default","actions":[{"name":"reject","text":"Reject","type":"button","style":"danger","value":"rejectaction"},{"name":"ga","text":"GA","type":"button","style":"primary","value":"confirmaction"}]}]}' \
    "$SLACK_URL"
  ;;
esac
fi

function postline {
    if [ "$1" == "pre-ci" ]; then
      LINE_ALTTEXT="重要通知 - 即將更新版本"
      LINE_COLOR="#B5B5B5"
      LINE_MSG="$PROJECT即將更新版本"
    elif [ "$1" == "end-ci" ]; then
      LINE_ALTTEXT="重要通知 - 版本更新完成"
      LINE_COLOR="#CCAFAF"
      LINE_MSG="$PROJECT新版本更新完成上線"
    fi
    echo "$LINE_MSG ,$GITMSG, ${GITMSG_BODY:-nil}, ${GITHUB_REPOSITORY:-nil}"
    curl -X POST https://api.line.me/v2/bot/message/push \
      -H 'Content-Type: application/json' \
      -H 'Authorization: Bearer { '"$LINE_TOKEN"' }' \
      -d '{
    "to": "C5326151f5088938355140be7f339f5c8",
    "messages":[
        {
            "type": "flex",
            "altText": "'"$LINE_ALTTEXT"'",
            "contents":  {
                "type": "bubble",
                "header": {
                  "type": "box",
                  "layout": "horizontal",
                  "contents": [
                    {
                      "type": "text",
                      "text": "產品更新",
                      "margin": "md",
                      "size": "md",
                      "color": "#240407",
                      "weight": "bold",
                      "gravity": "center"
                    },
                    {
                      "type": "image",
                      "url": "https://www.jkf.net/images/jkflogo.png",
                      "size": "xxs",
                      "align": "end",
                      "offsetBottom": "xs"
                    }
                  ],
                  "paddingBottom": "sm",
                  "paddingTop": "sm"
                },
                "body": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "text",
                      "text": "重要通知",
                      "color": "#E63946",
                      "weight": "bold",
                      "margin": "md"
                    },
                    {
                      "type": "text",
                      "text": "'"$LINE_MSG"'",
                      "weight": "regular",
                      "size": "lg",
                      "margin": "xs",
                      "wrap": true
                    },
                    {
                      "type": "text",
                      "text": "相關資訊標題",
                      "weight": "bold",
                      "color": "#E63946",
                      "margin": "md"
                    },
                    {
                      "type": "text",
                      "text": "'"$GITMSG"'",
                      "wrap": true
                    },
                    {
                      "type": "text",
                      "text": "相關資訊細節",
                      "weight": "bold",
                      "color": "#E63946",
                      "margin": "md"
                    },
                    {
                      "type": "text",
                      "text": "'"$GITMSG_BODY"'",
                      "wrap": true
                    },
                    {
                      "type": "text",
                      "text": "'"$GITHUB_REPOSITORY"'",
                      "size": "xs",
                      "color": "#aaaaaa",
                      "wrap": true,
                      "margin": "sm"
                    }
                  ],
                  "paddingTop": "sm",
                  "paddingBottom": "lg"
                },
                "size": "mega",
                "styles": {
                  "header": {
                    "backgroundColor": "'"$LINE_COLOR"'"
                  },
                  "body": {
                    "backgroundColor": "#FFFCFC"
                  },
                  "footer": {
                    "separator": true
                  }
                }
              }
        }
      ]
  }'
}
LINE_TOKEN=$(gcloud secrets versions access latest --secret=line_token --project=jkf-servers)
#* json Line post PRE CC  營運 / 客服
if [ $PRECI == "true" ] ;then 
  if  [ $BRANCH_NAME == "main" ]||[ $BRANCH_NAME == "master" ] ; then
    # 通告營運相關所有人員
    echo "@ Call lin pre-ci"
    postline pre-ci
    exit 0
  fi
fi
#* json Line post END CC 營運 / 客服
if [ $mode == "s" ] &&[ $BRANCH_NAME == "master" ] ; then
  echo "@ Call line end-ci"
  postline end-ci
fi
if [ $mode == "s" ] && [ $BRANCH_NAME == "main" ] ; then
  echo "@ Call line end-ci"
  postline end-ci
fi

#* -Note--------------------------------------------------------------------

#* TEMPLATE (https://api.slack.com/docs/messages/builder?msg=%7B%22text%22%3A%22I%20am%20a%20test%20message%22%2C%22attachments%22%3A%5B%7B%22text%22%3A%22And%20here%E2%80%99s%20an%20attachment!%22%7D%5D%7D)
# {
#     "attachments": [
#         {
#             "color": "#36a64f",
#             "pretext": "[Github Action]\n $BRANCH_NAME / $GITHUB_EVENT_NAME ",
#             "author_name": "$GITHUB_ACTOR",
#             "title": "$GITHUB_REPOSITORY",
#             "title_link": "https://github.com/$GITHUB_REPOSITORY",
#             "text": "$GITHUB_WORKFLOW / $GITHUB_JOB"
#         },
# 		{
# 		 "color": "#FFBB77",
# 		 "pretext": "AB Test",
# 		 "title": " A/B WEB-Link",
# 		 "title_link": "$AB_LINK",
# 		 "text": "Inspect Header: $AB_HEADER"
# 		}
#     ]
# }
#? # GA button
# {
#     "attachments": [
#         {
#             "color": "#0B6FFF",
#             "pretext": "[Github Action]\n $BRANCH_NAME / $GITHUB_EVENT_NAME ",
#             "callback_id": "confirmaction",
# 			      "text": "Are you sure to confirm deployment to GA?",
#             "attachment_type": "default",
#             "actions": [
# 			        {"name": "reject", "text": "Reject", "type": "button", "style": "danger", "value": "rejectaction"},
# 		        	{"name": "ga", "text": "GA", "type": "button", "style": "primary", "value": "confirmaction"}
#             ]
#         }
#     ]
# }
#? # URL
# {
#             "text": "URL : $URL"
# }

#* ORIGN SHELL
# curl -X POST -H 'Content-type: application/json' \
# --data '{"text": "Pipeline has passed.","attachments": [{"text": "Node: '"${NODE_NAME}"'"},{"text": "User: '"${CHANGED_BY_AUTHOR}"'"},{"text": "Version: '"${CODE_VERSION}"'"},{"text": "Inspect Header: '"${AB_VAR_NAME}=${AB_VAR_VALUE}"'"},{"text": "URL: '"${SVC_URL}"'"}]}' \
# $SLACK_URL
