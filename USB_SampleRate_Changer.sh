#!/system/bin/sh
#
# Version: 3.0.3
#     by zyhk

MYDIR="${0%/*}"

# Check whether this script has been marked "disable", or not
if [ ! -d "$MYDIR" ]; then
    echo "cannot get the current directory!" 1>&2 ; 
    exit 1
elif [ -e "$MYDIR/disable" ] ; then
    echo "this script is now disabled!" 1>&2 ; 
    exit 0
fi
# End

# Default values
policyMode="auto"
resetMode="false"
testMode="false"
testTemplate="$MYDIR/templates/test_template.xml"
DRC_enabled="false"
USB_module="usb"
BT_module="bluetooth"
forceBluetoothQti="false"

# Help message

while [ $# -gt 0 ]; do
     case "$1" in
        "-o" | "--offload" )
            policyMode="offload"
            shift
            ;;
        "-oh" | "--offload-hifi-playback" )
            policyMode="offload-hifi-playback"
            shift
            ;;
        "-od" | "--offload-direct" )
            policyMode="offload-direct"
            shift
            ;;
        "-b" | "--bypass-offload" )
            policyMode="bypass"
            shift
            ;;
        "-bs" | "--bypass-offload-safer" )
            policyMode="bypass-safer"
            shift
            ;;
        "-l" | "--legacy" )
            policyMode="legacy"
            shift
            ;;
        "-s" | "--safe" )
            policyMode="safe"
            shift
            ;;
        "-ss" | "--safest" )
            policyMode="safest"
            shift
            ;;
        "-ssa" | "--safest-auto" )
            policyMode="safest-auto"
            shift
            ;;
        "-u" | "--usb-only" )
            policyMode="usb"
            shift
            ;;
        "-fu" | "--force-usbv2" )
            USB_module="usbv2"
            shift
            ;;
        "-fq" | "--force-bluetooth-qti" )
            forceBluetoothQti="true"
            shift
            ;;
        "-a" | "--auto" )
            policyMode="auto"
            shift
            ;;
        "-d" | "--drc" )
            DRC_enabled="true"
            shift
            ;;
        "-r" | "--reset" )
            resetMode="true"
            shift
            ;;
        "--test" )
            testMode="true"
            shift
            ;;
        "--test-template" )
            # This option takes one argument specifying a template file path whether it is absolute or relative to the template folder
            shift
            if [ $# -gt 0 ]; then
                case "$1" in
                    /* )
                        testTemplate="$1"
                        ;;
                    * )
                        testTemplate="$MYDIR/templates/$1"
                        ;;
                esac
                shift
            fi
            ;;
        "-h" | "--help" | -* )
            echo -n "Usage: ${0##*/} [--reset] [--drc] [--bypass-offload][--bypass-offload-safer][--offload][--offload-hifi-playback][--offload-direct]" 1>&2
            echo    "[--legacy][--safe][--safest][--safest-auto][--usb-only] [[44k|48k|88k|96k|176k|192k|353k|384k|706k|768k] [[16|24|32|float]]]" 1>&2
            echo -n "\nNote: ${0##*/} requires to unlock the USB audio class driver's limitation (upto 96kHz lock or 384kHz Qcomm offload lock)" 1>&2
            echo     " if you specify greater than 96kHz or 384kHz (in case of Qcomm offload)." 1>&2
            exit 0
            ;;
        * )
            break
            ;;
    esac
done
# End of help message

. "$MYDIR/functions3.shlib"

genfile="/data/local/tmp/audio_conf_generated.xml"
 
# Reset
if "$resetMode"; then
    if [ -e "$MYDIR/.config" ]; then
        rm -f "$MYDIR/.config"
    fi
    removeGenFile "$genfile"
    reloadAudioServers "all"
    exit 0
fi
# Reset End

# Set parameters
sRate="44100"
bDepth="32"

case $# in
    0 ) ;;
    1 )  sRate="$1";;
    2 )  sRate="$1"; bDepth="$2";;
    * )  echo "too many arguments (n=$#)!" 1>&2 ; exit 1;;
esac
# End of setting parameters

