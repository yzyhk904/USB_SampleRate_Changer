#!/system/bin/sh

rst="closed"
file="/proc/asound/card1/pcm0p/sub0/hw_params"
if [ -r "$file" ]; then
    # For non-hardware offload use
    rst="`cat $file`"
    if [ ! "$rst" = "closed" ];then
        echo "DAC Connection Status:"
        echo "$rst"
    fi
fi

if [ "$rst" = "closed" ]; then
    # For USB hardware offload use
    for i in `seq 0 90`; do
    
        file="/proc/asound/card0/pcm${i}p/sub0/hw_params"
        if [ -r "$file" ]; then
            rst="`cat $file`"
            
            if [ ! "$rst" = "closed" ];then
                echo "Active Audio Connection Status (/proc/asound/card0/pcm${i}p):"
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

