#!/system/bin/sh

myName="${0##*/}"

function usage() {
      echo "Usage: $myName [--selinux|++selinux][--thermal|++thermal][---governor|++governor][--camera|++camera][--io|++io][--vm|++vm][--all|++all][--effect|++effect][--status][--help]" 1>&2
      echo "  Note: \"--all\" is an alias of all \"--\" prefixed options except \"--effect\", \"--status\" and \"--help\"," 1>&2
      echo "           conversely \"++all\" is an alias of all \"++\" prefixed options except \"++effect\"." 1>&2
}

selinuxFlag=0
thermalFlag=0
governorFlag=0
cameraFlag=0
ioFlag=0
vmFlag=0
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
	      governorFlag=1
	      cameraFlag=1
	      ioFlag=1
	      vmFlag=1
	      shift
	      ;;
	    "+a" | "++all" )
	      selinuxFlag=-1
	      thermalFlag=-1
	      governorFlag=-1
	      cameraFlag=-1
	      ioFlag=-1
	      vmFlag=-1
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

function forceOnlineCPUs() {
    for i in `seq 0 9`; do
        if [ -e "/sys/devices/system/cpu/cpu$i/online" ]; then
            chmod 644 "/sys/devices/system/cpu/cpu$i/online"
            echo '1' >"/sys/devices/system/cpu/cpu$i/online"
        fi
    done
}

function searchDefaultCpuGovernor() {
  # Search default CPU governor
  local gov=""
  for i in `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`; do
    if [ "$i" = "schedutil" ]; then
      gov="schedutil"
      break;
    elif [ ! "$gov" = "schedplus" ]; then
      if [ "$i" = "schedplus" ]; then
        gov="$i"
      elif [ ! "$gov" = "interactive" ]; then
        gov="$i"
      fi
    fi
  done
  if [ -z "$gov" ]; then
    gov="performance"
  fi
  echo "$gov"
}

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
  # Stop the thermal server
  if [ "`getprop init.svc.thermal`" = "running" ]; then
    setprop ctl.stop thermal
  fi
  # For MediaTek CPU's
  if [ -w "/proc/cpufreq/cpufreq_sched_disable" ]; then
    echo '1' > "/proc/cpufreq/cpufreq_sched_disable"
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
  # Start the thermal server
  if [ "`getprop init.svc.thermal`" = "stopped" ]; then
    setprop ctl.start thermal
  fi
  # For MediaTek CPU's
  if [ -w "/proc/cpufreq/cpufreq_sched_disable" ]; then
    val="`searchDefaultCpuGovernor`"
    if [ "$val" = "schedutil" ]; then
      echo "  Notice: EAS has been enabled, so skipping thermal MTK EAS+ enabling" 1>&2
    else
      echo '0' > "/proc/cpufreq/cpufreq_sched_disable"
    fi
  fi

fi

if [ $governorFlag -gt 0 ]; then
  # CPU governor
  # prevent CPU offline stuck by forcing online between double  governor writing 
  for i in `seq 0 9`; do
    if [ -e "/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor" ]; then
      chmod 644 "/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
      echo 'performance' >"/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
      chmod 644 "/sys/devices/system/cpu/cpu$i/online"
      echo '1' >"/sys/devices/system/cpu/cpu$i/online"
      echo 'performance' >"/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
    fi
  done
  # Qcomm GPU's
  if [ -w "/sys/class/kgsl/kgsl-3d0/pwrscale/trustzone/governor" ]; then
    echo 'performance' >"/sys/class/kgsl/kgsl-3d0/pwrscale/trustzone/governor"
  elif [ -w "/sys/class/kgsl/kgsl-3d0/devfreq/governor" ]; then
    echo 'performance' >"/sys/class/kgsl/kgsl-3d0/devfreq/governor"
  fi
elif [ $governorFlag -lt 0 ]; then
  gov="`searchDefaultCpuGovernor`"
  # prevent CPU offline stuck by forcing online between double  governor writing 
  for i in `seq 0 9`; do
    if [ -e "/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor" ]; then
      chmod 644 "/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
      echo "$gov" >"/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
      chmod 644 "/sys/devices/system/cpu/cpu$i/online"
      echo '1' >"/sys/devices/system/cpu/cpu$i/online"
      echo "$gov" >"/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
    fi
  done
  # Qcomm default GPU governor
  if [ -w "/sys/class/kgsl/kgsl-3d0/pwrscale/trustzone/governor" ]; then
    echo 'ondemand' >"/sys/class/kgsl/kgsl-3d0/pwrscale/trustzone/governor"
  elif [ -w "/sys/class/kgsl/kgsl-3d0/devfreq/governor" ]; then
    echo 'msm-adreno-tz' >"/sys/class/kgsl/kgsl-3d0/devfreq/governor"
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
      echo 'noop' >"/sys/block/$i/queue/scheduler"
      echo '8192' >"/sys/block/$i/queue/read_ahead_kb"
      echo '0' >"/sys/block/$i/queue/iostats"
      echo '2' >"/sys/block/$i/queue/rq_affinity"
      echo '2' >"/sys/block/$i/queue/nomerges"
      echo '14210' >"/sys/block/$i/queue/nr_requests"
    fi
  done
