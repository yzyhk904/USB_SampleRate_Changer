#!/system/bin/sh
#
# Version: 2.2
#     by zyhk

  MYDIR=${0%/*}

# Check whether this script has been marked "disable", or not
  if [ ! -d "$MYDIR" ]; then
    echo "cannot get the current directory!" 1>&2 ; 
    exit 1
  elif [ -e "$MYDIR/disable" ] ; then
    echo "this script is now disabled!" 1>&2 ; 
    exit 0
  fi
 # End
 
# Help message
  policyMode="auto"
  resetMode="false"
  DRC_enabled="false"
  while [ $# -gt 0 ]; do
     case "$1" in
       "-o" | "--offload" )
         policyMode="offload"
         shift
         ;;
       "-b" | "--bypass-offload" )
         policyMode="bypass"
         shift
         ;;
       "-l" | "--legacy" )
         policyMode="legacy"
         shift
         ;;
       "-s" | "--safe" )
         policyMode="safe"
         shift
         ;;
       "-ss" | "--safest" )
         policyMode="safest"
         shift
         ;;
       "-u" | "--usb-only" )
         policyMode="usb"
         shift
         ;;
       "-a" | "--auto" )
         policyMode="auto"
         shift
         ;;
       "-d" | "--drc" )
         DRC_enabled="true"
         shift
         ;;
       "-r" | "--reset" )
         resetMode="true"
         shift
         ;;
       "-h" | "--help" | -* )
         echo "Usage: ${0##*/} [--reset][--auto][--usb-only][--legacy][--offload][--bypass-offload][--safe][--safest] [--drc] [[44k|48k|88k|96k|176k|192k|353k|384k|706k|768k] [[16|24|32]]]" 1>&2
         echo "  Note: ${0##*/} requires to unlock the USB audio class driver's limitation (upto 96kHz lock or 384kHz offload lock)" 1>&2
         echo "           if you specify greater than 96kHz or 384kHz (in case of offload)" 1>&2
         exit 0
         ;;
       * )
         break
         ;;
     esac
  done
# End of help message

  . "$MYDIR/functions3.sh"

  genfile="/data/local/tmp/audio_conf_generated.xml"
 
# Reset
  if "$resetMode"; then
    if [ -e "$MYDIR/config.sh" ]; then
      rm -f "$MYDIR/config.sh"
    fi
    removeGenFile "$genfile"
    if [ "`getprop init.svc.audioserver`" = "running" ]; then
      reloadAudioServers "all"
    fi
    exit 0
  fi
# Reset End
 
# Set parameters
  sRate="44100"
  bDepth="32"

  case $# in
    0 ) ;;
    1 )  sRate="$1";;
    2 )  sRate="$1"; bDepth="$2";;
    * )  echo "too many arguments (n=$#)!" 1>&2 ; exit 1;;
  esac
# End of setting parameters

# Normalize arguments
  case "$sRate" in
    "44k" | "44.1k" )
      sRate="44100"
      ;;
    "48k" )
      sRate="48000"
      ;;
    "88k" | "88.2k" )
      sRate="88200"
      ;;
    "96k" )
      sRate="96000"
      ;;
    "176k" | "176.4k" )
      sRate="176400"
      ;;
    "192k" )
      sRate="192000"
      ;;
    "352k" | "353k" | "352.8k" )
      sRate="352800"
      ;;
    "384k" )
      sRate="384000"
      ;;
    "705k" | "706k" | "705.6k" )
      sRate="705600"
      ;;
    "768k" )
      sRate="768000"
      ;;
     * )
      if expr "$sRate" : "[1-9][0-9]*$" 1>"/dev/null" 2>&1; then
          if [ $sRate -lt 44100  -o  $sRate -gt 768000 ]; then
            echo "unsupported sample rate (rate=$sRate)!" 1>&2 
            exit 1
          fi
      else
          echo "unsupported sample rate (rate=$sRate)!" 1>&2 
          exit 1
      fi
      ;;
  esac

  if [ ! "$policyMode" = "offload"  -a  $sRate -gt 96000 ]; then
    echo "    Warning: ${0##*/} requires to unlock the USB audio class driver's limitation (upto 96kHz lock)" 1>&2
  elif [ "$policyMode" = "offload"  -a  $sRate -gt 384000 ]; then
    echo "    Warning: ${0##*/} requires to unlock the USB audio hardware offload driver's limitation (upto 384kHz lock)" 1>&2
  fi

  aFormat="AUDIO_FORMAT_PCM_32_BIT"
  case "$bDepth" in
    16 )
      aFormat="AUDIO_FORMAT_PCM_16_BIT"
      ;;
    24 )
      aFormat="AUDIO_FORMAT_PCM_24_BIT_PACKED"
      ;;
    32 )
      aFormat="AUDIO_FORMAT_PCM_32_BIT"
      ;;
    * )
      echo "unknow bit depth specified (depth=$bDepth)!" 1>&2
      exit 1
      ;;
  esac
