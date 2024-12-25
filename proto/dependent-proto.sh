#!/bin/bash
# Purpose: download_github_proto_folder
CONFIG_PATH="./src/dependent.config"

# create config file if not exists
function _create_external_proto_folder() {
    echo "Creating external proto folder"
    if ! [ -d ./external/ ]; then
        mkdir ./external
        echo "@ No exist external folder"
    fi
    echo "@ Exist external folder"
}
# download_github_proto_folder lctech-tw/example-proto
function _download_github_proto_folder() {
    GIHUB_PREFIX=https://github.com
    GIHUB_ORGS="$1"
    GITHUB_PROTO="$2"
    #* create_external_proto_folder
    _create_external_proto_folder
    mkdir ./external/tmp_"$GITHUB_PROTO"
    cd ./external/tmp_"$GITHUB_PROTO" || exit
    #* download proto
    git init && git remote add origin -f "$GIHUB_PREFIX/$GIHUB_ORGS/$GITHUB_PROTO"
    git config core.sparseCheckout true
    echo "/src/*" >.git/info/sparse-checkout
    #* push master / main
    git pull origin master --ff-only || git pull origin main --ff-only
    #* copy git repo to external folder
    rm -rf ../"$GITHUB_PROTO/"
    cp -r ../tmp_"$GITHUB_PROTO"/src/* ../
    cd ../../
    rm -rf tmp_"$GITHUB_PROTO" ./external/tmp_"$GITHUB_PROTO"
}

#* check has space in lastline
if [[ -n $(tail -1 "$CONFIG_PATH") ]]; then
    echo "" >>"$CONFIG_PATH"
fi

cat <"$CONFIG_PATH" | while read -r line; do
    #* pass null line and has '#'
    if [[ -n $line ]] && ! [[ $line =~ '#' ]]; then
        echo "🦄 $line "
        _download_github_proto_folder "$(echo "$line" | cut -d '/' -f 1)" "$(echo "$line" | cut -d '/' -f 2)"
    fi
done
