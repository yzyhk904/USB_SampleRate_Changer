#!/system/bin/sh
#
# My mock cheap in-DAC N-fold Over-sampling filer (fast roll-off type) of which quality level is set to be a bit better than that of SoX HQ linear phase
# when larger than or equal to 48kHz frequency up-sampling
#
#   Characteristics: heavy in background aliasing noise, light in pre-echo and ringing, and medium in intermodulation
#
# Try to use this for investigating differences of N-fold over-sampling among mock series and 179dB_408_99 after setting from 44.1kHz to 706kHz (16x) or 354kHz (8x) in 32bit depth up-sampling
#

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --bypass --cheat 100 80 104"
