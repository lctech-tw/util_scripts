#!/bin/bash
curDate=""
commitMessageList=$(git log --date=format:'%Y-%m-%d' --pretty=format:'%cd%n%s')
index=0
FILE_NAME="CHANGELOG.md"
# solve the space by IFS
IFS=$(echo -en "\n\b")
echo -en "$IFS"

if [ -f "CHANGELOG.md" ]; then
    rm -f CHANGELOG.md
    echo -e "# CHANGELOG.md\n" >>$FILE_NAME
else
    echo -e "# CHANGELOG.md\n" >>$FILE_NAME
fi

function checkLog() {
    if [[ $1 == "feat"* ]]; then
        feat[featIndex]=$1
        ((featIndex++))
    elif [[ $1 == "fix"* ]]; then
        fix[fixIndex]=$1
        ((fixIndex++))
    elif [[ $1 == "refact"* ]]; then
        refact[refactIndex]=$1
        ((refactIndex++))
    else
        other[otherIndex]=$1
        ((otherIndex++))
    fi
}

function printLog() {
    array=("feat" "refact" "fix" "other")
    #* gs = git status
    #* sgs = sub git status
    for ((gs = 0; gs < ${#array[@]}; gs++)); do
        if [[ "${array[gs]}Index" -ne 0 ]]; then
            echo -e "### ${array[gs]}\n" >>$FILE_NAME
            subarray="${array[gs]}[@]"
            for sgs in "${!subarray}"; do
                echo "- ${sgs}" >>$FILE_NAME
            done
            echo >>$FILE_NAME
        fi
        declare -a "${array[gs]}"
        declare "${array[gs]}Index"=0
    done
}

function checkDate() {
    if [[ $curDate = "$1" ]]; then
        return
    fi
    curDate=$1
    printLog
    echo -e "## ""$curDate\n" >>$FILE_NAME
}

for i in ${commitMessageList[@]}; do
    if [[ $index%2 -eq 0 ]]; then
        checkDate "$i"
    else
        checkLog "$i"
    fi
    ((index++))
done

printLog