# Normalize arguments
case "$sRate" in
    "44k" | "44.1k" )
        sRate="44100"
        ;;
    "48k" )
        sRate="48000"
        ;;
    "88k" | "88.2k" )
        sRate="88200"
        ;;
    "96k" )
        sRate="96000"
        ;;
    "176k" | "176.4k" )
        sRate="176400"
        ;;
    "192k" )
      sRate="192000"
      ;;
    "352k" | "353k" | "352.8k" )
      sRate="352800"
      ;;
    "384k" )
      sRate="384000"
      ;;
    "705k" | "706k" | "705.6k" )
      sRate="705600"
      ;;
    "768k" )
      sRate="768000"
      ;;
     * )
        if expr "$sRate" : "[1-9][0-9]*$" 1>"/dev/null" 2>&1; then
            if [ $sRate -lt 44100  -o  $sRate -gt 768000 ]; then
                echo "unsupported sample rate (rate=$sRate)!" 1>&2 
                exit 1
            fi
        else
            echo "unsupported sample rate (rate=$sRate)!" 1>&2 
            exit 1
        fi
        ;;
esac

aFormat="AUDIO_FORMAT_PCM_32_BIT"
case "$bDepth" in
    16 )
        aFormat="AUDIO_FORMAT_PCM_16_BIT"
        ;;
    24 )
        aFormat="AUDIO_FORMAT_PCM_24_BIT_PACKED"
        ;;
    32 )
        aFormat="AUDIO_FORMAT_PCM_32_BIT"
        ;;
    "float" )
        aFormat="AUDIO_FORMAT_PCM_FLOAT"
        ;;
    * )
        echo "unknow bit depth specified (depth=$bDepth)!" 1>&2
        exit 1
        ;;
esac
# End of argument normalization

# Overlay a generated audio policy configuration file on "/vendor/etc/audio_policy_configuration.xml" (e.g. typical)
if [ ! -r "$MYDIR/.config" ]; then
    makeConfigFile "$MYDIR/.config"
fi

if [ -r "$MYDIR/.config" ]; then
    . "$MYDIR/.config"
fi

if [ -z "$PolicyFile"  -o  "$PolicyFile" = "N/A" ]; then
    # Very recent devices, e.g., Pixel 9 series
    echo "Recent AIDL only devices are not supported!" 1>&2 
    exit 1
else
    overlayTarget="$PolicyFile"
fi

if [ "$policyMode" = "auto"  -a  -n "$BluetoothHal" ];then
    policyMode="$BluetoothHal"
fi

case "$policyMode" in
    "legacy" | "safe" | "safest" | "safest-auto" )
        BT_module="a2dp"
        ;;
    * )
        if [ "`getprop ro.board.platform`" = "pineapple"  -a  -r "/vendor/lib64/hw/audio.bluetooth_qti.default.so" ]; then
            # A workaround for Pineapple devices for no using the AOSP bluetooth module temporary
            BT_module="bluetooth_qti"
        elif [ "`getprop ro.product.board`" = "taro" -a  -r "/vendor/lib64/hw/audio.bluetooth_qti.default.so" ]; then
            # An exception for Asus Zenfone 9
            BT_module="bluetooth_qti"
        else
            BT_module="bluetooth"
        fi
        ;;
esac

# Force the bluetooth HAL to be "bluetooth_qti"
if "$forceBluetoothQti"; then
    BT_module="bluetooth_qti"
    if [ ! -r "/vendor/lib64/hw/audio.bluetooth_qti.default.so"  -a  ! -r "/vendor/lib/hw/audio.bluetooth_qti.default.so" ]; then
            echo "    Warning: ${0##*/} detected no \"bluetooth_qti\" audio HAL module on this device" 1>&2
    fi
fi

SysbtaCapable="`getprop persist.bluetooth.system_audio_hal.enabled`"

if [ "$SysbtaCapable" = "1" ]; then
    BT_module="sysbta"
fi

if [ -n "$SysbtaCapable"  -a  "`getprop init.svc.system.bt-audio-hal`" != "stopped" ]; then
    if [ "$policyMode" = "offload"  -o  "$policyMode" = "offload-direct" ]; then
        echo "    Warning: ${0##*/} detected that \"sysbta\" (System Wide Bluetooth HAL) service was running" 1>&2
        
        if [ "$SysbtaCapable" = "1" ]; then
            echo "    Info: \"sysbta\" rewrites bluetooth audio parts from \"$policyMode\" to its own forcibly on the fly! \
If you like \"$policyMode\" to be unmodified anyway, please use \"extras/change-bluetooth-hal.sh\" \
to change the active bluetooth audio HAL to \"offload\"" 1>&2
        else
            echo "    Info: Please use \"extras/change-bluetooth-hal.sh\" to change the active bluetooth audio HAL to \"offload\", \
or your bluetooth device cannot output sound!" 1>&2
        fi
        
    fi
