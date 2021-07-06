#!/system/bin/sh

if [ ! "`cat /proc/asound/card1/pcm0p/sub0/hw_params`" = "closed" ];then
  echo "DAC Connection Status:"
  cat '/proc/asound/card1/pcm0p/sub0/hw_params'
fi
if [ ! "`cat /proc/asound/card1/id`" = "closed" ];then
  echo "\nDAC Hardware Profile:"
  cat '/proc/asound/card1/stream0'
fi
