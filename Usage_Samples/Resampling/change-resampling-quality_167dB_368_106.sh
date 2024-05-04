#!/system/bin/sh
#
# General purpos re-sampling filter at a mastering quality (for low performance devices)

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --bypass --cheat 167 368 106"
