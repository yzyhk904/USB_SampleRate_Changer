#!/system/bin/sh

myName="${0##*/}"

function usage() {
      echo "Usage: $myName [--selinux|++selinux] [--thermal|++thermal] [--camera|++camera] [--io|++io] [--all|++all] [--effect|++effect] [--status] [--help]" 1>&2
      echo "  Note: \"--all\" & \"++all\" options don't affect \"--effect\" & \"++effect\" options." 1>&2
}

function forceOnlineCPUs() {
    for i in `seq 0 9`; do
        if [ -e "/sys/devices/system/cpu/cpu$i/online" ]; then
            chmod 644 "/sys/devices/system/cpu/cpu$i/online"
            echo '1' >"/sys/devices/system/cpu/cpu$i/online"
        fi
    done
}

selinuxFlag=0
thermalFlag=0
cameraFlag=0
ioFlag=0
effectFlag=0
statusFlag=0
if [ $# -eq 0 ];then
      usage
      exit 0
else
  while [ $# -gt 0 ]; do
	  case "$1" in
	    "-a" | "--all" )
	      selinuxFlag=1
	      thermalFlag=1
	      cameraFlag=1
	      ioFlag=1
	      shift
	      ;;
	    "+a" | "++all" )
	      selinuxFlag=-1
	      thermalFlag=-1
	      cameraFlag=-1
	      ioFlag=-1
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
	      ;;
	    "+i" | "++io" )
	      ioFlag=-1
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
	      statusFlag=1
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

if [ $selinuxFlag -gt 0 ]; then
  setenforce 0
elif [ $selinuxFlag -lt 0 ]; then
  setenforce 1
fi

if [ $thermalFlag -gt 0 ]; then
  # Stop thermal core control
  if [ -w "/sys/module/msm_thermal/core_control/enabled" ]; then
    echo '0' > "/sys/module/msm_thermal/core_control/enabled"
  fi
  # Stop the MPDecision (CPU hotplug)
  if [ "`getprop init.svc.mpdecision`" = "running" ]; then
    setprop ctl.stop mpdecision
    forceOnlineCPUs
  elif [ "`getprop init.svc.vendor.mpdecision`" = "running" ]; then
    setprop ctl.stop vendor.mpdecision
    forceOnlineCPUs
  fi
elif [ $thermalFlag -lt 0 ]; then
  # Start thermal core control
  if [ -w "/sys/module/msm_thermal/core_control/enabled" ]; then
    echo '1' > "/sys/module/msm_thermal/core_control/enabled"
  fi
  # Start the MPDecision (CPU hotplug)
  if [ "`getprop init.svc.mpdecision`" = "stopped" ]; then
    setprop ctl.start mpdecision
    forceOnlineCPUs
  elif [ "`getprop init.svc.vendor.mpdecision`" = "stopped" ]; then
    setprop ctl.start vendor.mpdecision
    forceOnlineCPUs
  fi
fi

if [ $cameraFlag -gt 0 ]; then
  # Stop the camera servers
  if [ "`getprop init.svc.qcamerasvr`" = "running" ]; then
    setprop ctl.stop qcamerasvr
  fi
  if [ "`getprop init.svc.vendor.qcamerasvr`" = "running" ]; then
    setprop ctl.stop vendor.qcamerasvr
  fi
  if [ "`getprop init.svc.cameraserver`" = "running" ]; then
    setprop ctl.stop cameraserver
  fi
  if [ "`getprop init.svc.camerasloganserver`" = "running" ]; then
    setprop ctl.stop camerasloganserver
  fi
  if [ "`getprop init.svc.camerahalserver`" = "running" ]; then
    setprop ctl.stop camerahalserver
  fi
