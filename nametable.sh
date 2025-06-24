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
andychuang)
  SLACKNAME="U083FFBLPPE"
  ;;
lctech-tree)
  SLACKNAME="U07UBRMAPK7"
  ;;
lctech-kin)
  SLACKNAME="U06AJTT83QS"
  ;;
lctech-adam)
  SLACKNAME="U06T71UMKTL"
  ;;
lctech-LeoLioa)
  SLACKNAME="U0642V9DDMX"
  ;;
lctech-stark)
  SLACKNAME="U069A9CHNTY"
  ;;
lctech-sid)
  SLACKNAME="U07A8E61S4E"
  ;;
lctech-Eddy)
  SLACKNAME="U03AGHT28BZ"
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
lctech-benwu)
  SLACKNAME="D0810A4D207"
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
Ninja)
  SLACKNAME="jenkins"
  ;;
Jenkins)
  SLACKNAME="jenkins"
  ;;
james-lin00)
  SLACKNAME="U2JRDGCUT"
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
freddie9527)
  SLACKNAME="UCKQWSCQ3"
  ;;
lctech-ray)
  SLACKNAME="U02B281CRDL"
  ;;
lctech-hikari)
  SLACKNAME="U034M2BB5QF"
  ;;
lctech-kai)
  SLACKNAME="U02DZMGTKJS"
  ;;
lctech-borg)
  SLACKNAME="U03UEUXRMLM"
  ;;
lctech-aren)
  SLACKNAME="U035E8FNFUH"
  ;;
lctech-kahn)
  SLACKNAME="U052TP95E7K"
  ;;

esac

if [ "$SLACKNAME" == "" ]; then
  echo "$NAME is not found"
  exit 0
else
  echo "$SLACKNAME"
fi
