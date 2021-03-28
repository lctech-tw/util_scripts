#!/bin/bash

#* need login gcloud service account

gcloud auth activate-service-account docker-puller@lc-shared-res.iam.gserviceaccount.com --key-file=puller.json
gcloud auth configure-docker
cat ./.github/auth/puller.json | docker login -u _json_key --password-stdin https://asia.gcr.io
curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/proto/build-protoc.sh
docker pull asia.gcr.io/lc-shared-res/proto-compiler:latest
docker run --rm -v "$(pwd)":/workdir asia.gcr.io/lc-shared-res/proto-compiler:latest ./build-protoc.sh build github.com/"$GITHUB_REPOSITORY"
rm -f build-protoc.sh
