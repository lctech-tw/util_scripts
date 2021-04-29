#!/bin/bash

# how to use
# ----------
# #!/bin/bash
# . ../util/fmt-text.sh --source-only
# fmt.bold "msg"

GREEN='\033[0;32m'  # Green
RED='\033[0;31m'    # RED
YELLOW='\033[0;33m' # Yellow
PURPLE='\033[0;35m' # Purple
STD='\033[0m'       # Text Reset

fmt.bold() {
    echo -e "$PURPLE > $(tput bold)" "$*" "$(tput sgr0) $STD"
}
fmt.succ() {
    echo -e "$GREEN [Success] $* ! $STD"
}
fmt.info() {
    echo -e "$YELLOW [Info] $* ! $STD"
}
fmt.err() {
    echo -e "$RED [Error] $* ! $STD" >&2
}
