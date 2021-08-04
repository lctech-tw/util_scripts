#! /bin/bash
# Purpose: Update package.json
# Author: @lctech-zeki
# Requirments: package.json , jq
# -------------------------------------------------------------------

# mock testing
function testing() {
    echo "@ ${FUNCNAME[0]}"
    if [ ! -f ./package.json ] ; then
    echo '{"version":"1.0.21"}' >package.json
    #GITHUB_ACTIONS=true
    fi
}

function Update() {
    echo "@ ${FUNCNAME[0]}"
    VERSION_OLD=$(jq <package.json '.version')
    VERSION_OLD_LAST=$(echo "$VERSION_OLD" | cut -f3 -d"." | cut -f1 -d'"')
    VERSION_NEW_LAST=$((VERSION_OLD_LAST + 1))
    VERSION_NEW=$(echo "$VERSION_OLD" | cut -f1,2 -d".")'.'"$VERSION_NEW_LAST"'"'
    echo "🐥 Update Version : $VERSION_OLD_LAST --> $VERSION_NEW_LAST"
    echo "🐥 New Version : $VERSION_NEW"
    cat <<< "$(jq '.version'="$VERSION_NEW" package.json)" > package.json
    # GITHUB_ENV -> github actions use
    if [ "$GITHUB_ACTIONS" ]; then
        echo "TAG_VERSION=""v""$(jq -r '.version' <package.json)" >>"$GITHUB_ENV"
    fi
}
function RenamePackage() {
    echo "@ ${FUNCNAME[0]}"
    NAME_NEW=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
    echo "🐹 New Name : @$NAME_NEW"
    cat <<< "$(jq '.name'='"@'"$NAME_NEW"'"' package.json)" > package.json
}

Update
echo "==============="
RenamePackage