elif [ $cameraFlag -lt 0 ]; then
  # Start the camera servers
  if [ "`getprop init.svc.qcamerasvr`" = "stopped" ]; then
    setprop ctl.start qcamerasvr
  fi
  if [ "`getprop init.svc.vendor.qcamerasvr`" = "stopped" ]; then
    setprop ctl.start vendor.qcamerasvr
  fi
  if [ "`getprop init.svc.cameraserver`" = "stopped" ]; then
    setprop ctl.start cameraserver
  fi
  if [ "`getprop init.svc.camerasloganserver`" = "stopped" ]; then
    setprop ctl.start camerasloganserver
  fi
  if [ "`getprop init.svc.camerahalserver`" = "stopped" ]; then
    setprop ctl.start camerahalserver
  fi
fi

if [ $ioFlag -gt 0 ]; then
  for i in sda mmcblk0 mmcblk1; do
    if [ -d "/sys/block/$i/queue" ]; then
      echo '8192' >"/sys/block/$i/queue/read_ahead_kb"
      echo '2' >"/sys/block/$i/queue/rq_affinity"
    fi
  done
elif [ $ioFlag -lt 0 ]; then
  for i in sda mmcblk0 mmcblk1; do
    if [ -d "/sys/block/$i/queue" ]; then
      echo '128' >"/sys/block/$i/queue/read_ahead_kb"
      echo '1' >"/sys/block/$i/queue/rq_affinity"
    fi
  done
fi

if [ $effectFlag -gt 0 ]; then
  type resetprop 1>/dev/null 2>&1
  if [ $? -eq 0 ]; then
    resetprop ro.audio.ignore_effects true
    setprop ctl.restart audioserver
  else
    type resetprop_phh 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
      resetprop_phh ro.audio.ignore_effects true
      setprop ctl.restart audioserver
    fi
  fi
elif [ $effectFlag -lt 0 ]; then
  type resetprop 1>/dev/null 2>&1
  if [ $? -eq 0 ]; then
    resetprop --delete ro.audio.ignore_effects
    setprop ctl.restart audioserver
  else
    type resetprop_phh 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
      resetprop_phh --delete ro.audio.ignore_effects
      setprop ctl.restart audioserver
    fi
  fi
fi

if [ $statusFlag -gt 0 ]; then
  echo "Jitter related Statuses:"

  echo "  Selinux mode: `getenforce`"

  if [ -w "/sys/module/msm_thermal/core_control/enabled" ]; then
    if [ "`cat /sys/module/msm_thermal/core_control/enabled`" -eq 0 ]; then
      echo "  Thermal core control: stopped"
    else
      echo "  Thermal core control: running"
    fi
  else
    echo "  Thermal core control: N/A"
  fi

  if [ -n "`getprop init.svc.mpdecision`" ]; then
      echo "  Thermal MPDecision: `getprop init.svc.mpdecision`"
  elif [ -n "`getprop init.svc.vendor.mpdecision`" ]; then
      echo "  Thermal MPDecision: `getprop init.svc.vendor.mpdecision`"
  fi

  val="`getprop init.svc.qcamerasvr`"
  if [ -n  "$val" ]; then
    echo "  Qcom camera server: $val"
  fi
  val="`getprop init.svc.vendor.qcamerasvr`"
  if [ -n  "$val" ]; then
    echo "  Qcom camera server: $val"
  fi
  val="`getprop init.svc.cameraserver`"
  if [ -n  "$val" ]; then
    echo "  Camera server: $val"
  fi

  for i in sda mmcblk0 mmcblk1; do
    if [ -d "/sys/block/$i/queue" ]; then
      val=`cat /sys/block/$i/queue/read_ahead_kb`
      echo "  I/O Scheduler ($i) read ahead size: $val KB"
      val=`cat /sys/block/$i/queue/rq_affinity`
      echo "  I/O Scheduler ($i) request affinity: $val"
    fi
  done

  val="`getprop ro.audio.ignore_effects`"
  if [ -n "$val"  -a  "$val" = "true" ]; then
    echo "  Effect config.: disabled"
  else
    echo "  Effect config.: enabled"
  fi
fi
