#!/bin/bash

PROFILE_FILE="$HOME/.config/omarchy/performance-profile"
OVERCLOCK_CONFIG="$HOME/.config/omarchy/overclock.conf"

get_performance_info() {
  local cpu_freq=$(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}')
  local cpu_temp=$(sensors | grep "Package id 0:" | awk '{print $4}' | tr -d '+°C' || echo "0")
  local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
  local mem_total=$(free -m | awk 'NR==2{print $2}')
  local mem_used=$(free -m | awk 'NR==2{print $3}')
  local mem_percent=$(awk "BEGIN {printf \"%.1f\", ($mem_used/$mem_total)*100}")

  local gpu_temp="0"
  local gpu_usage="0"
  if command -v nvidia-smi &>/dev/null; then
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
  fi

  local profile=$(cat "$PROFILE_FILE" 2>/dev/null || echo "balanced")
  local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")

  cat <<EOF
{
  "cpu": {
    "frequency": $cpu_freq,
    "temperature": $cpu_temp,
    "usage": $cpu_usage,
    "governor": "$governor"
  },
  "memory": {
    "total": $mem_total,
    "used": $mem_used,
    "percent": $mem_percent
  },
  "gpu": {
    "temperature": $gpu_temp,
    "usage": $gpu_usage
  },
  "profile": "$profile"
}
EOF
}

set_profile() {
  local profile="$1"

  case "$profile" in
  power-save)
    echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
    echo "auto" | sudo tee /sys/class/drm/card*/device/power_dpm_force_performance_level >/dev/null 2>&1
    ;;
  balanced)
    echo "schedutil" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
    echo "auto" | sudo tee /sys/class/drm/card*/device/power_dpm_force_performance_level >/dev/null 2>&1
    ;;
  performance)
    echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
    echo "high" | sudo tee /sys/class/drm/card*/device/power_dpm_force_performance_level >/dev/null 2>&1
    ;;
  overclock)
    apply_overclock
    ;;
  esac

  echo "$profile" >"$PROFILE_FILE"
  notify-send "Performance Profile" "Switched to $profile mode"
  get_performance_info
}

apply_overclock() {
  if [ ! -f "$OVERCLOCK_CONFIG" ]; then
    echo "No overclock configuration found"
    return 1
  fi

  source "$OVERCLOCK_CONFIG"

  # CPU overclock
  if [ -n "$CPU_MAX_FREQ" ]; then
    echo "$CPU_MAX_FREQ" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq >/dev/null
  fi

  # GPU overclock (NVIDIA)
  if command -v nvidia-settings &>/dev/null && [ -n "$GPU_OFFSET" ]; then
    nvidia-settings -a "[gpu:0]/GPUGraphicsClockOffset[3]=$GPU_OFFSET" >/dev/null 2>&1
  fi

  # AMD GPU overclock
  if [ -n "$GPU_POWER_CAP" ]; then
    echo "$GPU_POWER_CAP" | sudo tee /sys/class/drm/card*/device/hwmon/hwmon*/power1_cap >/dev/null 2>&1
  fi

  echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
}

restore_profile() {
  local profile=$(cat "$PROFILE_FILE" 2>/dev/null || echo "balanced")
  set_profile "$profile"
}

get_process_list() {
  ps aux --sort=-%cpu | head -11 | tail -10 | while read -r user pid cpu mem vsz rss tty stat start time command; do
    echo "{\"pid\":$pid,\"user\":\"$user\",\"cpu\":$cpu,\"mem\":$mem,\"command\":\"$command\"}"
  done | jq -s '.'
}

case "$1" in
info)
  get_performance_info
  ;;
profile)
  set_profile "$2"
  ;;
restore)
  restore_profile
  ;;
processes)
  get_process_list
  ;;
*)
  echo '{"error":"Unknown command"}'
  exit 1
  ;;
esac
