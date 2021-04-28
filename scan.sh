#! /bin/bash

#https://slscan.io/en/latest/
# Use -> scan --type go

scan() {
    docker run --rm -e "WORKSPACE=$(pwd)" -e GITHUB_TOKEN -v "$(pwd):/app" shiftleft/scan scan $*
}