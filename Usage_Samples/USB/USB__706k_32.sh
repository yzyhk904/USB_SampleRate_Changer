#!/system/bin/sh

MODDIR=${0%/*/*/*}
su --mount-master -c "/system/bin/sh ${MODDIR}/USB_SampleRate_Changer.sh 706k 32"
