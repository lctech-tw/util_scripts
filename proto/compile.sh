#!/bin/bash

#* Before the event: Need login gcloud service account

# Check out env GITHUB_REPOSITORY
if [ -z "$GITHUB_REPOSITORY" ]; then
    echo "You must define ENV GITHUB_REPOSITORY or run via Github Actions..."
    echo "Try to get GITHUB_REPOSITORY from git config..."
    GITHUB_REPOSITORY=$(git config --get remote.origin.url | sed 's/https:\/\/github.com\///' | sed 's/\.git//')
fi
echo "@ GITHUB_REPOSITORY = $GITHUB_REPOSITORY"

# Check out env COMPILE_MODE
if [ -n "$COMPILE_MODE" ]; then
    # Default -> single-compile
    # Multi -> multi-compile
    if [ "$COMPILE_MODE" == "Multi" ] || [ "$COMPILE_MODE" == "MULITI" ] || [ "$COMPILE_MODE" == "multi" ]; then
        SCRIPT_FILE="build-protoc2.sh"
    elif [ "$COMPILE_MODE" == "v3" ]; then
        SCRIPT_FILE="build-protoc3.sh"
    else
        SCRIPT_FILE="build-protoc.sh"
    fi
    echo "@ ENV / COMPILE_MODE = $COMPILE_MODE : SCRIPT_FILE = $SCRIPT_FILE"
fi

# Download script
curl -sLJO "https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/$SCRIPT_FILE"
curl -sLJO "https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/build-protoc-node.sh"

# Auth
if [ ! "$(whoami)" == "lctech-zeki" ]; then
    # GCP
    gcloud auth activate-service-account docker-puller@lc-shared-res.iam.gserviceaccount.com --key-file=.github/auth/puller.json
    gcloud auth configure-docker -q
    # Docker
    cat <./.github/auth/puller.json | docker login -u _json_key --password-stdin https://asia.gcr.io
fi

# Run build-protoc via docker
docker pull asia.gcr.io/lc-shared-res/proto-compiler:node &
docker pull asia.gcr.io/lc-shared-res/proto-compiler:latest
docker run --rm -v "$(pwd)":/workdir asia.gcr.io/lc-shared-res/proto-compiler:latest ./"$SCRIPT_FILE" build github.com/"$GITHUB_REPOSITORY"
docker run --rm -v "$(pwd)":/workdir asia.gcr.io/lc-shared-res/proto-compiler:node ./build-protoc-node.sh build

# Remove script
rm -f ./build-protoc*
