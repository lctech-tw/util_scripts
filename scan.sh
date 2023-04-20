#!/bin/bash
# Purpose: scan code
# Author: zeki@lctech.com.tw
# Requirments: Docekr
# -------------------------------------------------------------------
# Usage:
# scan.sh --type go
# -------------------------------------------------------------------
# Notes:
# Ref: https://slscan.io/en/latest/
# -------------------------------------------------------------------

scan-docker-run() {
    docker run --rm -e "WORKSPACE=$(pwd)" -e GITHUB_TOKEN -v "$(pwd):/app" shiftleft/scan scan $*
}

scan-docker-run "$@"