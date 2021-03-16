#! /bin/bash

if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
  cat >&2 <<"EOF"
Description:
  This for loop you'r porj 
USAGE:
  SHELL.sh delete
EXAMPLE
  SHELL.sh delete

EOF
  exit 1
fi

if [ "${1}" == 'delete' ]; then

for proj in $(gcloud projects list | awk 'NR!=1{print $1}'); do
    declare -a arr=("asia.gcr.io" "gcr.io" "us.gcr.io")
    echo "---------$proj---------"
    for location in "${arr[@]}"; do
        echo "$location/$proj"
        gcloud container images list --repository "$location/$proj"

    done
done

fi
