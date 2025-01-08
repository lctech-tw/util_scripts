#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    -p | --param) # example named parameter
      param="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${param-}" ]] && die "Missing required parameter: param"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

# PROGRESS start
CURRENT_PROGRESS=0
function _delay()
{
    sleep 0.01;
}
function _progress()
{
    PARAM_PROGRESS=$1;
    PARAM_PHASE=$2;
    if [ "$CURRENT_PROGRESS" -le 0 ] && [ "$PARAM_PROGRESS" -ge 0 ]  ; then echo -ne "[..........................] (0%)  $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 5 ] && [ "$PARAM_PROGRESS" -ge 5 ]  ; then echo -ne "[#.........................] (5%)  $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 10 ] && [ "$PARAM_PROGRESS" -ge 10 ]; then echo -ne "[##........................] (10%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 15 ] && [ "$PARAM_PROGRESS" -ge 15 ]; then echo -ne "[###.......................] (15%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 20 ] && [ "$PARAM_PROGRESS" -ge 20 ]; then echo -ne "[####......................] (20%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 25 ] && [ "$PARAM_PROGRESS" -ge 25 ]; then echo -ne "[#####.....................] (25%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 30 ] && [ "$PARAM_PROGRESS" -ge 30 ]; then echo -ne "[######....................] (30%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 35 ] && [ "$PARAM_PROGRESS" -ge 35 ]; then echo -ne "[#######...................] (35%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 40 ] && [ "$PARAM_PROGRESS" -ge 40 ]; then echo -ne "[########..................] (40%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 45 ] && [ "$PARAM_PROGRESS" -ge 45 ]; then echo -ne "[#########.................] (45%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 50 ] && [ "$PARAM_PROGRESS" -ge 50 ]; then echo -ne "[##########................] (50%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 55 ] && [ "$PARAM_PROGRESS" -ge 55 ]; then echo -ne "[###########...............] (55%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 60 ] && [ "$PARAM_PROGRESS" -ge 60 ]; then echo -ne "[############..............] (60%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 65 ] && [ "$PARAM_PROGRESS" -ge 65 ]; then echo -ne "[#############.............] (65%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 70 ] && [ "$PARAM_PROGRESS" -ge 70 ]; then echo -ne "[###############...........] (70%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 75 ] && [ "$PARAM_PROGRESS" -ge 75 ]; then echo -ne "[#################.........] (75%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 80 ] && [ "$PARAM_PROGRESS" -ge 80 ]; then echo -ne "[####################......] (80%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 85 ] && [ "$PARAM_PROGRESS" -ge 85 ]; then echo -ne "[#######################...] (85%) $PARAM_PHASE \r"  ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 90 ] && [ "$PARAM_PROGRESS" -ge 90 ]; then echo -ne "[##########################] (100%) $PARAM_PHASE \r" ; _delay; fi;
    if [ "$CURRENT_PROGRESS" -le 100 ] && [ "$PARAM_PROGRESS" -ge 100 ];then echo -ne 'Done!                                            \n' ; _delay; fi;

    CURRENT_PROGRESS=$PARAM_PROGRESS;
}

echo "The task is in progress, please wait a few seconds"

#Do some tasks
_progress 10 Initialize
#Do some tasks
_progress 20 "Phase 1      "
#Do some tasks
_progress 40 "Phase 2      "
#Do some tasks
_progress 60 "Processing..."
#Do some tasks
_progress 80 "Processing..."
#Do some tasks
_progress 90 "Processing..."
#Do some tasks
_progress 100 "Done        "

# PROGRESS end

parse_params "$@"
setup_colors

# script logic here

msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"