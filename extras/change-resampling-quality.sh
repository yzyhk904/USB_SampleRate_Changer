#!/system/bin/sh

# AOSP standard values:         StopBandAttenuation   HalfFilterLength   CutOffPercent (ratio to Nyquist freq.)
#   DYN_HIGH_QUALITY:             98dB                          32                       100
#   AOSP default:                         90dB                          32                       100
#   DYN_MEDIUM_QUALITY:        84dB                          16                       100
#   DYN_LOW_QUALITY:             80dB                            8                       100
#   This script's default:              140dB                        320                        91
#

stopBand=140
filterLength=320
cutOffPercent=91

resetMode=0

function usage()
{
    echo "Usage: ${0##*/} [--help] [--status] [--reset] [stop_band_dB [half_filter_length [cut_off_percent]]]" 1>&2
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
    if [ $# -eq 3 ]; then
        echo "AudioFlinger's Resampling Configuration Status" 1>&2
        if [ -n "$1" ]; then
            echo "  Stop Band (dB): $1" 1>&2
        fi
        if [ -n "$2" ]; then
            echo "  Half Filter Length: $2" 1>&2
        fi
        if [ -n "$3" ]; then
            echo "  Cut Off (%): $3" 1>&2
        fi
    fi
}

function AudioFlingerStatus()
{
    local val1 val2 val3
    val1="`getprop ro.audio.resampler.psd.stopband`"
    if [ -n "$val1" ]; then
        val2="`getprop ro.audio.resampler.psd.halflength`"
        val3="`getprop ro.audio.resampler.psd.cutoff_percent`"
        PrintStatus "$val1" "$val2" "$val3"
    else
        PrintStatus 90 32 100
    fi
}

if [ $# -gt 0 ];then
    case "$1" in
        "-h" | "--help" )
            usage
            exit 0
            ;;
        "-s" | "--status" )
            AudioFlingerStatus
            exit 0
            ;;
        "-r" | "--reset" )
            resetMode=1
            ;;
        * )
             if expr "$1" : "[1-9][0-9]*$" 1>"/dev/null" 2>&1; then
                
                if [ $1 -lt 20  -o  $1 -gt 160 ]; then
                    echo "unsupported stop band dB ($1; valid: 20~160)!" 1>&2 
                    usage
                    exit 1
                else
                    stopBand="$1"
                    if [ $stopBand -le 60 ]; then
                        filterLength=8
                    elif [ $stopBand -le 84 ]; then
                        filterLength=16
                    elif [ $stopBand -le 90 ]; then
                        filterLength=24
                    elif [ $stopBand -le 98 ]; then
                        filterLength=32
                    else
                        filterLength="`expr 32 + \( $1 - 98 \) / 8 \* 8 \* 6`"
                    fi
                fi
                
            else
                
                echo "unsupported stop band dB ($1; valid: 20~160)!" 1>&2 
                usage
                exit 1
                
            fi
            ;;
    esac
fi

if [ $resetMode -eq 0  -a  $# -eq 2 ]; then
     if expr "$2" : "[1-9][0-9]*$" 1>"/dev/null" 2>&1; then
        
        if [ $2 -lt 8  -o  $2 -gt 480 ]; then
            echo "unsupported half filter length ($2; valid: 8~480)!" 1>&2 
            usage
            exit 1
        else
            filterLength="`expr $2 / 8 \* 8`"
        fi
        
    else
        
        echo "unsupported half filter length ($2; valid: 8~480)!" 1>&2 
        usage
        exit 1
        
    fi
fi

if [ $resetMode -eq 0  -a  $# -eq 3 ]; then
     if expr "$3" : "[1-9][0-9]*$" 1>"/dev/null" 2>&1; then
        
        if [ $3 -lt 0  -o  $3 -gt 100 ]; then
            echo "unsupported cut off percent ($3; valid: 0~100)!" 1>&2 
            usage
            exit 1
        else
            cutOffPercent=$3
        fi
        
    else
        
        echo "unsupported cut off percent ($3; valid: 0~100)!" 1>&2 
        usage
        exit 1
        
    fi
fi

resetprop_command="`which_resetprop_command`"
if [ -n "$resetprop_command" ]; then
    if [ $resetMode -gt 0 ]; then
        "$resetprop_command" --delete af.resampler.quality 1>"/dev/null" 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.enable_at_samplerate 1>"/dev/null" 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.stopband 1>"/dev/null" 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.halflength 1>/dev/null 2>&1
        "$resetprop_command" --delete ro.audio.resampler.psd.cutoff_percent 1>/dev/null 2>&1
    else
        "$resetprop_command" af.resampler.quality 7
        "$resetprop_command" ro.audio.resampler.psd.enable_at_samplerate 44100 1>"/dev/null" 2>&1
        "$resetprop_command" ro.audio.resampler.psd.stopband "$stopBand" 1>"/dev/null" 2>&1
        "$resetprop_command" ro.audio.resampler.psd.halflength "$filterLength" 1>"/dev/null" 2>&1
        "$resetprop_command" ro.audio.resampler.psd.cutoff_percent "$cutOffPercent" 1>"/dev/null" 2>&1
    fi
    reloadAudioserver
else
    echo "cannot change resampling quality (no resetprop commands found)" 1>&2
    exit 1
fi
exit 0
