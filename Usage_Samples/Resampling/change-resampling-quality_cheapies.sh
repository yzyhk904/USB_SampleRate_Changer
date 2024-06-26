#!/system/bin/sh
#
# For LDAC earphones and DAC's under $30 having large non-linear distortion
#
#  If you feel your LDAC earphones or "cheapie" DAC wouldn't become to sound good at all, 
#  try replacing "94" (below) with one of "93" down to "87" for appropriately cutting off ultrasonic noise causing intermodulation.
#
#   Characteristics: almost none in background aliasing noise, almost none in pre-echo and ringing, and very slight in intermodulation
#
# Try to use this for investigating differences of 179dB_408_99 and "cheapies" after setting from 44.1kHz to 706kHz (16x) or 354kHz (8x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh 179 520 94"
