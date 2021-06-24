#! /bin/bash

NAME=""
SLACKNAME=""

#* help
if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
  cat >&2 <<"EOF"
Description:
  use github account look for slack name
USAGE:
  SHELL.sh NAME

EXAMPLE:
    SHELL.sh lctech-zeki

EOF
  exit 1
fi

if [ "$1" == "" ] ; then
    echo " nil , use --help "
    exit 0
    else
    NAME=$1
fi

# lctech- 開頭
prefix="lctech-"
[[ "$1" =~ ^lctech- ]] && SLACKNAME=$(echo $NAME | sed -e "s/^$prefix//")

suffix='-lctech'
[[ "$1" =~ $suffix ]] && SLACKNAME=$(echo $NAME |sed -e "s/$suffix$//")

case $NAME in
    TreeTzeng)
    SLACKNAME="tree"
    ;;
    Allison)
    SLACKNAME="allison"
    ;;
    freddie9527)
    SLACKNAME="freddie9527"
    ;;
    irir)
    SLACKNAME="Irvin Huang"
    ;;
    james-lin00)
    SLACKNAME="james"
    ;;
    lct-ponywu)	
    SLACKNAME="ponywu"
    ;;
    miko0628)
    SLACKNAME="miko"
    ;;
    sheepLctech)
    SLACKNAME="sheep"
    ;;
esac

if [ "$SLACKNAME" == "" ] ; then
    echo " nil , i don't no who is $NAME"
    exit 0
    else
    echo "$SLACKNAME"
fi