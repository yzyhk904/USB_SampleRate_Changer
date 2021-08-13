#!/system/bin/sh

allFlag=0
if [ $# -gt 0 ];then
  case "$1" in
    "-a" | "--all" )
      allFlag=1
      ;;
    "-h" | "--help" )
      echo "Usage: ${0##*/} [--all][--help]" 1>&2
      exit 0
      ;;
    * )
      echo "wrong argument ($1)" 1>&2
      echo "Usage: ${0##*/} [--all][--help]" 1>&2
      exit 1
      ;;
  esac
fi

dumpsys media.audio_policy | awk -v allFlag=$allFlag ' 
 allFlag==1 ||
  /^ Config source: / ||
  /^- HW Module / ||
  /^  - name: /  {
     print
  }' 
