#!/bin/bash

# 初始化變數
NAME=""
SLACKNAME=""

# 顯示說明
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

# 檢查輸入參數
if [ "$1" == "" ]; then
  echo " nil , use --help "
  exit 0
else
  NAME=$1
fi

# 建立 GitHub 名稱到 Slack 名稱的關聯陣列
NAME_TO_SLACK=(
  ["Jordan-lctech"]="jordan"
  ["TreeTzeng"]="U017BFMBZLZ"
  ["lctech-kin"]="U06AJTT83QS"
  ["lctech-adam"]="U06T71UMKTL"
  ["lctech-LeoLioa"]="U0642V9DDMX"
  ["lctech-stark"]="U069A9CHNTY"
  ["lctech-sid"]="U07A8E61S4E"
  ["lctech-Eddy"]="U03AGHT28BZ"
  ["lctech-erin"]="U03AX65UFH8"
  ["allisonkuooo"]="U9GLLPYHY"
  ["Jacky-lctech"]="U03JC9FEXLK"
  ["lctechArlen"]="U042N9T0G1G"
  ["freddie9527"]="freddie9527"
  ["lctech-Arthur"]="U03E4MY00MD"
  ["lctech-Marc"]="U03E1TAKSMP"
  ["lctech-Leo"]="U03AGHT74KZ"
  ["lctech-coco"]="U03EGCNMBDK"
  ["irir"]="U2BCVHVLG"
  ["lctech-daniel-hung"]="U04RP3AV02Z"
  ["Ninja"]="jenkins"
  ["Jenkins"]="jenkins"
  ["james-lin00"]="james"
  ["lct-ponywu"]="ponywu"
  ["miko0628"]="miko"
  ["sheepLctech"]="sheep"
  ["benbenyo"]="U023H76SW2X"
  ["lctech-Neil"]="U02BSH1Q3FY"
)

# 根據輸入的 GitHub 名稱查找 Slack 名稱
if [[ "$NAME" =~ ^lctech-(.*) ]]; then
  # 如果 GitHub 名稱以 "lctech-" 開頭
  SLACKNAME="${NAME_TO_SLACK[lctech-${BASH_REMATCH[1]}]}"
elif [[ "$NAME" =~ (.*)-lctech ]]; then
  # 如果 GitHub 名稱以 "-lctech" 結尾
  SLACKNAME="${NAME_TO_SLACK[${BASH_REMATCH[1]}-lctech]}"
else
  # 如果 GitHub 名稱直接存在於關聯陣列中
  SLACKNAME="${NAME_TO_SLACK[$NAME]}"
fi
