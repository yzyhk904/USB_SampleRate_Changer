#!/system/bin/sh

MODDIR=${0%/*/*/*}

case "`getprop ro.board.platform`" in
    gs* | zuma* )
        # for Tensor devices (Internal speaker: 48kHz 32bit; offload USB driver: automatic max. detection (<=192kHz)  for even non-HiRes. tracks)
        # because they wouldn't run the USB HAL driver
        Args="--offload-hifi-playback 48k 32"
        ;;
    * )
        if [ ! -e "/vendor/lib64/hw/audio.bluetooth.default.so" ]; then
            # for old devices (under Android 10; various configurations)
            Args="--safest-auto"
        elif [ "`getprop persist.bluetooth.bluetooth_audio_hal.disabled`" = "true" ]; then
            # for legacy configuration devices (using "a2dp" legacy Bluetooth module)
            Args="--safest-auto"
        elif [ "`getprop ro.hardware.lights`" = "qcom"  -o  "`getprop ro.hardware`" = "qcom" ]; then
            # for Qcom devices (Internal speaker: 384kHz 32bit; the USB HAL & the BT HAL driver: automatic max. detection for even non-HiRes. tracks)
            Args="--bypass-offload 384k 32"
        else
            # for MTK and other devices (Internal speaker: 48kHz 32bit; the USB HAL & the BT HAL driver: automatic max. detection for even non-HiRes. tracks)
            Args="--bypass-offload 48k 32"
        fi
        ;;
esac

su --mount-master -c "/system/bin/sh ${MODDIR}/USB_SampleRate_Changer.sh $Args"
