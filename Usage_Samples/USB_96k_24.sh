#!/system/bin/sh

MODDIR=${0%/*/*}
exec su --mount-master -c "/system/bin/sh ${MODDIR}/USB_SampleRate_Changer.sh 96k 24"
