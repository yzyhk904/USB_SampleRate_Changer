#!/system/bin/sh

period_us=4000

resetFlag=0

function usage()
{
    echo "Usage: ${0##*/} [--help] [--status] [--reset] [period_usec]" 1>&2
    echo "  (default: 4000 usec)" 1>&2
}

function which_resetprop_command()
{
    type resetprop 1>"/dev/null" 2>&1
    if [ $? -eq 0 ]; then
        echo "resetprop"
    else
        type resetprop_phh 1>"/dev/null" 2>&1
        if [ $? -eq 0 ]; then
            echo "resetprop_phh"
        else
            return 1
        fi
    fi
    return 0
}

function reloadAudioserver()
{
    # wait for system boot completion and audiosever boot up
    local i
    for i in `seq 1 3` ; do
      if [ "`getprop sys.boot_completed`" = "1"  -a  "`getprop init.svc.audioserver`" = "running" ]; then
        break
      fi
      sleep 0.9
    done

    if [ "`getprop init.svc.audioserver`" = "running" ]; then
        setprop ctl.restart audioserver
        if [ $? -gt 0 ]; then
            echo "audioserver reload failed!" 1>&2
            return 1
        else
            return 0
        fi
    else
        echo "audioserver is not running!" 1>&2
        return 1
    fi
}

function PrintStatus()
{
    if [ $# -eq 1 ]; then
        echo "USB driver's transfer property:" 1>&2
        if [ -n "$1" ]; then
            echo "  period = $1 usec" 1>&2
        fi
    fi
}

function AudioDriverStatus()
{
    local val
    val="`getprop ro.audio.usb.period_us`"
    if [ -n "$val" ]; then
        PrintStatus "$val"
    else
        PrintStatus 5000
    fi
}

while [ $# -gt 0 ]; do
    case "$1" in
        "-s" | "--status" )
            AudioDriverStatus
            exit 0
            ;;
        "-r" | "--reset" )
            resetFlag=1
            shift
            ;;
        "-h" | "--help" | -* )
            usage
            exit 0
            ;;
        * )
            break
            ;;
    esac
done

if [ $# -ge 1 ]; then
     if expr "$1" : "[1-9][0-9]*$" 1>"/dev/null" 2>&1; then
        
        if [ $1 -lt 125  -o  $1 -gt 50000 ]; then
            echo "unsupported transfer period ($1; valid: 125~50000 usec)!" 1>&2
            usage
            exit 1
        else
            period_us="`expr $1 / 125 \* 125`"
        fi
        
    else
        
        echo "unsupported transfer period ($1; valid: 125~50000 usec)!" 1>&2
        usage
        exit 1
        
    fi
fi

resetprop_command="`which_resetprop_command`"
if [ -n "$resetprop_command" ]; then
    if [ $resetFlag -gt 0 ]; then
        "$resetprop_command" --delete ro.audio.usb.period_us 1>"/dev/null" 2>&1
    else
        "$resetprop_command" "ro.audio.usb.period_us" "$period_us" 1>"/dev/null" 2>&1
    fi
    reloadAudioserver
else
    echo "cannot change the USB transfer period (no resetprop commands found)" 1>&2
    exit 1
fi

AudioDriverStatus
exit 0
