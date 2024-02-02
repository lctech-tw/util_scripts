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
lctech-kin)
  SLACKNAME="U06AJTT83QS"
  ;;
LeoLioa)
  SLACKNAME="U0642V9DDMX"
  ;;
lctech-stark)
  SLACKNAME="U069A9CHNTY"
  ;;
lctech-erin)
  SLACKNAME="U03AX65UFH8"
  ;;
allisonkuooo)
  SLACKNAME="U9GLLPYHY"
  ;;
Jacky-lctech)
  SLACKNAME="U03JC9FEXLK"
  ;;
lctechArlen)
  SLACKNAME="U042N9T0G1G"
  ;;
freddie9527)
  SLACKNAME="freddie9527"
  ;;
lctech-Arthur)
  SLACKNAME="U03E4MY00MD"
  ;;
lctech-Marc)
  SLACKNAME="U03E1TAKSMP"
  ;;
lctech-Leo)
  SLACKNAME="U03AGHT74KZ"
  ;;
lctech-coco)
  SLACKNAME="U03EGCNMBDK"
  ;;
irir)
  SLACKNAME="U2BCVHVLG"
  ;;
lctech-daniel-hung)
  SLACKNAME="U04RP3AV02Z"
  ;;
Ninja)
  SLACKNAME="jenkins"
  ;;
Jenkins)
  SLACKNAME="jenkins"
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
  echo "$NAME is not found"
  exit 0
else
  echo "$SLACKNAME"
fi
