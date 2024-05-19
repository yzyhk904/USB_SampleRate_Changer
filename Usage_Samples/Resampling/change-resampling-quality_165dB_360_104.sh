#!/system/bin/sh
#
# General purpos re-sampling filter at a mastering quality (for low performance devices)
#
#   Characteristics: very slight in background aliasing noise, very slight in pre-echo and ringing, and medium in intermodulation
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --bypass --cheat 165 360 104"
