#!/system/bin/sh

# Internal speakers: 48kHz & 32bit; offload USB driver & Bluetooth HAL: automatically detecting the best samplerate and audio format

MODDIR=${0%/*/*/*}
su --mount-master -c "/system/bin/sh ${MODDIR}/USB_SampleRate_Changer.sh --offload-hifi-playback 48k 32"
