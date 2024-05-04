#!/system/bin/sh

#  Items                                             Stop_Band_Attenuation   Half_Filter_Length     Cut_Off_Percent or Stop_Band_Cheat (% of Nyquist freq.)
# -- AOSP standard parameters --
#   DYN_LOW_QUALITY(5):                               80dB                              8                          100
#   DYN_MEDIUM_QUALITY(6):                          84dB                            16                          100
#   AOSP default (>=48kHz):                             90dB                            32                          100   (options: --bypass)
#   DYN_HIGH_QUALITY(7):                              98dB                             32                         100
#
#  -- Recommended parameters --
#   This script's default (for old Androids):          160dB                          480                            91
#   For low perf Android 12+ (in general):         167dB                          368                          106   (options: --bypass --cheat)
#   For Android 12+ (in general):                      179dB                          408                            99   (options:  --cheat)
#   For bit perfect when 1:1 ratio:                     194dB                          520                          100
#
#  -- My mock series --
#   Mock DAC-A over-sampling:                        150dB                            48                          109   (options: --bypass --cheat)
#   Mock DAC-B over-sampling:                        118dB                            40                            96
#   Mock mastering filter:                                 159dB                           240                            99   (options: --cheat)
#

stopBand=160
filterLength=480
cutOffPercent=91

resetFlag=0
bypassFlag=0
cheatFlag=0

function usage()
{
    echo "Usage: ${0##*/} [--help] [--status] [--reset] [--bypass] [--cheat] [stop_band_dB [half_filter_length [cut_off_percent]]]" 1>&2
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
    if [ $# -eq 5 ]; then
        echo "AudioFlinger's current resampling configuration:" 1>&2
        if [ -n "$2" ]; then
            echo "  Effective Freq. (kHz) >= : $2" 1>&2
        fi
        if [ -n "$3" ]; then
            echo "  Stop Band (dB): $3" 1>&2
        fi
        if [ -n "$4" ]; then
            echo "  Half Filter Length: $4" 1>&2
        fi
        if [ -n "$5" ]; then
            if [ "$1" = "cheat" ]; then
                echo "  Cheat (% Nyquist freq.): $5" 1>&2
            else
                echo "  Cut Off (% Nyquist freq.): $5" 1>&2
            fi
        fi
    fi
}

function AudioFlingerStatus()
{
    local val1 val2 val3 val4
    val1="`getprop ro.audio.resampler.psd.enable_at_samplerate`"
    if [ -n "$val1" ]; then
        val1=`echo "scale=1; $val1 / 1000.0" | bc`
        val2="`getprop ro.audio.resampler.psd.stopband`"
        val3="`getprop ro.audio.resampler.psd.halflength`"
        val4="`getprop ro.audio.resampler.psd.tbwcheat`"
        if [ -n "$val4" -a "$val4" -gt 0 ]; then
            PrintStatus "cheat" "$val1" "$val2" "$val3" "$val4"
        else
            val4="`getprop ro.audio.resampler.psd.cutoff_percent`"
            PrintStatus "cut-off" "$val1" "$val2" "$val3" "$val4"
        fi
    else
        PrintStatus "cut-off" 48.0 90 32 100
    fi
}

while [ $# -gt 0 ]; do
    case "$1" in
        "-s" | "--status" )
            AudioFlingerStatus
            exit 0
            ;;
        "-r" | "--reset" )
            resetFlag=1
            shift
            ;;
        "-b" | "--bypass" )
            bypassFlag=1
            shift
            ;;
        "-c" | "--cheat" )
            cheatFlag=1
            cutOffPercent=100
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
        
        if [ $1 -lt 20  -o  $1 -gt 242 ]; then
            echo "unsupported stop band dB ($1; valid: 20~242)!" 1>&2
            usage
            exit 1
        else
            stopBand="$1"
            if [ $stopBand -le 60 ]; then
                filterLength=72
            elif [ $stopBand -le 84 ]; then
                filterLength=112
            elif [ $stopBand -le 90 ]; then
                filterLength=152
            elif [ $stopBand -le 98 ]; then
                filterLength=192
            else
                filterLength="`expr 192 + \( $1 - 98 \) / 8 \* 8 \* 4`"
            fi
        fi
        
    else
        
        echo "unsupported stop band dB ($1; valid: 20~242)!" 1>&2
        usage
        exit 1
        
    fi
