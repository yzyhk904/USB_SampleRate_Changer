#!/system/bin/sh
#
# Version: 2.5.1
#     by zyhk

MYDIR="${0%/*}"

# Check whether this script has been marked "disable", or not
if [ ! -d "$MYDIR" ]; then
    echo "cannot get the current directory!" 1>&2 ; 
    exit 1
elif [ -e "$MYDIR/disable" ] ; then
    echo "this script is now disabled!" 1>&2 ; 
    exit 0
fi
# End

function usage()
{
      echo "Usage: ${0%/*} [--selinux|++selinux][--thermal|++thermal][--doze|++doze][---governor|++governor][--logd][++logd][--camera|++camera][--io [scheduler [light | m-light | medium | boost]] | ++io][--vm|++vm][--wifi|++wifi][--all|++all][--battery|++battery][--effect|++effect][--status][--help]" 1>&2
      echo -n "\nNote 1: each \"--\" prefixed option except \"--status\" and \"--help\" options is an enabler for its corresponding jitter reducer," 1>&2
      echo -n " conversely each \"++\" prefixed option is an disabler for its corresponding jitter reducer." 1>&2
      echo -n " \"--all\" option is an alias of all \"--\" prefixed options except \"--effect\", \"--battery\", \"--status\" and \"--help\" option," 1>&2
      echo      " and also \"++all\" option is an alias of all \"++\" prefixed options except \"++effect\" and \"++battery\" option." 1>&2
      echo -n "\nNote 2: \"scheduler\" specifys an I/O scheduler for I/O block devices " 1>&2
      echo -n "(typically \"deadline\", \"cfq\" or \"noop\", but you may specify \"*\" for automatical best selection), " 1>&2
      echo -n "and has optional four modes \"light\" (for warmer tone), \"m-light\" (for slightly warmer tone)," 1>&2
      echo     " \"medium\" (default) and \"boost\" (for clearer tone)." 1>&2
      echo     "\nNote 3: \"--wifi\" option is persistent even after reboot, but other options are not." 1>&2
}

selinuxFlag=0
thermalFlag=0
dozeFlag=0
governorFlag=0
cameraFlag=0
logdFlag=0
ioFlag=0
ioScheduler=""
toneMode="medium"
vmFlag=0
wifiFlag=0
wifiNoRestart=0
batteryFlag=0
effectFlag=0
printStatus=0

if [ $# -eq 0 ];then
    usage
    exit 0
else

    while [ $# -gt 0 ]; do
        
        case "$1" in
            "-a" | "--all" )
                selinuxFlag=1
                thermalFlag=1
                governorFlag=1
                cameraFlag=1
                logdFlag=1
                ioFlag=1
                vmFlag=1
                wifiFlag=1
                dozeFlag=1
                shift
                ;;
            "+a" | "++all" )
                selinuxFlag=-1
                thermalFlag=-1
                governorFlag=-1
                cameraFlag=-1
                logdFlag=-1
                ioFlag=-1
                vmFlag=-1
                wifiFlag=-1
                dozeFlag=-1
                shift
                ;;
            "-se" | "--selinux" )
                 selinuxFlag=1
                shift
                ;;
            "+se" | "++selinux" )
                selinuxFlag=-1
                shift
                ;;
            "-t" | "--thermal" )
                thermalFlag=1
                shift
                ;;
            "+t" | "++thermal" )
                thermalFlag=-1
                shift
                ;;
            "-d" | "--doze" )
                dozeFlag=1
                shift
                ;;
            "+d" | "++doze" )
                dozeFlag=-1
                shift
                ;;
            "-g" | "--governor" )
                governorFlag=1
                shift
                ;;
            "+g" | "++governor" )
                governorFlag=-1
                shift
                ;;
            "-c" | "--camera" )
                cameraFlag=1
                shift
                ;;
            "+c" | "++camera" )
                cameraFlag=-1
                shift
                ;;
            "-l" | "--logd" )
                logdFlag=1
                shift
                ;;
            "+l" | "++logd" )
                logdFlag=-1
                shift
                ;;
            "-i" | "--io" )
                ioFlag=1
                shift
                
                if [ $# -gt 0 ]; then
                
                    case "$1" in
                        -* )
                            ;;
                        * )
                            ioScheduler="$1"
                            shift
                            ;;
                     esac
                    
                    # Tone: "light", "medium", "boost", "exp"
                    if [ "$1" = "light" ]; then
                        toneMode="light" 
                        shift
                    elif [ "$1" = "m-light" ]; then
                        toneMode="m-light" 
                        shift
                    elif [ "$1" = "medium" ]; then
                        toneMode="medium" 
                        shift
                    elif [ "$1" = "boost" ]; then
                        toneMode="boost"
                        shift
                    elif [ "$1" = "exp" ]; then
                        toneMode="exp"
                        shift
                    elif expr "$1" : '[^-].*' >"/dev/null" 2>&1; then
                        echo "wrong I/O scheduler parameter (\"$1\"). valid parameters: light m-light medium boost" 1>&2
                        usage
                        exit 1
                    fi
                    
                fi
                
                ;;
            "+i" | "++io" )
                ioFlag=-1
                shift
                ;;
            "-v" | "--vm" )
                vmFlag=1
                shift
                ;;
            "+v" | "++vm" )
                vmFlag=-1
                shift
                ;;
            "-w" | "--wifi" )
                wifiFlag=1
                wifiNoRestart=0
                shift
                ;;
            "-wn" | "--wifi-no-restart" )
                wifiFlag=1
                wifiNoRestart=1
                shift
                ;;
            "+w" | "++wifi" )
                wifiFlag=-1
                wifiNoRestart=0
                shift
                ;;
            "-b" | "--battery" )
                batteryFlag=1
                shift
                ;;
            "+b" | "++battery" )
                batteryFlag=-1
                shift
                ;;
            "-e" | "--effect" )
                effectFlag=1
                shift
                ;;
            "+e" | "++effect" )
                effectFlag=-1
                shift
                ;;
            "-st" | "--status" )
                printStatus=1
                shift
                ;;
            "-h" | "--help" )
                usage
                exit 0
                ;;
            * )
                echo "wrong option (\"$1\")" 1>&2
                usage
                exit 1
                ;;
        esac
        
    done
    
fi

. "$MYDIR/jitter-reducer-functions.shlib"

reduceSelinuxJitter $selinuxFlag $printStatus
reduceGovernorJitter $governorFlag $printStatus
reduceThermalJitter $thermalFlag $printStatus
reduceDozeJitter $dozeFlag $printStatus
reduceLogdJitter $logdFlag $printStatus
reduceCameraJitter $cameraFlag $printStatus
reduceIoJitter "$ioFlag" "$ioScheduler" "$toneMode" "$printStatus"
reduceVmJitter $vmFlag $printStatus
if [ $wifiNoRestart -gt 0 ]; then
    reduceWifiJitter $wifiFlag "NoRestart" $printStatus
else
    reduceWifiJitter $wifiFlag "Restart" $printStatus
fi
reduceBatteryJitter $batteryFlag $printStatus
reduceEffectJitter $effectFlag $printStatus

if [ $? -eq 2 ]; then
    if [ $effectFlag -gt 0 ]; then
        echo "\n\"--effect\" option ignored (no resetprop commands found)" 1>&2
    elif [ $effectFlag -lt 0 ]; then
        echo "\n\"++effect\" option ignored (no resetprop commands found)" 1>&2
    fi
fi
