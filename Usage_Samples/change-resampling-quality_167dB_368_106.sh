#!/system/bin/sh

MODDIR=${0%/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --bypass --cheat 167 368 106"
