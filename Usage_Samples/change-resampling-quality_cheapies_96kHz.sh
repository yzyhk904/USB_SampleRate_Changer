#!/system/bin/sh
#
# For LDAC earphones and DAC's under $30 having large non-linear distortion when replaying 96 kHz & 24 bits Hires. tracks
#
#  If you feel your LDAC earphones or "cheapie" DAC wouldn't become to sound good at all, 
#  try replacing "43" (below) with "44" for appropriately cutting off ultrasonic noise causing intermodulation.
#
#   Characteristics: almost none in background aliasing noise, almost none in pre-echo and ringing, and very slight in intermodulation
#
# Try to use this for investigating differences of 179dB_408_99 and "cheapies_96kHz" after setting from 96kHz to 768kHz (8x) or 384kHz (4x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --bypass-hires 194 520 43"
