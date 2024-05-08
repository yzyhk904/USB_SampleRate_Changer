#!/system/bin/sh
#
# My mock iZotope-ish mastering tool filer (no alias type)
#
#   Characteristics: light in background aliasing noise, slight in pre-echo and ringing, and light in intermodulation
#
# Try to use this for investigating differences of N-fold over-sampling among mock series and 179dB_408_99 after setting from 44.1kHz to 706kHz (16x) or 354kHz (8x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --cheat 159 240 99"