fi

if [ ! \( "$policyMode" = "offload"  -o  "$policyMode" = "offload-hifi-playback"  -o  "$policyMode" = "offload-direct" \
             -o  "$policyMode" = "bypass-offload" \)  -a  $sRate -gt 96000 ]; then
    if [ ! -e "/data/adb/modules/usb-samplerate-unlocker"  -a  ! -e "/data/adb/modules/audio-samplerate-changer" ]; then
        echo "    Warning: ${0##*/} requires to unlock the USB HAL driver's limitation (upto 96kHz lock) by \"usb-samplerate-unlocker\" or \"audio-samplerate-changer\"" 1>&2
    fi
elif [ "$policyMode" = "offload"  -o  "$policyMode" = "offload-direct" ]; then
    case "`getprop ro.board.platform`" in
        mt* | exynos* | gs10? )
            if [ $sRate -gt 96000 ]; then
                echo -n "    Warning: ${0##*/} may not change to the specified sample rate ($sRate) because of the hardware offloading driver's limitation" 1>&2
                echo     " (upto 96kHz lock)" 1>&2
            fi
        ;;
       gs* | zuma* )
            if [ $sRate -gt 192000 ]; then
                echo -n "    Warning: ${0##*/} canot change to the specified sample rate ($sRate) because of the hardware offloading driver's limitation" 1>&2
                echo     " (upto 192kHz lock)" 1>&2
            fi
        ;;
        * )
            if [ $sRate -gt 384000 ]; then
                echo -n "    Warning: ${0##*/} may not change to the specified sample rate ($sRate) because of the hardware offloading driver's limitation" 1>&2
                echo     " (upto 384kHz lock)" 1>&2
            fi
        ;;
    esac
fi

if IsSeventhAudio; then
    case "$policyMode" in
        "offload" )
            template="$MYDIR/templates/offload_template.xml"
            ;;
        "offload-hifi-playback" )
            template="$MYDIR/templates/offload_hifi_playback_template.xml"
            ;;
        "offload-direct" )
            template="$MYDIR/templates/offload_direct_template.xml"
            ;;
        "bypass" )
            template="$MYDIR/templates/bypass_offload_template.xml"
            ;;
        "bypass-safer" )
            case "`getprop ro.board.platform`" in
                gs* | zuma* )
                    USB_module="usbv2"
                    template="$MYDIR/templates/bypass_offload_safer_tensor_template.xml"
                    ;;
                * )
                    template="$MYDIR/templates/bypass_offload_safer_template.xml"
                    ;;
            esac
            ;;
        "legacy" )
            template="$MYDIR/templates/Old/legacy_template.xml"
            ;;
        "safe" )
            template="$MYDIR/templates/bypass_offload_safer_template.xml"
            ;;
        "safest-auto" )
            template="$MYDIR/templates/bypass_offload_template.xml"
            sRate="48000"
            aFormat="AUDIO_FORMAT_PCM_16_BIT"
            ;;
        "usb" )
            template="$MYDIR/templates/Old/usb_only_template.xml"
            if [ -r "/vendor/etc/usb_audio_policy_configuration.xml" ]; then
                overlayTarget="/vendor/etc/usb_audio_policy_configuration.xml"
            elif [ -r "/vendor/etc/usbv2_audio_policy_configuration.xml"  -a  -r "/vendor/lib64/hw/audio.usbv2.default.so" ]; then
                overlayTarget="/vendor/etc/usbv2_audio_policy_configuration.xml"
                USB_module="usbv2"
            else
                echo "target USB configuration file (\"/vendor/etc/usb_audio_policy_configuration.xml\") not found!" 1>&2 
                exit 1
            fi
            ;;
        "safest" | * )
            template="$MYDIR/templates/Old/safest_template.xml"
            ;;
    esac
