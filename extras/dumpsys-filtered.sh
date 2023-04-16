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

dumpsys media.audio_flinger | sed -e '/^  Hal stream dump/,/^  Master balance:/d' -e '/^-/d'  -e '/^Output thread/,/^$/!d' \
    | awk '
        /^$/ ||
        /^Output thread/ ||
        /^  Sample rate:/ ||
        /^  HAL format:/ ||
        /^  Timestamp stats:/ ||
        /^  AudioStreamOut:/ ||
        /^  Output devices?:/ ||
        /^  Local log:/ ||
        /^   [0-1][0-9]-[0-3][0-9] [0-9.:]+ AT::add / {
            print
        }' \
    | awk -v allFlag=$allFlag '
        BEGIN {
            RS=""
            FS="\n"
        }
        (allFlag==1 && /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_SPEAKER\)/) ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_USB_HEADSET\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_USB_DEVICE\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_WIRED_HEADSET\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_WIRED_HEADPHONE\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_LINE\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_REMOTE_SUBMIX\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_BLUETOOTH_SCO_HEADSET\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_BLUETOOTH_SCO_CARKIT\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_BLUETOOTH_SCO\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_BLUETOOTH_A2DP_SPEAKER\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_BLUETOOTH_A2DP_HEADPHONES\)/ ||
        /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_BLUETOOTH_A2DP\)/ {
            print $0 "\n"
        }'
