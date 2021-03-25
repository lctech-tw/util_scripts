# util_scripts

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
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/util_scripts/main/notify_slack.sh)"

# 先下載在調用
# -L → --location
# -J → --remote-header-name
# -O → --remote-name
curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/notify_slack.sh 
./notify_slack.sh -h
./notify_slack.sh -s 
...

```

```yaml
      - name: ⚙️ Initialize Google Cloud SDK
        uses: GoogleCloudPlatform/github-actions/setup-gcloud@master  
        with:
          project_id: #$GCPproject_id
          service_account_email: #"github-ci@email"
          service_account_key: ${{ secrets.GCP_SA_KEY_GITHUB_CI }}
          export_default_credentials: true
      - name: ⚙️ login Google Cloud SDK
        run: |
          # This client-secret.json is converted by GCP_SA_KEY.
          echo '${{ secrets.GCP_SA_KEY_GITHUB_CI }}' > client-secret.json
          gcloud auth activate-service-account "github-ci@email" --key-file=client-secret.json
          gcloud config set project $GCPproject_id

 ...

      - name: Slack Notification on Success (O)
        if: success()
        run: |
          echo "run slack on Success (O)"
          curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/notify_slack.sh 
          bash ./notify_slack.sh -s 

      - name: Slack Notification on Failure (X)
        if: failure()
        run: |
          echo "run slack on fail (X)"
          curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/notify_slack.sh 
          bash ./notify_slack.sh -f 
```

## Some other util

[csv2md - csv 轉成 md table](https://www.convertcsv.com/csv-to-markdown.htm)
