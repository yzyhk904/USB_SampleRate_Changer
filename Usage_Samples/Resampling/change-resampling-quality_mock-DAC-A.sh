#!/system/bin/sh
#
# My mock AK4191EQ-ish in-DAC N-fold Over-sampling filer (sharp roll-off type) when larger than or equal to 48kHz frequency up-sampling
#
# Try to use this from 44.1kHz to 706kHz (16x) or 354kHz (8x) up-sampling for comparing difference between mock series and 179dB_408_100.
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --bypass --cheat 150 80 109"
