#!/system/bin/sh
#
# Reset and revert to the original system configuration for audio re-sampling

MODDIR=${0%/*/*/*}
su -c "/system/bin/sh ${MODDIR}/extras/change-resampling-quality.sh --reset"
