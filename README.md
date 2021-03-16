# shell_util

|Path|Name|Desc|
|-|-|-|
|-|notify_slack.sh|通知slack|
|-|gcp_sm_get_slack.py|from secret-manager get slack to sysenv |
|-|-|-|
|sigma|gcp_iam_get_all.sh|list gcp auth fo .csv|
|sigma|gcp_gcr_rm_image.sh| rm gcr images|
|sigma|gcp_gcr_rm_all.sh|forloop rm gcr|
|-|-|-|

## How to use

```sh
# 直接調用
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/shell_util/main/notify_slack.sh)"

# 先下載在調用
# -L → --location
# -J → --remote-header-name
# -O → --remote-name
curl -LJO https://raw.githubusercontent.com/lctech-tw/shell_util/main/notify_slack.sh 
./notify_slack.sh -h
./notify_slack.sh -s 
...

```

## Some other util

[csv2md - csv 轉成 md table](https://www.convertcsv.com/csv-to-markdown.htm)