else
    case "$policyMode" in
        "offload" )
            template="$MYDIR/templates/Old/offload_template.xml"
            ;;
        "offload-hifi-playback" )
            case "`getprop ro.board.platform`" in
                mt* )
                    echo "    Warning: ${0##*/} changed to \"--bypass-offload-safer\" mode because of the hardware offloading driver's restrictions" 1>&2
                    template="$MYDIR/templates/Old/bypass_offload_safer_mtk_template.xml"
                    ;;
                * )
                    template="$MYDIR/templates/Old/offload_hifi_playback_template.xml"
                    ;;
            esac
            ;;
        "offload-direct" )
            template="$MYDIR/templates/Old/offload_direct_template.xml"
            ;;
        "bypass" )
            template="$MYDIR/templates/Old/bypass_offload_template.xml"
            ;;
        "bypass-safer" )
            case "`getprop ro.board.platform`" in
                mt* )
                    template="$MYDIR/templates/Old/bypass_offload_safer_mtk_template.xml"
                    ;;
                * )
                    template="$MYDIR/templates/Old/bypass_offload_safer_template.xml"
                    ;;
            esac
            ;;
        "legacy" )
            template="$MYDIR/templates/Old/legacy_template.xml"
            ;;
        "usb" )
            template="$MYDIR/templates/Old/usb_only_template.xml"
            if [ -r "/vendor/etc/usb_audio_policy_configuration.xml" ]; then
                overlayTarget="/vendor/etc/usb_audio_policy_configuration.xml"
            elif [ -r "/vendor/etc/usbv2_audio_policy_configuration.xml"  -a  -r "/vendor/lib64/hw/audio.usbv2.default.so" ]; then
                overlayTarget="/vendor/etc/usbv2_audio_policy_configuration.xml"
                USB_module="usbv2"
            else
                echo "target USB configuration file (\"/vendor/etc/usb_audio_policy_configuration.xml\") not found!" 1>&2 
                exit 1
            fi
            ;;
        "safe" )
            template="$MYDIR/templates/Old/safe_template.xml"
            ;;
        "safest" )
            template="$MYDIR/templates/Old/safest_template.xml"
            ;;
        "safest-auto" )
            template="$MYDIR/templates/Old/safest_auto_template.xml"
            ;;
         * )
            template="$MYDIR/templates/Old/safe_template.xml"
            ;;
    esac
fi

# Test template mode
if "$testMode"; then
    template="$testTemplate"
fi
# Test template mode End

if [ -r "$template" ]; then

    removeGenFile "$genfile"
    if [ "$USB_module" = "usb"  -a  ! -r "/vendor/lib64/hw/audio.usb.default.so"  -a  -r "/vendor/lib64/hw/audio.usbv2.default.so" ]; then
        USB_module="usbv2"
    fi
    sed   -e "s|%DRC_ENABLED%|$DRC_enabled|" -e "s|%USB_MODULE%|$USB_module|" -e "s|%BT_MODULE%|$BT_module|" \
            -e "s|%SAMPLING_RATE%|$sRate|" -e "s|%AUDIO_FORMAT%|$aFormat|" \
            -e "s|%VOLUME_FILE%|$VolumeFile|" -e "s|%DEFAULT_VOLUME_FILE%|$DefaultVolumeFile|" "$template" >"$genfile"

    if [ $? -eq 0 ]; then
    
        chmod 644 "$genfile"
        chcon u:object_r:vendor_configs_file:s0 "$genfile"

        targetDir=${overlayTarget%/*}
        if [ -r "$overlayTarget"  -o  "${targetDir##*_}" = "qssi" ]; then
            # "${targetDir##*_}" = "qssi" is for some OnePlus ROM's (probably a bug?)
            
            isMounted "/proc/self/mountinfo" "$overlayTarget" "ExcludeMagisk" "NoShowKey"
            if [ $? -eq 0 ]; then
                umount "$overlayTarget" 1>"/dev/null" 2>&1
             fi
             
            mount -o bind "$genfile" "$overlayTarget"
            if [ $? -gt 0 ]; then
                echo "failed to overlay a generated audio policy configuration XML file!" 1>&2 
                exit 1
            fi
            
        else
        
            echo "overlaying target (\"$overlayTarget\") doesn't exist!" 1>&2 
            exit 1
            
        fi
        
    else
    
        echo "audio policy XML file genaration failed!" 1>&2 
        exit 1
        
    fi
    
else

    echo "an audio configuration template file (\"$template\") not found!" 1>&2 
    exit 1
    
fi
# End of overlay system files


# Reload audio policy configuration files.  
reloadAudioServers

# End of reload
