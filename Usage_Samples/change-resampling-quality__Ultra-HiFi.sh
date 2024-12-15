#!/system/bin/sh
#
# Ultra Hi-Fi mastering quality re-sampling filter (for very high performance devices)
#
#   Characteristics: almost none in background aliasing noise, almost none in pre-echo and ringing, and light in intermodulation
#
# Try to use this for investigating differences of N-fold over-sampling among mock series and this ultra-hifi after setting from 48kHz to 768kHz (16x) or 384kHz (8x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --cheat 194 520 98"