# End of argument normalization

# Overlay a generated audio policy configuration file on "/vendor/etc/audio_policy_configuration.xml" (e.g. typical)
  if [ ! -r "$MYDIR/config.sh" ]; then
    makeConfigFile "$MYDIR/config.sh"
  fi
  if [ -r "$MYDIR/config.sh" ]; then
     . "$MYDIR/config.sh"
   fi
  if [ -n "$PolicyFile" ];then
    overlayTarget="$PolicyFile"
  else
    overlayTarget="/vendor/etc/audio_policy_configuration.xml"
  fi
  if [ "$policyMode" = "auto"  -a  -n "$BluetoothHal" ];then
    policyMode="$BluetoothHal"
  fi
  case "$policyMode" in
    "offload" )
       template="$MYDIR/templates/offload_template.xml"
       ;;
    "bypass" )
       template="$MYDIR/templates/bypass_offload_template.xml"
        ;;
    "legacy" )
       template="$MYDIR/templates/legacy_template.xml"
       ;;
    "usb" )
       template="$MYDIR/templates/usb_only_template.xml"
       overlayTarget="/vendor/etc/usb_audio_policy_configuration.xml"
       ;;
    "safe" )
       template="$MYDIR/templates/safe_template.xml"
       ;;
    "safest" )
       template="$MYDIR/templates/safest_template.xml"
       ;;
     * )
       template="$MYDIR/templates/safe_template.xml"
       ;;
  esac

  if [ -r "$template" ]; then
    removeGenFile "$genfile"
    sed -e "s/%DRC_ENABLED%/$DRC_enabled/" -e "s/%SAMPLING_RATE%/$sRate/" -e "s/%AUDIO_FORMAT%/$aFormat/" "$template" >"$genfile"
    if [ $? -eq 0 ]; then
      chmod 644 "$genfile"
      chcon u:object_r:vendor_configs_file:s0 "$genfile"
      if [ -r "$overlayTarget" ]; then
        isMounted "/proc/self/mountinfo" "$overlayTarget" 0
        if [ $? -eq 0 ]; then
          umount "$overlayTarget" 1>"/dev/null" 2>&1
        fi
        mount -o bind "$genfile" "$overlayTarget"
        if [ $? -gt 0 ]; then
          echo "overlaying a generated USB configuration XML file failed!" 1>&2 
          exit 1
        fi
      else
        echo "overlaying target (\"$overlayTarget\") doesn't exist!" 1>&2 
        exit 1
      fi
    else
      echo "audio policy XML file genaration failed!" 1>&2 
      exit 1
    fi
  else
    echo "a template USB configuration file not found!" 1>&2 
    exit 1
  fi
# End of overlay system files

# Reload audio policy configuration files.  
  if [ "`getprop init.svc.audioserver`" = "running" ]; then
    reloadAudioServers
    if [ $? -gt 0 ]; then
      echo "audioserver reload failed!" 1>&2
      exit 1
    else
      exit 0
    fi
  else
    echo "audioserver is not running!" 1>&2 
    exit 1
  fi
# End of reload
