#!/bin/bash
# Note : This script is used to download proto files from remote repository
# Download proto files from remote repository

declare FOLDER_PATHS="docs/proto"
_create_folder() {
    if [ ! -d $FOLDER_PATHS ]; then
        mkdir -p $FOLDER_PATHS
    fi
}

_download_doc() {
    echo "Downloading proto files from remote repository"
    mkdir tmp || exit
    grep -v '^ *#' < proto-docs.config | while IFS= read -r line; do
        echo "$line"
        FILENAME=$(echo "$line" | awk -F'/' '{print $NF}')
        git clone "https://github.com/$line.git" --depth 1 tmp/"$FILENAME" || echo "Failed to clone $line"
        sudo cp tmp/"$FILENAME"/README.md "$FOLDER_PATHS"/"$FILENAME".md || echo "Failed to copy README.md"
    done
    sudo rm -rf tmp
}

if [ -f proto-docs.config ]; then
    _create_folder
    _download_doc
else
    echo "'proto-docs.config' not found"
    exit 1
fi
