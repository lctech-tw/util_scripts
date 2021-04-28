# util_scripts

|Path|Name|Desc|
|-|-|-|
|-|notify_slack.sh|Notify slack use|
|-|modify_version.sh|update package.json|
|-|yq.sh|yaml edit tool|
|-|scan.sh|security audit tool |
|util|fmt-text.sh|shell text style|
|proto|build-protoc.sh|build code|
|proto|compile.sh|pre compile|

## How to use

```sh
# 直接調用
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/util_scripts/main/notify_slack.sh)"

# 先下載再調用
# -L → --location
# -J → --remote-header-name
# -O → --remote-name
curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/notify_slack.sh 
# ex
./notify_slack.sh -h
...

```

## Demo use scripts by GitHub Actions

### notify_slack.sh

```yaml
      - name: ⚙️ Initialize Google Cloud SDK
        if: allways()
        uses: GoogleCloudPlatform/github-actions/setup-gcloud@master  
        with:
          project_id: #$GCPproject_id
          service_account_email: #"github-ci@email"
          service_account_key: ${{ secrets.GCP_SA_KEY_GITHUB_CI }}
          export_default_credentials: true
          
 # ... some actions

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

### modify_version.sh

```yaml
      - name: Use scripts
        run: |
          echo "Use scripts"
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/util_scripts/main/modify_version.sh)"
```

### compile.sh / build-protoc.sh

```yaml
      - name: Use scripts
        run: |
          echo "Use scripts"
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/compile.sh)"
```

### yq.sh

```yaml
      - name: Use scripts
        run: |
          echo "Use scripts"
          curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/yq.sh 
          # get 
          cat a.yaml | sh yq.sh e '.metadata.name' - 
          # edit 
          cat a.yaml | sh yq.sh e '.metadata.name'="123" - 
```

### scan.sh

```yaml
      - name: Use scripts
        run: |
          echo "Use scripts"
          curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/scan.sh 
          # use 
          scan --type go
```

## Some other util

[csv2md - csv 轉成 md table](https://www.convertcsv.com/csv-to-markdown.htm)
