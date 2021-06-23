#!/bin/bash

#* Need gcp auth 

#* Env
GITHUB_ACTIONS_MODE=true
# 0 -> Nothing / 1 -> Do / < 1 -> close
modecount=0
testmode=false
TAG=""

#* help
if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
  cat >&2 <<"EOF"
Description:
  由原本 jenkins tesk3.sh 調整
USAGE:
  SHELL.sh [-acfgqstux] 
  @ Mode (only)
    - a , --ab     AB test mode
    - s , --secc   succ mode
    - f , --fail   fail mode
    - c , --check  check mode
    - q , --quiet  quiet mode
  @ Debug use
    - t , --test   test mode
    - x , --x bool [true] github mode
  @ Env setting
    - u , --url    use URL     ( Ex: -u=URL )
  @ Slack Post Setting
    - g , --group  post group  ( Ex: -g=jvid )
    --tag  TAG who ( Ex: --tag='<!channel> <!here> <@zeki>' )
  @ Arg  
    $AB_LINK   = A/B test's link
    $AB_HEADER = A/B test's header
EXAMPLE:
  [github action]
    SHELL.sh -s
  [other]
    SHELL.sh -t -x -u="https://google.com" -s --tag='<@zeki>'

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
  -u=*|--url=*)
    URL="${i#*=}"
    ;;
  -g=*|--group=*)
    SLACK_GROUP="${i#*=}"
    ;;
  -t | --test)
    # mock testing
    testmode=true
    GITHUB_REPOSITORY="test_repo"
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
    modecount=$((modecount+1))
    ;;
  -f | --fail)
    mode="f"
    modecount=$((modecount+1))
    ;;
  -a | --ab)
    modecount=$((modecount+1))
    ;;
  -c | --check)
    modecount=$((modecount+1))
    ;;
  -q | --quiet)
    mode="q"
    modecount=$((modecount+1))
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

#* 檢查 MODE變數
if [ $modecount -gt 1 ];then
echo "@ ERROR - You enter mode the wrong "
echo "@ modecount -> $modecount"
exit 1
fi

#* 檢查 GITHUB ACTION & 取URL
if "$GITHUB_ACTIONS_MODE"; then
  if [ -z "$GITHUB_ACTIONS" ]; then
    echo "🐥 Not from github action"
    exit 1
  else
    if $testmode ;then
      echo "@ TEST" 
      #SLACK_URL="https://ho"
      #"oks.slack.com/services/T2BCVHV"
      #"K2/B02578RKE7J/c8QeRmYfQtVbKcZMWCCRyr3y"
    else
      # url -> gcp / secrets
      case $SLACK_GROUP in
      jvid)
        echo "@ SLACK_GROUP -> jvid"
        SLACK_URL=$(gcloud secrets versions access latest --secret=slack_url_jvid --project=jkf-servers)
      ;;
      *)
        echo "@ SLACK_GROUP -> default"
        SLACK_URL=$(gcloud secrets versions access latest --secret=slack_url --project=jkf-servers)
      ;;
      esac
    fi
  fi
fi

#* 檢查 EVENT MODE ( Use .git info )
if [ "$GITHUB_EVENT_NAME" == 'pull_request' ]; then
  GITMSG=$(git log --format=%B -n 1 "${{ github.event.after }}" )
  BRANCH_NAME=$(echo "${GITHUB_HEAD_REF}" | tr / -)
else
  GITMSG=$(git log -1 --pretty=format:"%s")
  BRANCH_NAME=$(echo "${GITHUB_REF#refs/heads/}" | tr / -)
fi

#* URL link
if [ "$URL" != "" ]; then
  echo "@ URL = $URL"
  JSONURL=',{"text": "URL : '"$URL"'","color": "#FFBB77"}'
fi

#* printenv
if $testmode ;then
  echo " -- T E S T - - "
  BRANCH_NAME="test"  
fi
echo "@ GITMSG = $GITMSG"
echo "@ B/E = $BRANCH_NAME / $GITHUB_EVENT_NAME"
echo "@ TAG = $TAG"

#* json post 
case $mode in
  s)
    echo " -- secc mode -- "
    curl -X POST -H 'Content-type: application/json' \
      --data '{"attachments":[{"color":"#36a64f","pretext":"[Github Action] Success \n '"$BRANCH_NAME"' / '"$GITHUB_EVENT_NAME"' / '"$GITHUB_RUN_NUMBER"' '"$TAG"' ","author_name":"'"👤 $GITHUB_ACTOR"'","title":"'"📦 $GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"💬 $GITMSG"'"}'"$JSONURL"']}' \
      "$SLACK_URL"
    ;;
  f)
    echo " -- fail mode -- "
    curl -X POST -H 'Content-type: application/json' \
      --data '{"attachments":[{"color":"#EA0000","pretext":"[Github Action] Fail \n '"$BRANCH_NAME"' / '"$GITHUB_EVENT_NAME"' / '"$GITHUB_RUN_NUMBER"'  ","author_name":"'"👤 $GITHUB_ACTOR"'","title":"'"📦 $GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"💬 $GITMSG"'"}]}' \
      "$SLACK_URL"
    ;;
  a)
    echo " -- ab mode -- "
    curl -X POST -H 'Content-type: application/json' \
      --data '{"attachments":[{"color":"#36a64f","pretext":"[Github Action] Success \n '"$BRANCH_NAME"' / '"$GITHUB_EVENT_NAME"' / '"$GITHUB_RUN_NUMBER"' ","author_name":"'"$GITHUB_ACTOR"'","title":"'"$GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"$GITHUB_WORKFLOW"' / '"$GITHUB_JOB"'"},{"color":"#FFBB77","pretext":"AB Test","title":" A/B WEB-Link ","title_link":"'"$AB_LINK"'","text":"Inspect Header: '"$AB_HEADER"'"}]}' \
      "$SLACK_URL"
    ;;
  c)
    echo " -- check mode -- "
    curl -X POST -H 'Content-type: application/json' \
      --data '{"attachments":[{"color":"#0B6FFF","pretext":"[Github Action] Success \n '"$BRANCH_NAME"' / '"$GITHUB_EVENT_NAME"' / '"$GITHUB_RUN_NUMBER"' ","callback_id":"confirmaction","text":"Are you sure to confirm deployment to GA?","attachment_type":"default","actions":[{"name":"reject","text":"Reject","type":"button","style":"danger","value":"rejectaction"},{"name":"ga","text":"GA","type":"button","style":"primary","value":"confirmaction"}]}]}' \
      "$SLACK_URL"
esac

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
