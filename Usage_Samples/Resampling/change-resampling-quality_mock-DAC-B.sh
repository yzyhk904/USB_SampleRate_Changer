#!/system/bin/sh
#
# My mock ESS9039PRO-ish in-DAC N-fold Over-sampling filer (fast roll-off type)
#
# Try to use this from 44.1kHz to 706kHz (16x) or 354kHz (8x) up-sampling for comparing difference between mock series and 179dB_408_100.
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh 120 80 97"
