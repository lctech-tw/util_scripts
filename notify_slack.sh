#!/bin/bash

GITHUB_ACTIONS_MODE=true

# mock test
# BRANCH_NAME="test_branch_name"
# GITHUB_EVENT_NAME="test_event_name"
# GITHUB_ACTOR="test_actor"
# GITHUB_JOB="test_job_name"
# AB_LINK="https://jkf.net"
# AB_HEADER="teststest"

if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
  cat >&2 <<"EOF"
Description:
  由原本 jenkins tesk3.sh 調整
USAGE:
  SHELL.sh 
  - a , --AB   AB test mode
  - s , --succ 
  - f , --fail
  - t , --test
  - x bool [true] github mode
EXAMPLE
  [github action]
  SHELL.sh -s
  [other]
  SHELL.sh -s -x

EOF
  exit 1
fi
for i in "$@"; do
  case $i in
  -x | --x)
    GITHUB_ACTIONS=true
    shift # past argument=value
    ;;
  *)
    # unknown option
    ;;
  esac
done

#* 檢查 GITHUB ACTION
if "$GITHUB_ACTIONS_MODE"; then
  if [ -z "$GITHUB_ACTIONS" ]; then
    echo "🐥 Not from github action"
    exit 1
    else
    # slack url -> jkf-servers / secrets
    SLACK_URL=$(gcloud secrets versions access latest --secret=slack_url --project=jkf-servers)
  fi
fi

#* 檢查 EVENT MODE
if [ "$GITHUB_EVENT_NAME" == 'pull_request' ]; then
  BRANCH_NAME=$(echo "${GITHUB_HEAD_REF}" | tr / -)
else
  BRANCH_NAME=$(echo "${GITHUB_REF#refs/heads/}" | tr / -)
fi
echo "$BRANCH_NAME / $GITHUB_EVENT_NAME"

#* json post 
if [ "$1" == "-s" ]; then
  echo " -- secc mode -- "
curl -X POST -H 'Content-type: application/json' \
  --data '{"attachments":[{"color":"#36a64f","pretext":"[Github Action] Success \n '"$BRANCH_NAME"' / '"$GITHUB_EVENT_NAME"' ","author_name":"'"$GITHUB_ACTOR"'","title":"'"$GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"$GITHUB_JOB"'"}]}' \
  "$SLACK_URL"
fi

if [ "$1" == "-f" ]; then
  echo " -- fail mode -- "
curl -X POST -H 'Content-type: application/json' \
  --data '{"attachments":[{"color":"#EA0000","pretext":"[Github Action] Fail \n '"$BRANCH_NAME"' / '"$GITHUB_EVENT_NAME"' ","author_name":"'"$GITHUB_ACTOR"'","title":"'"$GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"$GITHUB_JOB"'"}]}' \
  "$SLACK_URL"
fi

if [ "$1" == "-a" ]; then
  echo " -- ab mode -- "
curl -X POST -H 'Content-type: application/json' \
  --data '{"attachments":[{"color":"#36a64f","pretext":"[Github Action] Success \n '"$BRANCH_NAME"' / '"$GITHUB_EVENT_NAME"' ","author_name":"'"$GITHUB_ACTOR"'","title":"'"$GITHUB_REPOSITORY"'","title_link":"https://github.com/'"$GITHUB_REPOSITORY"'","text":"'"$GITHUB_JOB"'"},{"color":"#FFBB77","pretext":"AB Test","title":" A/B WEB-Link ","title_link":"'"$AB_LINK"'","text":"Inspect Header: '"$AB_HEADER"'"}]}' \
  "$SLACK_URL"
fi


#* TEMPLATE
# {
#     "attachments": [
#         {
#             "color": "#36a64f",
#             "pretext": "[Github Action]\n $BRANCH_NAME / $GITHUB_EVENT_NAME ",
#             "author_name": "$GITHUB_ACTOR",
#             "title": "$GITHUB_REPOSITORY",
#             "title_link": "https://github.com/$GITHUB_REPOSITORY",
#             "text": "$GITHUB_JOB"
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

#* ORIGN SHELL
# curl -X POST -H 'Content-type: application/json' \
# --data '{"text": "Pipeline has passed.","attachments": [{"text": "Node: '"${NODE_NAME}"'"},{"text": "User: '"${CHANGED_BY_AUTHOR}"'"},{"text": "Version: '"${CODE_VERSION}"'"},{"text": "Inspect Header: '"${AB_VAR_NAME}=${AB_VAR_VALUE}"'"},{"text": "URL: '"${SVC_URL}"'"}]}' \
# $SLACK_URL

