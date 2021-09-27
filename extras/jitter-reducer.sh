#!/system/bin/sh

myName="${0##*/}"
function usage() {
      echo "Usage: $myName [--status] [--selinux|++selinux] [--thermal|++thermal] [--camera|++camera] [--all|++all] [--help]" 1>&2
}

selinuxFlag=0
thermalFlag=0
cameraFlag=0
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
	      shift
	      ;;
	    "+a" | "++all" )
	      selinuxFlag=-1
	      thermalFlag=-1
	      cameraFlag=-1
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
  if [ -w "/sys/module/msm_thermal/core_control/enabled" ]; then
    echo '0' > "/sys/module/msm_thermal/core_control/enabled"
  fi
elif [ $thermalFlag -lt 0 ]; then
  if [ -w "/sys/module/msm_thermal/core_control/enabled" ]; then
    echo '1' > "/sys/module/msm_thermal/core_control/enabled"
  fi
fi

if [ $cameraFlag -gt 0 ]; then
  # Stop the camera servers
  if [ "`getprop init.svc.qcamerasvr`" = "running" ]; then
    setprop ctl.stop qcamerasvr
    stop qcamerasvr
  fi
  if [ "`getprop init.svc.vendor.qcamerasvr`" = "running" ]; then
    setprop ctl.stop vendor.qcamerasvr
    stop vendor.qcamerasvr
  fi
  if [ "`getprop init.svc.cameraserver`" = "running" ]; then
    setprop ctl.stop cameraserver
    stop cameraserver
  fi
  if [ "`getprop init.svc.camerasloganserver`" = "running" ]; then
    setprop ctl.stop camerasloganserver
    stop camerasloganserver
  fi
  if [ "`getprop init.svc.camerahalserver`" = "running" ]; then
    setprop ctl.stop camerahalserver
    stop camerahalserver
  fi
elif [ $cameraFlag -lt 0 ]; then
  # Start the camera servers
  if [ "`getprop init.svc.qcamerasvr`" = "stopped" ]; then
    setprop ctl.start qcamerasvr
    start qcamerasvr
  fi
  if [ "`getprop init.svc.vendor.qcamerasvr`" = "stopped" ]; then
    setprop ctl.start vendor.qcamerasvr
    start vendor.qcamerasvr
  fi
  if [ "`getprop init.svc.cameraserver`" = "stopped" ]; then
    setprop ctl.start cameraserver
    start cameraserver
  fi
  if [ "`getprop init.svc.camerasloganserver`" = "stopped" ]; then
    setprop ctl.start camerasloganserver
    start camerasloganserver
  fi
  if [ "`getprop init.svc.camerahalserver`" = "stopped" ]; then
    setprop ctl.start camerahalserver
    start camerahalserver
  fi
fi

if [ $statusFlag -gt 0 ]; then
  echo "Jitter related Statuses:"

  echo "  Selinux mode=`getenforce`"

  if [ -w "/sys/module/msm_thermal/core_control/enabled" ]; then
    if [ "`cat /sys/module/msm_thermal/core_control/enabled`" -eq 0 ]; then
      echo "  Thermal core control: disabled"
    else
      echo "  Thermal core control: enabled"
    fi
  else
    echo "  Thermal core control: N/A"
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
fi
