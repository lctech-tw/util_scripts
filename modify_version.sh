#! /bin/bash

#* Need package.json

# mock testing
# echo '{"version":"1.0.21"}' >package.json

function Update() {
    mv package.json origin.package.json
    VERSION_OLD=$(jq <origin.package.json '.version')
    VERSION_OLD_LAST=$(echo "$VERSION_OLD" | cut -f3 -d"." | cut -f1 -d'"')
    VERSION_NEW_LAST=$((VERSION_OLD_LAST + 1))
    VERSION_NEW=$(echo "$VERSION_OLD" | cut -f1,2 -d".")'.'"$VERSION_NEW_LAST"'"'
    echo "🐥 Update Version : $VERSION_OLD_LAST ---> $VERSION_NEW_LAST"
    echo "🐥 New Version : $VERSION_NEW"
    echo "TAG_VERSION="v"$(jq -r <package.json '.version')" >> "$GITHUB_ENV"
    cat origin.package.json | jq '.version'=$VERSION_NEW >package.json
    rm origin.package.jsonc
}

Update
