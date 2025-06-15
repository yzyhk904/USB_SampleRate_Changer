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
    function getDRCswitch(fname)
    {
        v=0
        if (system("test -r " fname) > 0)
            return(-1)
        for (;;) {
            r=(getline x < fname)
            if (r < 0)
                retrun(-1)
            else if ( r == 0) {
                v=0
                break
            }
            else {
                if (x ~ /speaker_drc_enabled[:space:]*=[:space:]*\"true\"/) {
                    v=1
                    break
                }
                else if (x ~ /speaker_drc_enabled[:space:]*=[:space:]*\"false\"/) {
                    v=0
                    break
                }
            }
        }
        close(fname)
        return(v)
    }

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
        v=getDRCswitch($3)
        if (v == 1)
            print  " DRC switch: on"
        else if (v == 0)
            print  " DRC switch: off"
    }
    allFlag!=1 &&
    /^  [1-9][0-9]*\. Handle:/ {
        print "\n\n HW module: " $4
    }
    allFlag!=1 &&
    /^    [1-9][0-9]*\. [^{]+\{AUDIO_DEVICE/ {
        print
    }'
