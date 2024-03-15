#!/system/bin/sh

MODDIR=${0%/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/alsa-hw-params.sh"
