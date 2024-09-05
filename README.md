# util_scripts

|Path|Name|Desc|
|-|-|-|
|-|notify_slack.sh|Notify slack use|
|-|modify_version.sh|update package.json version and package name|
|-|yq.sh|yaml edit tool|
|-|scan.sh|security audit tool |
|util|fmt-text.sh|shell text style|
|proto|build-protoc.sh|build code|
|proto|compile.sh|pre compile|
|proto|dependent-proto.sh|download dependent proto|

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
      - name: ⚙️ Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json:  ${{secrets.GCP_SA_KEY_GITHUB_CI}}
      - name: ⚙️ Initialize Google Cloud SDK
        if: always()
        uses: google-github-actions/setup-gcloud@v2
 # ... some actions

      - name: Slack Notification
        if: always()
        run: |
          curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/notify_slack.sh 
          if [[ '${{job.status}}' == 'failure' ]] ;then
            echo "Run slack on Fail (X)"
            bash ./notify_slack.sh -f
          else
            echo "Run slack on Success (O)"
            bash ./notify_slack.sh -s
          fi
```

### modify_version.sh

```yaml
      - name: Use scripts
        run: |
          echo "Use scripts"
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/util_scripts/main/modify_version.sh)"
```

### changelog.sh

```yaml
      - name: Use scripts
        run: |
          echo "Use changelog"
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/util_scripts/main/changelog.sh)"
```

### compile.sh / build-protoc.sh

```yaml
      - name: Use scripts
        run: |
          echo "Use scripts"
          # old 
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/compile.sh)"
          # new
          COMPILE_MODE="Multi" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/compile2.sh)"

```

### yq.sh

```yaml
      - name: Use scripts
        run: |
          echo "Use scripts"
          curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/yq.sh 
          # get 
          cat a.yaml | bash yq.sh e '.metadata.name' - 
          # edit 
          cat a.yaml | bash yq.sh e '.metadata.name'="123" - 
```

### scan.sh

```yaml
      - name: Use scripts
        run: |
          echo "Use scripts"
          curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/scan.sh 
          # use 
          sh scan.sh --type go
```

## Some other util

[csv2md - csv 轉成 md table](https://www.convertcsv.com/csv-to-markdown.htm)
