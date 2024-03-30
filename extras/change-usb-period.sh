#!/system/bin/sh

period_us=2250

resetFlag=0

function usage()
{
    echo "Usage: ${0##*/} [--help] [--status] [--reset] [period_usec]" 1>&2
    echo "  (default: 2250 usec)" 1>&2
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
        if [ "`getprop sys.boot_completed`" = "1"  -a  -n "`getprop init.svc.audioserver`" ]; then
            break
        fi
        sleep 0.9
    done

    if [ -n "`getprop init.svc.audioserver`" ]; then

        setprop ctl.restart audioserver
        sleep 0.2
        if [ "`getprop init.svc.audioserver`" != "running" ]; then
            # workaround for Android 12 old devices hanging up the audioserver after "setprop ctl.restart audioserver" is executed
            local pid="`getprop init.svc_debug_pid.audioserver`"
            if [ -n "$pid" ]; then
                kill -HUP $pid 1>"/dev/null" 2>&1
            fi
            for i in `seq 1 10` ; do
                sleep 0.2
                if [ "`getprop init.svc.audioserver`" = "running" ]; then
                    break
                elif [ $i -eq 10 ]; then
                    echo "audioserver reload failed!" 1>&2
                    return 1
                fi
            done
        fi
        return 0
        
    else
        echo "audioserver is not found!" 1>&2 
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
    val="`getprop vendor.audio.usb.perio`"
    if [ -z "$val" ]; then
        val="`getprop ro.audio.usb.period_us`"
    fi
    if [ -n "$val" ]; then
        PrintStatus "$val"
    elif [ $resetFlag -eq 0 ]; then
        echo "Warning: root permisson is needed for the right answer!" 1>&2
        PrintStatus "5000(?)"
    else
        PrintStatus "5000(?)"
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
        "$resetprop_command" --delete vendor.audio.usb.perio 1>"/dev/null" 2>&1
        "$resetprop_command" --delete vendor.audio.usb.out.period_us 1>"/dev/null" 2>&1
        "$resetprop_command" --delete vendor.audio.usb.out.period_count 1>"/dev/null" 2>&1
        "$resetprop_command" --delete vendor.audio_hal.period_multiplier 1>"/dev/null" 2>&1
    else
        # Workaround for recent Pixel Firmwares (not to reboot when resetprop'ing)
        "$resetprop_command" --delete ro.audio.usb.period_us 1>"/dev/null" 2>&1
        "$resetprop_command" --delete vendor.audio.usb.perio 1>"/dev/null" 2>&1
        "$resetprop_command" --delete vendor.audio.usb.out.period_us 1>"/dev/null" 2>&1
        "$resetprop_command" --delete vendor.audio.usb.out.period_count 1>"/dev/null" 2>&1
        "$resetprop_command" --delete vendor.audio_hal.period_multiplier 1>"/dev/null" 2>&1
        # End of workaround

        "$resetprop_command" "ro.audio.usb.period_us" "$period_us" 1>"/dev/null" 2>&1
        "$resetprop_command" "vendor.audio.usb.perio" "$period_us" 1>"/dev/null" 2>&1
        "$resetprop_command" "vendor.audio.usb.out.period_us" "$period_us" 1>"/dev/null" 2>&1
        "$resetprop_command" "vendor.audio.usb.out.period_count" "2" 1>"/dev/null" 2>&1
        "$resetprop_command" "vendor.audio_hal.period_multiplier" "1" 1>"/dev/null" 2>&1
    fi
    reloadAudioserver
else
    echo "cannot change the USB transfer period (no resetprop commands found)" 1>&2
    exit 1
fi

AudioDriverStatus
exit 0
