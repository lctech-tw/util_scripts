#!/bin/bash
# Script to map GitHub usernames to Slack IDs

declare NAME=""
declare SLACK_NAME=""

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

if [ -z "$1" ]; then
  echo "Error: No argument provided, use --help "
  exit 0
else
  NAME=$1
fi

# remove 開頭 & 結尾 lctech
[[ "$1" =~ ^lctech- ]] && SLACK_NAME="${NAME/lctech-/}"
[[ "$1" =~ -lctech ]] && SLACK_NAME="${NAME/-lctech/}"

case $NAME in
lctech-andychuang)
  SLACK_NAME="U083FFBLPPE"
  ;;
lctech-york)
  SLACK_NAME="U098UHVUAQ3"
  ;;
lctech-tree)
  SLACK_NAME="U07UBRMAPK7"
  ;;
lctech-kin)
  SLACK_NAME="U06AJTT83QS"
  ;;
lctech-adam)
  SLACK_NAME="U06T71UMKTL"
  ;;
lctech-LeoLioa)
  SLACK_NAME="U0642V9DDMX"
  ;;
lctech-stark)
  SLACK_NAME="U069A9CHNTY"
  ;;
lctech-sid)
  SLACK_NAME="U07A8E61S4E"
  ;;
lctech-Eddy)
  SLACK_NAME="U03AGHT28BZ"
  ;;
lctech-erin)
  SLACK_NAME="U03AX65UFH8"
  ;;
allisonkuooo)
  SLACK_NAME="U9GLLPYHY"
  ;;
Jacky-lctech)
  SLACK_NAME="U03JC9FEXLK"
  ;;
lctech-Arthur)
  SLACK_NAME="U03E4MY00MD"
  ;;
lctech-benwu)
  SLACK_NAME="D0810A4D207"
  ;;
lctech-Leo)
  SLACK_NAME="U03AGHT74KZ"
  ;;
irir)
  SLACK_NAME="U2BCVHVLG"
  ;;
Ninja)
  SLACK_NAME="jenkins"
  ;;
Jenkins)
  SLACK_NAME="jenkins"
  ;;
james-lin00)
  SLACK_NAME="U2JRDGCUT"
  ;;
lct-ponywu)
  SLACK_NAME="ponywu"
  ;;
sheepLctech)
  SLACK_NAME="sheep"
  ;;
benbenyo)
  SLACK_NAME="U023H76SW2X"
  ;;
freddie9527)
  SLACK_NAME="UCKQWSCQ3"
  ;;
lctech-ray)
  SLACK_NAME="U02B281CRDL"
  ;;
lctech-hikari)
  SLACK_NAME="U034M2BB5QF"
  ;;
lctech-kai)
  SLACK_NAME="U02DZMGTKJS"
  ;;
lctech-borg)
  SLACK_NAME="U03UEUXRMLM"
  ;;
lctech-aren)
  SLACK_NAME="U035E8FNFUH"
  ;;
lctech-jay-hsieh)
  SLACK_NAME="U09KARWQQHY"
  ;;
lctech-kahn)
  SLACK_NAME="U052TP95E7K"
  ;;

esac

if [ "$SLACK_NAME" == "" ]; then
  echo "$NAME is not found"
  exit 0
else
  echo "$SLACK_NAME"
fi
