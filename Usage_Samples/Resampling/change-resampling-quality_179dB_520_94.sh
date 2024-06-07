#!/system/bin/sh
#
# For under $30 DAC's having large non-linear distortion
#
#   Characteristics: almost none in background aliasing noise, almost none in pre-echo and ringing, and very slight in intermodulation
#
# Try to use this for investigating differences of N-fold over-sampling among mock series and 179dB_520_94 after setting from 44.1kHz to 706kHz (16x) or 354kHz (8x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh 179 520 94"
