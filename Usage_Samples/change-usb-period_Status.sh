#!/system/bin/sh

MODDIR=${0%/*/*}
exec su -c "/system/bin/sh ${MODDIR}/extras/change-usb-period.sh --status"
