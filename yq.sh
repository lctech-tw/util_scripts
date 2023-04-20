#!/bin/bash
# Purpose: Use yq to parse yaml
# Author: zeki@lctech.com.tw
# Requirments: Docekr
# -------------------------------------------------------------------
# Usage:
# cat a.yaml | sh yq.sh e '.metadata.name' -  
# -------------------------------------------------------------------
# Notes:
# Ref: https://mikefarah.gitbook.io/yq/
# -------------------------------------------------------------------

yq-docker-run() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}

yq-docker-run "$@"