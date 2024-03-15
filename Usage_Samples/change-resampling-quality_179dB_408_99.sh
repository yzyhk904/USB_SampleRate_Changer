#!/system/bin/sh

MODDIR=${0%/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --cheat 179 408 99"
