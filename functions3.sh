#!/system/bin/sh
#

  MYDIR=${0%/*}

# Forcing to reload audioservers
  function reloadAudioServers() 
  {
    setprop ctl.restart audioserver
    local stat=$?
    if [ $# -gt 0  -a  "$1" = "all" ]; then
      audioHal="$(getprop |sed -nE 's/.*init\.svc\.(.*audio-hal[^]]*).*/\1/p')"
      setprop ctl.restart "$audioHal" 1>"/dev/null" 2>&1
      setprop ctl.restart vendor.audio-hal-2-0 1>"/dev/null" 2>&1
      setprop ctl.restart audio-hal-2-0 1>"/dev/null" 2>&1
    fi
    return $stat
  }

# Find mount points paired with arg2 ("/data/...") in arg1 (typycally "/proc/self/mountinfo"). 
#   arg3 1: show a key with its paired mount point, 0: moun point only.
  function findMounts() 
  {
    if [ $# -ne 3 ]; then
      return 1
    elif [ ! -r "$1"  -o  `expr "$2" : /data` -ne 5 ]; then
      return 1
    fi

    local mf=${2:5}    
    local showKey=0
    case "$3" in
      "true" | "1" )
          showKey=1
        ;;
      "false" | "0" )
          showKey=0
        ;;
    esac
    
     awk -v showKey=$showKey -v mFile="^$mf\$|^$mf//deleted$" '
       BEGIN { 
         status=1
       }
       $4 ~ mFile  && $10 ~ /^\/dev\/block\// {
         if (showKey)
             print $4 " " $5
         else
             print  $5
         status=0
       }
       END {
          exit status 
       }' <"$1"
  }

# Find a mount point arg2 in arg1 (typycally "/proc/self/mountinfo"). 
#   arg3 1: print a key with its specified mount point, 0: don't print.
#   If found, then return 0 else return 1
  function isMounted() {
    if [ $# -ne 3 ]; then
      return 1
    elif [ ! -r "$1" ]; then
      return 1
    fi

    local mf="$2"
    local showKey=0
    case "$3" in
      "true" | "1" )
          showKey=1
        ;;
      "false" | "0" )
          showKey=0
        ;;
    esac

     awk -v showKey=$showKey -v mFile="^$mf\$" '
     BEGIN {
          status=1
     }
      $5 ~ mFile  && $10 ~ /^\/dev\/block\//{
            if (showKey)
                print $4 " " $5
            status=0
            exit
      }
      END {
            exit status
      }' <"$1"
  }

# Remove somewheres bind mounted with arg1
  function removeMountPoints()
  {
    if [ $# -eq 1 ]; then
      local mDirs="`findMounts \"/proc/self/mountinfo\" \"$1\" 0`"
      if [ -n "$mDirs" ]; then
        local i
        for i in $mDirs ; do
          if [ -e "$i" ]; then
            case "$i" in
              /data/local/tmp/* )
                  ;;
             * )
                  umount "$i" 1>"/dev/null" 2>&1
                  ;;
            esac
          fi
        done
      fi
    fi
    return 0
 }
 
# Remove arg1 file probaby bind mounted somewheres
  function removeGenFile()
  {
    if [ $# -eq 1 ]; then
        removeMountPoints "$1"
        if [ -e "$1" ]; then
          rm -f "$1"
        fi
        # Remove Magisk overlayed files. The above remove may fail.
        removeMountPoints "$1"
        return $?
    fi
    return 1
 }

# Get the active audio policy configuration fille from the audioserever
  function getActivePolicyFile()
  {
     dumpsys media.audio_policy | awk ' 
	 /^ Config source: / {
	     print $3
	  }' 
  }
  
# Make a configuration file for this script
  function makeConfigFile()
  {
    if [ $# -eq 1 ]; then
      local policyFile="`getActivePolicyFile`"
      if [ ! -e "$policyFile" ]; then
        policyFile="/vendor/etc/audio_policy_configuration.xml"
      fi
      local bltHal
      if [ "`getprop persist.bluetooth.bluetooth_audio_hal.disabled`" = "true" ];then
         bltHal="legacy"
      elif [ -e "/vendor/lib64/hw/audio.bluetooth.default.so" ]; then
         bltHal="bypass"
      else
         bltHal="legacy"
      fi
      if [ -e "$1" ]; then
        rm -f "$1"
      fi
      cat <<_EOT_ > "$1"
PolicyFile="$policyFile"
BluetoothHal="$bltHal"
_EOT_
      return 0
    fi
    return 1
 }