fi

if [ $# -ge 2 ]; then
     if expr "$2" : "[1-9][0-9]*$" 1>"/dev/null" 2>&1; then
        
        if [ $2 -lt 8  -o  $2 -gt 640 ]; then
            echo "unsupported half filter length ($2; valid: 8~640)!" 1>&2
            usage
            exit 1
        else
            filterLength="`expr $2 / 8 \* 8`"
        fi
        
    else
        
        echo "unsupported half filter length ($2; valid: 8~640)!" 1>&2
        usage
        exit 1
        
    fi
fi

if [ $# -ge 3 ]; then
     if expr "$3" : "[1-9][0-9]*$" 1>"/dev/null" 2>&1; then

        if [ $cheatFlag -gt 0 ]; then        
            if [ $3 -le 0  -o  $3 -gt 200 ]; then
                echo "unsupported cheat percent ($3; valid: 1~200)!" 1>&2
                usage
                exit 1
            else
                cutOffPercent=$3
            fi
        elif [ $3 -lt 0  -o  $3 -gt 100 ]; then
            echo "unsupported cut off percent ($3; valid: 0~100)!" 1>&2
            usage
            exit 1
        else
            cutOffPercent=$3
        fi
        
    else
        
        if [ $cheatFlag -gt 0 ]; then        
            echo "unsupported cheat percent ($3; valid: 1~200)!" 1>&2
        else
            echo "unsupported cut off percent ($3; valid: 0~100)!" 1>&2
        fi
        usage
        exit 1
        
    fi
fi

resetprop_command="`which_resetprop_command`"
if [ -n "$resetprop_command" ]; then
    if [ $resetFlag -gt 0 ]; then
        "$resetprop_command" --delete af.resampler.quality 1>"/dev/null" 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.enable_at_samplerate 1>"/dev/null" 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.stopband 1>"/dev/null" 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.halflength 1>/dev/null 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.cutoff_percent 1>/dev/null 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.tbwcheat 1>/dev/null 2>&1
    else
        # Workaround for recent Pixel Firmwares (not to reboot when resetprop'ing)
        "$resetprop_command" --delete af.resampler.quality 1>"/dev/null" 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.enable_at_samplerate 1>"/dev/null" 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.stopband 1>"/dev/null" 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.halflength 1>/dev/null 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.cutoff_percent 1>/dev/null 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.tbwcheat 1>/dev/null 2>&1
        # En of workaround
        
        "$resetprop_command" af.resampler.quality 7 1>"/dev/null" 2>&1
        if [ $bypassFlag -gt 0 ]; then
            "$resetprop_command" ro.audio.resampler.psd.enable_at_samplerate 48000 1>"/dev/null" 2>&1
        else
            "$resetprop_command" ro.audio.resampler.psd.enable_at_samplerate 44100 1>"/dev/null" 2>&1
        fi
        "$resetprop_command" ro.audio.resampler.psd.stopband "$stopBand" 1>"/dev/null" 2>&1
        "$resetprop_command" ro.audio.resampler.psd.halflength "$filterLength" 1>"/dev/null" 2>&1
        if [ $cheatFlag -gt 0 ]; then
            "$resetprop_command" ro.audio.resampler.psd.tbwcheat "$cutOffPercent" 1>"/dev/null" 2>&1
            "$resetprop_command" --delete ro.audio.resampler.psd.cutoff_percent 1>/dev/null 2>&1
        else
            "$resetprop_command" ro.audio.resampler.psd.cutoff_percent "$cutOffPercent" 1>"/dev/null" 2>&1
            "$resetprop_command" --delete ro.audio.resampler.psd.tbwcheat 1>/dev/null 2>&1
        fi
    fi
    reloadAudioserver
else
    echo "cannot change resampling quality (no resetprop commands found)" 1>&2
    exit 1
fi

AudioFlingerStatus
exit 0
