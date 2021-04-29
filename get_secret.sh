#!/bin/bash

#* help
if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
  cat >&2 <<"EOF"
Description:
  use get secret
USAGE:
  SHELL.sh sql

EXAMPLE:
    SHELL.sh sql

EOF
  exit 1
fi

if [ "$1" == "" ] ; then
    echo " nil , use --help"
    exit 0
fi

case $1 in
    sql)
    secrets=$(gcloud secrets versions access latest --secret=line_token --project=jkf-servers)
    ;;
esac

echo "$secrets"
