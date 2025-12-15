#!/bin/bash

get_system_info() {
    local hostname=$(hostname)
    local kernel=$(uname -r)
    local uptime=$(uptime -p | sed 's/up //')
    local os=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2)
    
    # CPU info
    local cpu_model=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    local cpu_cores=$(nproc)
    local cpu_threads=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    
    # GPU info
    local gpu_model=""
    if command -v nvidia-smi &> /dev/null; then
        gpu_model=$(nvidia-smi --query-gpu=name --format=csv,noheader)
    elif lspci | grep -i vga | grep -qi amd; then
        gpu_model=$(lspci | grep -i vga | grep -i amd | cut -d':' -f3 | xargs)
    elif lspci | grep -i vga | grep -qi intel; then
        gpu_model=$(lspci | grep -i vga | grep -i intel | cut -d':' -f3 | xargs)
    fi
    
    # Memory info
    local mem_total=$(free -h | awk 'NR==2{print $2}')
    local mem_used=$(free -h | awk 'NR==2{print $3}')
    
    # Disk info
    local disk_total=$(df -h / | awk 'NR==2{print $2}')
    local disk_used=$(df -h / | awk 'NR==2{print $3}')
    local disk_percent=$(df -h / | awk 'NR==2{print $5}')
    
    # Display info
    local displays=$(swaymsg -t get_outputs | jq -r '.[] | .name + " (" + .current_mode.width + "x" + .current_mode.height + "@" + (.current_mode.refresh/1000|tostring) + "Hz)"' | paste -sd ',' -)
    
    cat <<EOF
{
  "hostname": "$hostname",
  "os": "$os",
  "kernel": "$kernel",
  "uptime": "$uptime",
  "cpu": {
    "model": "$cpu_model",
    "cores": $cpu_cores,
    "threads": $cpu_threads
  },
  "gpu": {
    "model": "$gpu_model"
  },
  "memory": {
    "total": "$mem_total",
    "used": "$mem_used"
  },
  "disk": {
    "total": "$disk_total",
    "used": "$disk_used",
    "percent": "$disk_percent"
  },
  "displays": "$displays"
}
EOF
}

case "$1" in
    info|"")
        get_system_info
        ;;
    *)
        echo '{"error":"Unknown command"}'
        exit 1
        ;;
esac