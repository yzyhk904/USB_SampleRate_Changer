#!/system/bin/sh

MODDIR=${0%/*/*}
exec su -c "/system/bin/sh ${MODDIR}/extras/change-bluetooth-hal.sh aosp"
