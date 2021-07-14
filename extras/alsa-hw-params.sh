#!/system/bin/sh

rst="closed"
if [ -r "/proc/asound/card1/pcm0p/sub0/hw_params" ]; then
#  For non-hardware offload use
  rst="`cat /proc/asound/card1/pcm0p/sub0/hw_params`"
  if [ ! "$rst" = "closed" ];then
    echo "DAC Connection Status:"
    echo "$rst"
  fi
fi
if [ "$rst" = "closed" ]; then
#  For USB hardware offload use
  for i in `seq 1 60`; do
    if [ -r "/proc/asound/card0/pcm${i}p/sub0/hw_params" ]; then
      rst="`cat /proc/asound/card0/pcm${i}p/sub0/hw_params`"
      if [ ! "$rst" = "closed" ];then
          echo "DAC Connection Status:"
          echo "$rst"
          break
      fi
    fi
  done
fi

if [ -r "/proc/asound/card1/id" ]; then
  if [ ! "`cat /proc/asound/card1/id`" = "closed"  -a  -r "/proc/asound/card1/stream0" ];then
    echo "\nDAC Hardware Profile:"
    cat '/proc/asound/card1/stream0'
  fi
fi

