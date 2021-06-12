#!/bin/bash

#* need login gcloud service account

# download script
curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/build-protoc.sh
# GCP login
if [ ! "$(whoami)" == "lctech-zeki" ] ;then
gcloud auth activate-service-account docker-puller@lc-shared-res.iam.gserviceaccount.com --key-file=.github/auth/puller.json
gcloud auth configure-docker
fi
# docker login
cat ./.github/auth/puller.json | docker login -u _json_key --password-stdin https://asia.gcr.io
docker pull asia.gcr.io/lc-shared-res/proto-compiler:latest
# docker run
docker run --rm -v "$(pwd)":/workdir asia.gcr.io/lc-shared-res/proto-compiler:latest ./build-protoc.sh build github.com/"$GITHUB_REPOSITORY"
rm -f build-protoc.sh
