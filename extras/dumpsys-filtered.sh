#!/system/bin/sh

dumpsys media.audio_flinger | sed -e '/^  Hal stream dump/,/^  Thread throttle/d' -e '/^-/d'  -e '/^Output thread/,/^$/!d' \
  | grep -e '^$' -e '^Output thread' -e '^  Sample rate' -e '^  HAL format' -e '^  Timestamp stats' -e '^  AudioStreamOut'  -e '^  Output devices' -e '^  Local log' -e '^   [0-9][0-9]-[0-9][0-9] '  \
  | awk '
  BEGIN {
    RS=""
    FS="\n"
  }
  /(AUDIO_DEVICE_OUT_USB_HEADSET)/ {
    print $0
  }'
