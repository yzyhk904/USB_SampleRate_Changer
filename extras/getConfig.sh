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

dumpsys media.audio_policy | sed -e '/^Supported/,/^$/d' -e '/^ Outputs/,$d' \
    | awk -v allFlag=$allFlag ' 
    allFlag==1 {
        print
    }
    allFlag!=1 &&
    ( /^- HW Module / || /^  - name: / ) {
        print
    }
    allFlag!=1 &&
    /^ Config source: / {
        print  " Config source: \"" $3 "\""
    }
    allFlag!=1 &&
    /^  [1-9][0-9]*\. Handle:/ {
        print "\n\n HW module: " $4
    }
    allFlag!=1 &&
    /^    [1-9][0-9]*\. [^{]+\{AUDIO_DEVICE/ {
        print
    }'
