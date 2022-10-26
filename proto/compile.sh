#!/bin/bash

#* need login gcloud service account

# check out env GITHUB_REPOSITORY
if [ -z "$GITHUB_REPOSITORY" ]; then
    echo "You must define ENV GITHUB_REPOSITORY or run via github action."
    echo "建議通過 github action 執行"
    GITHUB_REPOSITORY=$(git config --get remote.origin.url | sed 's/https:\/\/github.com\///' | sed 's/\.git//')
fi
echo "GITHUB_REPOSITORY = $GITHUB_REPOSITORY"

# Multi -> multi-compile
# Default -> old s
# Use COMPILE_MODE="Multi"
if [ -n "$COMPILE_MODE" ]; then
    echo "@ ENV / COMPILE_MODE = $COMPILE_MODE"
    echo " ------------------------------ "
fi
if [ "$COMPILE_MODE" == "Multi" ] || [ "$COMPILE_MODE" == "MULITI" ] || [ "$COMPILE_MODE" == "multi" ]; then
    SCRIPT_FILE="build-protoc2.sh"
    echo "🦅 -- Multi mode / $SCRIPT_FILE --"
elif [ "$COMPILE_MODE" == "v3" ]; then
    SCRIPT_FILE="build-protoc3.sh"
    echo "🦅 -- Multi mode / $SCRIPT_FILE --"
else
    SCRIPT_FILE="build-protoc.sh"
    echo "🦅 -- Default mode / $SCRIPT_FILE --"
fi

# Download script
curl -sLJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/$SCRIPT_FILE
curl -sLJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/build-protoc-node.sh

# Auth
if [ ! "$(whoami)" == "lctech-zeki" ]; then
    # GCP
    gcloud auth activate-service-account docker-puller@lc-shared-res.iam.gserviceaccount.com --key-file=.github/auth/puller.json
    gcloud auth configure-docker
    # Docker
    cat <./.github/auth/puller.json | docker login -u _json_key --password-stdin https://asia.gcr.io
    docker pull asia.gcr.io/lc-shared-res/proto-compiler:latest
fi

# Run build-protoc via docker
docker pull asia.gcr.io/lc-shared-res/proto-compiler:node &
docker run --rm -v "$(pwd)":/workdir asia.gcr.io/lc-shared-res/proto-compiler:latest ./$SCRIPT_FILE build github.com/"$GITHUB_REPOSITORY"
docker run --rm -v "$(pwd)":/workdir asia.gcr.io/lc-shared-res/proto-compiler:node ./build-protoc-node.sh build

# Remove script
rm -f ./build-protoc*
