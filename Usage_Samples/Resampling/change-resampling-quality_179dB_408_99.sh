#!/system/bin/sh
#
# General purpos re-sampling filter at a very mastering quality (for devices except low performance ones)
#
#   Characteristics: almost none in background aliasing noise, almost none in pre-echo and ringing, and light in intermodulation
#
# Try to use this for investigating differences of N-fold over-sampling among mock series and 179dB_408_99 after setting from 44.1kHz to 706kHz (16x) or 354kHz (8x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --cheat 179 408 99"
