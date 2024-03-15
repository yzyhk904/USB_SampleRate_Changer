#!/system/bin/sh

MODDIR=${0%/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/getConfig.sh"
