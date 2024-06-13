#!/system/bin/sh
#
# For under $30 DAC's having large non-linear distortion when replaying 96 kHz & 24 bits Hires. tracks
#
#   Characteristics: almost none in background aliasing noise, almost none in pre-echo and ringing, and very slight in intermodulation
#
# Try to use this for investigating differences of N-fold over-sampling among mock series and 179dB_520_44 after setting from 96kHz to 768kHz (8x) or 384kHz (4x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --bypass-hires 179 520 44"
