#!/bin/bash

NAME=""
SLACKNAME=""

#* help
if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
  cat >&2 <<"EOF"
Description:
  Use github account look for slack name
USAGE:
  SHELL.sh $NAME

EXAMPLE:
    SHELL.sh lctech-zeki

EOF
  exit 1
fi

if [ "$1" == "" ]; then
  echo " nil , use --help "
  exit 0
else
  NAME=$1
fi

# remove 開頭 & 結尾 lctech
[[ "$1" =~ ^lctech- ]] && SLACKNAME="${NAME/lctech-/}"
[[ "$1" =~ -lctech ]] && SLACKNAME="${NAME/-lctech/}"

case $NAME in
Jordan-lctech)
  SLACKNAME="jordan"
  ;;
TreeTzeng)
  SLACKNAME="U017BFMBZLZ"
  ;;
allisonkuooo)
  SLACKNAME="U9GLLPYHY"
  ;;
freddie9527)
  SLACKNAME="freddie9527"
  ;;
irir)
  SLACKNAME="U2BCVHVLG"
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
benbenyo)
  SLACKNAME="U023H76SW2X"
  ;;
lctech-Neil)
  SLACKNAME="U02BSH1Q3FY"
  ;;
esac

if [ "$SLACKNAME" == "" ]; then
  echo " ( ˘•ω•˘ ) who is $NAME "
  exit 0
else
  echo "$SLACKNAME"
fi
