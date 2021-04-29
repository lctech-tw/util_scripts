# template

## bash

### title

```sh
#!/bin/bash
# Purpose: text
# Author: @lctech-zeki
# Requirments: text
# -------------------------------------------------------------------
```

### help

```sh
if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
  cat >&2 <<"EOF"
Description:
  OOXX
USAGE:
  SHELL.sh [A] [B]
EXAMPLE
  SHELL.sh A B

EOF
  exit 1
fi
```

### flag

```sh
for i in "$@"
do
case $i in
    -a=*|--VAR1=*)
    VAR1="${i#*=}"
    shift # past argument=value
    ;;
    -b=*|--VAR2=*)
    VAR2="${i#*=}"
    shift 
    ;;
    --TF)
    TF=YES
    shift 
    ;;
    *)
    ;;
esac
done
echo "VAR1  = ${VAR1}"
echo "VAR2  = ${VAR2}"
echo "TF    =   ${TF}"
if [[ -n $1 ]]; then
    echo "$1"
fi
#DEMO# sh ./this.sh -a=aaa -b=bbb 123
#VAR1  = aaa
#VAR2  = bbb
#TF    =  
#123
```

```sh
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
    -V | --version )
    echo $version
    exit
    ;;
    -s | --string )
    shift; string=$1
    ;;
    -f | --flag )
    flag=1
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi
```

### array

```sh
#!/bin/bash
array[0]="file1.sdf"
array[1]="file2.sdf"
array[2]="file3.sdf"
size=${#array[@]}
index=$(($RANDOM % $size))
echo ${array[$index]}
for((i=0; i<${#array[@]}; i++))
do
        echo ${array[i]}
done
```

```sh
arr[0]="0"
arr[1]="1"
rand=$((RANDOM % ${#arr[@]}))
echo "${arr[$rand]}"
```

### get_week_num

```sh
if [ "$(date '+%u')" = 1 ] ; then
echo "1 => today is monday"
fi
```

```sh
case  "$(date '+%u')" in
    1)
    echo "today is monday"
    ;;
esac
```

### trap

```sh
#!/bin/bash
trap "echo TRAP!!; exit" SIGTERM SIGINT SIGHUP

for (( i=0; i<5; i=i+1 ))
do
    echo $i
    sleep 1
done
```
