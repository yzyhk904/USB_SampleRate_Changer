#!/system/bin/sh
#
# For LDAC earphones and DAC's under $30 having large non-linear distortion when replaying 48 kHz & 16 and 24 bits tracks (possibly 44.1 kHz ones)
#
#  If you feel your LDAC earphones or internal speakers wouldn't become to sound good at all, 
#  try replacing "83" (below) with "84", "85"  or "86" for appropriately cutting off ultrasonic noise causing intermodulation.
#
#   Characteristics: almost none in background aliasing noise, almost none in pre-echo and ringing, and very slight in intermodulation
#
# Try to use this for investigating differences of 179dB_408_99 and "cheapies_48kHz-cheapest" after setting from 48kHz to 768kHz (8x) or 384kHz (4x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh 194 520 83"
