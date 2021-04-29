#!/bin/bash

#https://mikefarah.gitbook.io/yq/
# Use ->  cat a.yaml | sh yq.sh e '.metadata.name' -  

yq-docker-run() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}

yq-docker-run "$@"