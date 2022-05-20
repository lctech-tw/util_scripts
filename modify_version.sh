#!/bin/bash
# Purpose: Update package.json
# Author: @lctech-zeki
# Requirments: package.json , jq
# -------------------------------------------------------------------

function _fmt.err() {
    RED='\033[0;31m' # RED
    STD='\033[0m'    # Text Reset
    echo -e "$RED [Error] $* ! $STD" >&2
}

# mock testing
function _testing {
    echo "@ ${FUNCNAME[0]}"
    if [ ! -f ./package.json ]; then
        echo "Create demo package.json ...."
        echo '{"version":"1.2.34"}' >package.json
    #GITHUB_ACTIONS=true
    else
        echo "Has package.json file."
    fi
}

function _Update {
    echo "@ ${FUNCNAME[0]}"
    VERSION_OLD=$(jq <package.json '.version')
    VERSION_OLD_LAST=$(echo "$VERSION_OLD" | cut -f3 -d"." | cut -f1 -d'"')
    VERSION_NEW_LAST=$((VERSION_OLD_LAST + 1))
    VERSION_NEW=$(echo "$VERSION_OLD" | cut -f1,2 -d".")'.'"$VERSION_NEW_LAST"'"'
    echo "🐥 Update Version : $VERSION_OLD_LAST --> $VERSION_NEW_LAST"
    echo "🐥 New Version : $VERSION_NEW"
    cat <<<"$(jq '.version'="$VERSION_NEW" package.json)" >package.json
    # GITHUB_ENV -> github actions use
    if [ "$GITHUB_ACTIONS" ]; then
        echo "TAG_VERSION=""v""$(jq -r '.version' <package.json)" >>"$GITHUB_ENV"
    fi
}
function _RenamePackage {
    echo "@ ${FUNCNAME[0]}"
    NAME_NEW=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
    echo "🐹 New Name : @$NAME_NEW"
    cat <<<"$(jq '.name'='"@'"$NAME_NEW"'"' package.json)" >package.json
}
function _ReleseChangeLog {
    echo "@ ${FUNCNAME[0]}"
    if [ ! -f ./CHANGELOG.md ]; then
        echo "Create CHANGELOG.md ...."
        echo "# $NAME_NEW Changelog" > CHANGELOG.md
    fi
    if [ "$GITHUB_ACTIONS" ]; then
        echo "📚 ChangeLog"
        
        sed -i "" "1s/^/# $NAME_NEW Changelog\n/" CHANGELOG.md
    fi
}

if [ "$1" == "test" ]; then
    _testing
fi
if [ ! -f ./package.json ]; then
    _fmt.err "You need package.json file"
    _fmt.err "Or use test flag"
    exit 88
fi
_Update
echo "==============="
_RenamePackage
#_ReleseChangeLog