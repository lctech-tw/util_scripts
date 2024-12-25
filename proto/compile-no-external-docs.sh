#!/bin/bash

#* Before the event: Need login gcloud service account

# Init color
RED='\033[0;31m'
NC='\033[0m'

# Check out env GITHUB_REPOSITORY
if [ -z "$GITHUB_REPOSITORY" ]; then
    echo "@ Start"
    echo "------------------------------------------------------------------"
    echo -e "You must define ENV: ${RED}GITHUB_REPOSITORY${NC} or run via ${RED}Github Actions${NC}..."
    echo -e "Try to get ${RED}GITHUB_REPOSITORY${NC} from git config..."
    echo "------------------------------------------------------------------"
    GITHUB_REPOSITORY=$(git config --get remote.origin.url | sed 's/git@github.com://' | sed 's/https:\/\/github.com\///' | sed 's/\.git//')
fi
echo -e "@ GITHUB_REPOSITORY = ${RED}$GITHUB_REPOSITORY${NC}"
echo "------------------------------------------------------------------"
# Check out env COMPILE_MODE
# Default -> single-compile
# Multi -> multi-compile
if [ "$COMPILE_MODE" == "Multi" ] || [ "$COMPILE_MODE" == "MULITI" ] || [ "$COMPILE_MODE" == "multi" ]; then
    SCRIPT_FILE="build-protoc2.sh"
elif [ "$COMPILE_MODE" == "v3" ]; then
    SCRIPT_FILE="build-protoc3.sh"
elif [ "$COMPILE_MODE" == "v4" ]; then
    SCRIPT_FILE="build-protoc4.sh"
elif [ "$COMPILE_MODE" == "old" ]; then
    SCRIPT_FILE="build-protoc.sh"
else
    SCRIPT_FILE="build-neo.sh"
fi

# Golang mod
if [ -f go.mod ]; then
    echo "@ Found and remove go.mod"
    rm -f go.mod
    echo "module github.com/$GITHUB_REPOSITORY" > go.mod
    echo "go 1.22" >> go.mod
fi

# Check out env COMPILE_MODE
if [ "$COMPILE_MODE" == "Multi" ] || [ "$COMPILE_MODE" == "MULITI" ] || [ "$COMPILE_MODE" == "multi" ] || [ "$COMPILE_MODE" == "v3" ] || [ "$COMPILE_MODE" == "v4" ] || [ "$COMPILE_MODE" == "old" ]; then
    echo -e "@ ENGINE = ${RED}Default${NC}"
    echo -e "@ ENV / COMPILE_MODE = ${COMPILE_MODE:-Default} : SCRIPT_FILE = ${RED}$SCRIPT_FILE${NC}"
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
else
    echo -e "@ ENGINE = ${RED}Neo mode${NC}"
    # Remove dist folder and copy src to tmp_src
    rm -rf dist
    cp -R src tmp_src
    cd ./src || exit
    # Download buf.yaml and buf.gen.yaml
    if [ ! -f "buf.yaml" ]; then
        curl -sLJO "https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/buf.yaml"
    fi
    if [ ! -f "buf.gen.yaml" ]; then
        curl -sLJO "https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/buf.gen.yaml"
    fi
    mkdir dist
    # # Copy external proto files to src/external
    # if [ -d "../external" ]; then
    #     rsync -av ../external/ ./
    # fi
    docker run --volume "$(pwd):/workspace" --workdir /workspace bufbuild/buf generate
    mv dist ../dist && rm -rf buf.yaml buf.gen.yaml buf.lock
    # Modufy golang path
    sudo mv ../dist/go/github.com/"$GITHUB_REPOSITORY"/dist/go/* ../dist/go/ 
    sudo mv ../dist/go/github.com/"$GITHUB_REPOSITORY"/* ../dist/go/ 
    # Modify README
    sudo mv ../dist/docs/docs.md ../README.md  || { echo "Error moving README"; exit 1; }
    # Remove temp proto files
    sudo rm -rf ../dist/go/github.com/*
    # Restore original src
    cd .. && rm -rf src && mv tmp_src src
fi

echo "@ Done 🎉🎉🎉"
