#! /bin/bash

GITHUB_EVENT_NAME=push
BRANCH_NAME=master
GITHUB_RUN_NUMBER=1111
AURTHOR_NAME=zeki
GITHUB_ACTOR=zeki
GITHUB_REPOSITORY=lctech-tw/repostitory
GITMSG="commit message"
# JSONURL

# success
curl -X POST -H "Content-Type: application/json" \
    -d '{
  "cards": [
    {
      "header": {
        "title": "Github Actions",
        "subtitle": "'$GITHUB_REPOSITORY'",
        "imageUrl": "https://emojis.slackmojis.com/emojis/images/1540491167/4864/github-check-mark.png?1540491167"
      },
      "sections": {
        "header": "<font color=\"#006400\"> '$GITHUB_EVENT_NAME' / '$BRANCH_NAME' / '$GITHUB_RUN_NUMBER' / '$GITHUB_ACTOR' </font>",
        "widgets": [
          {
            "textParagraph": {
              "text": "'"$GITMSG"'",
              },
            }
          ]
        }
      }
    ]
  }

' \
    "https://chat.googleapis.com/v1/spaces/AAAAQkdkW-c/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=CgIDE2tdHII5Krts4qONzvgsARcEEgmsbEU2ZS0zFlo="



# AB
# curl -X POST -H "Content-Type: application/json" \
#     -d '{
#   "cards": [
#     {
#       "header": {
#         "title": "Github Actions",
#         "subtitle": "lctech-tw/jkf-proto-1234",
#         "imageUrl": "https://emojis.slackmojis.com/emojis/images/1540491167/4864/github-check-mark.png?1540491167"
#       },
#       "sections": {
#         "header": "<font color=\"#006400\" face=\"DFKai-sb\">push / _develop / 117 / jasper </font>",
#         "widgets": [
#           {
#             "textParagraph": {
#               "text": "這是之後要放commmmit 的地方",
#               },
#               "buttons": [
#                 {
#                   "textButton": {
#                         "text": "測試站連結",
#                     "onClick": {
#                         "openLink": {
#                         "url": "https://emojis.slackmojis.com/emojis/images/1540491167/4864/github-check-mark.png?1540491167"
#                       }
#                       }
#                       }
#                   }
#               ]
#             }
#           ]
#         }
#       }
#     ]
#   }

# ' \
#     "https://chat.googleapis.com/v1/spaces/AAAAQkdkW-c/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=CgIDE2tdHII5Krts4qONzvgsARcEEgmsbEU2ZS0zFlo="
