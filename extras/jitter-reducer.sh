#!/system/bin/sh

NR_REQUESTS_DEFAULT=30000

myName="${0##*/}"
MYDIR="${0%/*}"

function usage() {
      echo "Usage: $myName [--selinux|++selinux][--thermal|++thermal][---governor|++governor][--camera|++camera][--io [nr_requests]|++io][--vm|++vm][--wifi|++wifi][--all|++all][--effect|++effect][--status][--help]" 1>&2
      echo "  Note 1.: each \"--\" prefixed option except \"--status\" and \"--help\" options is an enabler for its corresponding jitter reducer," 1>&2
      echo "           conversely each \"++\" prefixed option is an disabler for its corresponding jitter reducer." 1>&2
      echo "          \"--all\" option is an alias of all \"--\" prefixed options except \"--effect\", \"--status\" and \"--help\" options," 1>&2
      echo "           and also  \"++all\" option is an alias of all \"++\" prefixed options except \"++effect\"." 1>&2
      echo "  Note 2.: \"--wifi\" option is persistent even after reboot, but other options are not" 1>&2
}

selinuxFlag=0
thermalFlag=0
governorFlag=0
cameraFlag=0
ioFlag=0
vmFlag=0
wifiFlag=0
effectFlag=0
printStatus=0

nr_requests="$NR_REQUESTS_DEFAULT"

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
                ioFlag=1
                vmFlag=1
                wifiFlag=1
                shift
                ;;
            "+a" | "++all" )
                selinuxFlag=-1
                thermalFlag=-1
                governorFlag=-1
                cameraFlag=-1
                ioFlag=-1
                vmFlag=-1
                wifiFlag=-1
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
            "-i" | "--io" )
                ioFlag=1
                shift
                
                if [ $# -gt 0 ]; then
                    # Presets: "light", "medium", "boost"; then numbers
                    if [ "$1" = "light" ]; then
                        nr_requests=14210
                        shift
                    elif [ "$1" = "medium" ]; then
                        nr_requests="$NR_REQUESTS_DEFAULT"
                        shift
                    elif [ "$1" = "boost" ]; then
                        nr_requests=60000
                        shift
                    elif expr "$1" : "[1-9][0-9]*$" 1>"/dev/null" 2>&1; then
                    
                        if [ "$1" -lt 32  -o  "$1" -gt 64000 ]; then
                            echo "Warning: unsupported \"nr requests\" ignored (nr_requests=$1; 32<=nr_requests<=64000)!" 1>&2
                        else
                            nr_requests="$1"
                        fi
                        
                        shift
                        
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
                shift
                ;;
            "+w" | "++wifi" )
                wifiFlag=-1
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
            -* | * )
                echo "wrong argument ($1)" 1>&2
                usage
                exit 1
                ;;
        esac
        
    done
    
fi

. "$MYDIR/jitter-reducer-functions.shlib"

reduceSelinuxJitter $selinuxFlag $printStatus
reduceThermalJitter $thermalFlag $printStatus
reduceGovernorJitter $governorFlag $printStatus
reduceCameraJitter $cameraFlag $printStatus
reduceIoJitter $ioFlag $nr_requests $printStatus
reduceVmJitter $vmFlag $printStatus
reduceWifiJitter $wifiFlag "NoRestart" $printStatus
reduceEffectJitter $effectFlag $printStatus

if [ $? -eq 2 ]; then
    if [ $effectFlag -gt 0 ]; then
        echo "\n\"--effect\" option ignored (no resetprop commands found)" 1>&2
    elif [ $effectFlag -lt 0 ]; then
        echo "\n\"++effect\" option ignored (no resetprop commands found)" 1>&2
    fi
fi
