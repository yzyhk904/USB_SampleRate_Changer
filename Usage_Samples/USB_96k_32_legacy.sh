#!/system/bin/sh

MODDIR=${0%/*/*}
su --mount-master -c "/system/bin/sh ${MODDIR}/USB_SampleRate_Changer.sh --legacy 96k 32"
