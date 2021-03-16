#!/bin/bash

#* Delete your GCP Google Container Registry images 
IFS=$'\n\t'
set -eou pipefail

if [[ "$#" -ne 2 || "${1}" == '-h' || "${1}" == '--help' ]]; then
  cat >&2 <<"EOF"
Description:
  Delete your GCP Google Container Registry images 
USAGE:
  SHELL.sh [REPOSITORY] [DATE]
EXAMPLE
  SHELL.sh asia.gcr.io/apple/my-app 2020-11-01
   > 刪除 2020-11-01 前的鏡像檔案

EOF
  exit 1
elif [[ "${#2}" -ne 10 ]]; then
  echo "wrong DATE format; use YYYY-MM-DD." >&2
  exit 1
fi

main(){
  local C=0
  IMAGE="${1}"
  DATE="${2}"
  for digest in $(gcloud container images list-tags ${IMAGE} --limit=999999 --sort-by=TIMESTAMP \
    --filter="timestamp.datetime < '${DATE}'" --format='get(digest)'); do
    (
      set -x
      gcloud container images delete -q --force-delete-tags "${IMAGE}@${digest}"
    )
    ((C=C+1))
  done
  echo ""
  echo " 🐈 Done ! Deleted ${C} images in ${IMAGE} by ${DATE} ." >&2
  echo ""
}

main "${1}" "${2}"
