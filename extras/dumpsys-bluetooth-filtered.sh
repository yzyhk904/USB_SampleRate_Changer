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

dumpsys bluetooth_manager | sed -e '/^Bluetooth Status/,/^A2DP State:/d' -e '/^A2DP Sink State:/,$d' \
    | awk -v allFlag=$allFlag '
        BEGIN {
            RS=""
            FS="\n"
            printFlag=1
            if (allFlag == 1)
                print "A2DP State:"
        }
        allFlag==1 || (printFlag==1 && /\n  Config: Rate/) {
            print $0 "\n"
            if (allFlag == 0)
                printFlag=0
        }'
