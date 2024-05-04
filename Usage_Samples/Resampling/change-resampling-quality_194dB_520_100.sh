#!/system/bin/sh
#
# The ideal re-sampling (bit-perfect) only when 1:1 ratio frequency re-sampling and 32 bit depth

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh 194 520 100"