elif [ $ioFlag -lt 0 ]; then
  for i in sda mmcblk0 mmcblk1; do
    if [ -d "/sys/block/$i/queue" ]; then
      echo 'cfq' >"/sys/block/$i/queue/scheduler"
      echo '128' >"/sys/block/$i/queue/read_ahead_kb"
      echo '1' >"/sys/block/$i/queue/iostats"
      echo '1' >"/sys/block/$i/queue/rq_affinity"
      echo '0' >"/sys/block/$i/queue/nomerges"
      echo '128' >"/sys/block/$i/queue/nr_requests"
    fi
  done
fi

if [ $vmFlag -gt 0 ]; then
  echo '0' >"/proc/sys/vm/swappiness"
  echo '50' >"/proc/sys/vm/dirty_ratio"
  echo '25' >"/proc/sys/vm/dirty_background_ratio"
  echo '60000' >"/proc/sys/vm/dirty_expire_centisecs"
  echo '11100' >"/proc/sys/vm/dirty_writeback_centisecs"
  echo '1' >"/proc/sys/vm/laptop_mode"
elif [ $vmFlag -lt 0 ]; then
  if [ -e "/dev/block/zram0" ]; then
    echo '100' >"/proc/sys/vm/swappiness"
  else
    echo '60' >"/proc/sys/vm/swappiness"
  fi
  echo '20' >"/proc/sys/vm/dirty_ratio"
  echo '5' >"/proc/sys/vm/dirty_background_ratio"
  echo '200' >"/proc/sys/vm/dirty_expire_centisecs"
  echo '500' >"/proc/sys/vm/dirty_writeback_centisecs"
  echo '0' >"/proc/sys/vm/laptop_mode"
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
    else
      echo "ignoring \"--effect\" option (no resetprop commands found)" 1>&2
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
    else
      echo "ignoring \"++effect\" option (no resetprop commands found)" 1>&2
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
  elif [ -n "`getprop init.svc.thermal`" ]; then
    echo "  Thermal server: `getprop init.svc.thermal`"
  else
    echo "  Thermal control: N/A"
  fi

  if [ -n "`getprop init.svc.mpdecision`" ]; then
      echo "  Thermal MPDecision: `getprop init.svc.mpdecision`"
  elif [ -n "`getprop init.svc.vendor.mpdecision`" ]; then
      echo "  Thermal MPDecision: `getprop init.svc.vendor.mpdecision`"
  fi

  # For MediaTek CPU's
  if [ -r "/proc/cpufreq/cpufreq_sched_disable" ]; then
    set `cat /proc/cpufreq/cpufreq_sched_disable`
    val=$3
    if [ "$val" -eq '1' ]; then
      echo "  Thermal MTK EAS+: stopped"
    else
      echo "  Thermal MTK EAS+: running"
    fi
  fi

  #CPU Governor
  if [ -r "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]; then
      echo "  Governor CPU: `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`"
  fi
  # Qcomm GPU
  if [ -r "/sys/class/kgsl/kgsl-3d0/pwrscale/trustzone/governor" ]; then
    echo "  Governor GPU: `cat /sys/class/kgsl/kgsl-3d0/pwrscale/trustzone/governor`"
  elif [ -w "/sys/class/kgsl/kgsl-3d0/devfreq/governor" ]; then
    echo "  Governor GPU: `cat /sys/class/kgsl/kgsl-3d0/devfreq/governor`"
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
      val=`cat /sys/block/$i/queue/scheduler`
      echo "  I/O scheduler: $val"
      val=`cat /sys/block/$i/queue/read_ahead_kb`
      echo "  I/O read ahead size: $val KB"
      val=`cat /sys/block/$i/queue/iostats`
      echo "  I/O iostat: $val"
      val=`cat /sys/block/$i/queue/rq_affinity`
      echo "  I/O rq affinity: $val"
      val=`cat /sys/block/$i/queue/nomerges`
      echo "  I/O nomerges: $val"
      val=`cat /sys/block/$i/queue/nr_requests`
      echo "  I/O nr requests: $val"
      break
    fi
  done

  val=`cat /proc/sys/vm/swappiness`
  if [ -n "$val" ]; then
    echo "  VM swappiness: $val"
  fi
  val=`cat /proc/sys/vm/dirty_ratio`
  if [ -n "$val" ]; then
    echo "  VM dirty ratio: $val"
  fi
  val=`cat /proc/sys/vm/dirty_background_ratio`
  if [ -n "$val" ]; then
    echo "  VM dirty background ratio: $val"
  fi
  val=`cat /proc/sys/vm/dirty_expire_centisecs`
  if [ -n "$val" ]; then
    echo "  VM dirty expire centisecs: $val"
  fi
  val=`cat /proc/sys/vm/dirty_writeback_centisecs`
  if [ -n "$val" ]; then
    echo "  VM dirty writeback centisecs: $val"
  fi
  val=`cat /proc/sys/vm/laptop_mode`
  if [ "$val" = "1" ]; then
    echo "  VM laptop mode: on"
  else
    echo "  VM laptop mode: off"
  fi

  val="`getprop ro.audio.ignore_effects`"
  if [ -n "$val"  -a  "$val" = "true" ]; then
    echo "  Effects framework: disabled"
  else
    echo "  Effects framework: enabled"
  fi
fi
