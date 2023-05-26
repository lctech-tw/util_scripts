#!/bin/bash
# Purpose:
# Author: zeki@lctech.com.tw
# Requirments: Docekr collection
# -------------------------------------------------------------------
# Usage:
# t-docker.sh _drun_psql
# -------------------------------------------------------------------
# Notes:
#
# -------------------------------------------------------------------

function _check_docker() {
    if ! [ -x "$(command -v docker)" ]; then
        echo 'Error: Docker is not installed.' >&2
        exit 1
    fi
}

function _drun_yq() {
    docker run --rm --name d_yq -i \
        -v "${PWD}":/workdir \
        mikefarah/yq "$@"
}

function _drun_scan() {
    docker run --rm --name d_scan \
        -e "WORKSPACE=$(pwd)" -e GITHUB_TOKEN -v "$(pwd):/app" \
        shiftleft/scan scan "$@"
}

function _drun_redis() {
    docker run --rm --name d_redis -itd \
        -p 6379:6379 \
        redis
}

function _drun_psql() {
    docker run --rm --name psql -d \
        -p 5432:5432 \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=12345678 \
        -e POSTGRES_ENCODING=UTF8 \
        -e POSTGRES_LC_ALL=en_US.UTF-8 \
        -e POSTGRES_DB="$1" \
        -v "$PWD"/.github/testing/:/test/ \
        postgres
}

function _dtest() {
    echo "arg:" "${@:2}"
}

# -------------------------------------------------------------------
# Main

_check_docker

case $1 in
_dtest)
    _dtest "$@"
    ;;
_drun_psql)
    _drun_psql "$@"
    ;;
_drun_redis)
    _drun_redis "$@"
    ;;
_drun_scan)
    _drun_scan "$@"
    ;;
*)
    echo "Use --help"
    ;;
esac
