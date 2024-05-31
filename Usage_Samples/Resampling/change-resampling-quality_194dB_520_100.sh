#!/system/bin/sh
#
# The ideal re-sampling (bit-perfect) only when 1:1 ratio frequency re-sampling and 32 bit depth
#
#   Characteristics (except 1:1 re-sampling) : almost none in background aliasing noise, light in pre-echo and ringing, and light in intermodulation
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh 194 520 100"
