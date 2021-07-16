#! /bin/bash

#* Need package.json

# mock testing
# echo '{"version":"1.0.21"}' > package.json

function Update() {
    echo "@ UpdateVersion"
    mv package.json origin.package.json
    VERSION_OLD=$(jq <origin.package.json '.version')
    VERSION_OLD_LAST=$(echo "$VERSION_OLD" | cut -f3 -d"." | cut -f1 -d'"')
    VERSION_NEW_LAST=$((VERSION_OLD_LAST + 1))
    VERSION_NEW=$(echo "$VERSION_OLD" | cut -f1,2 -d".")'.'"$VERSION_NEW_LAST"'"'
    echo "🐥 Update Version : $VERSION_OLD_LAST --> $VERSION_NEW_LAST"
    echo "🐥 New Version : $VERSION_NEW"
    cat origin.package.json | jq '.version'=$VERSION_NEW >package.json
    rm origin.package.json
    # GITHUB_ENV ->  github actions use
    echo "TAG_VERSION="v"$(jq -r <package.json '.version')" >> "$GITHUB_ENV"
}
function RenamePackage() {
    echo "@ RenamePackage"
    mv package.json origin.package.json
    NAME_NEW=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
    echo "🐹 New Name : @$NAME_NEW"
    cat origin.package.json | jq '.name'='"@'"$NAME_NEW"'"' >package.json
    rm origin.package.json
}

Update
echo "==============="
RenamePackage