# template

```sh
# help
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

```sh
# flag
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
#sh ./this.sh -a=aaa -b=bbb 123
#VAR1  = aaa
#VAR2  = bbb
#TF    =  
#123

```
