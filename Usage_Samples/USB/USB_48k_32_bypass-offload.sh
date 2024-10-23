#!/system/bin/sh

# Internal speakers: 48kHz & 32bit; USB HAL & Bluetooth HAL: automatically detecting the best samplerate and audio format

MODDIR=${0%/*/*/*}
su --mount-master -c "/system/bin/sh ${MODDIR}/USB_SampleRate_Changer.sh --bypass-offload 48k 32"
