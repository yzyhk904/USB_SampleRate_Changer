#!/system/bin/sh
#
# My mock AK4191EQ-ish in-DAC N-fold Over-sampling filer (sharp roll-off type) when larger than or equal to 48kHz frequency up-sampling
#
#   Characteristics: light in background aliasing noise, heavy in pre-echo and ringing, and heavy in intermodulation
#
# Try to use this for investigating differences of N-fold over-sampling among mock series and 179dB_408_99 after setting from 44.1kHz to 706kHz (16x) or 354kHz (8x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --bypass --cheat 150 80 109"
