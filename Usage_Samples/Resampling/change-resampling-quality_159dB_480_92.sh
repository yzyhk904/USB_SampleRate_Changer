#!/system/bin/sh
#
# General purpos re-sampling filter at a very mastering quality (for old devices)
#
#   Characteristics: slight in background aliasing noise, almost none in pre-echo and ringing, and almost none in intermodulation
#
# Try to use this for investigating differences of N-fold over-sampling among mock series and 159dB_480_92 after setting from 44.1kHz to 706kHz (16x) or 354kHz (8x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh 159 480 92"
