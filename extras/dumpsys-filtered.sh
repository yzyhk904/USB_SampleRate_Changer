#!/system/bin/sh

dumpsys media.audio_flinger | sed -e '/^  Hal stream dump/,/^  Thread throttle/d' -e '/^-/d'  -e '/^Output thread/,/^$/!d' \
  | awk '
  /^$/ ||
  /^Output thread/ ||
  /^  Sample rate:/ ||
  /^  HAL format:/ ||
  /^  Timestamp stats:/ ||
  /^  AudioStreamOut:/ ||
  /^  Output devices?:/ ||
  /^  Local log:/ ||
  /^   [0-1][0-9]-[0-3][0-9] / {
     print
  }' \
  | awk '
  BEGIN {
    RS=""
    FS="\n"
  }
  /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_USB_HEADSET\)/ ||
  /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_USB_DEVICE\)/ ||
  /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_WIRED_HEADSET\)/ ||
  /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_WIRED_HEADPHONE\)/ ||
  /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_REMOTE_SUBMIX\)/ ||
  /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_BLUETOOTH_A2DP_SPEAKER\)/ ||
  /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_BLUETOOTH_A2DP_HEADPHONES\)/ ||
  /Output devices?:[^(]+\(AUDIO_DEVICE_OUT_BLUETOOTH_A2DP\)/ {
    print $0 "\n"
  }'
