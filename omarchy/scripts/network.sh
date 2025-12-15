#!/bin/bash

CACHE_FILE="/tmp/network-info-cache"
CACHE_TIMEOUT=2

get_cached_or_update() {
  if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_TIMEOUT ]; then
    cat "$CACHE_FILE"
  else
    get_network_info >"$CACHE_FILE"
    cat "$CACHE_FILE"
  fi
}

get_network_info() {
  local interface=$(ip route | grep default | awk '{print $5}' | head -n1)
  local ip_address=$(ip addr show "$interface" 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
  local gateway=$(ip route | grep default | awk '{print $3}' | head -n1)
  local dns=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -n1)

  # Get connection type
  if [[ "$interface" =~ ^wl ]]; then
    local ssid=$(iwgetid -r)
    local signal=$(awk 'NR==3 {printf "%.0f", ($3/70)*100}' /proc/net/wireless 2>/dev/null || echo "0")
    local conn_type="WiFi"
  else
    local ssid="Wired"
    local signal="100"
    local conn_type="Ethernet"
  fi

  # Get speeds
  local rx_bytes_old=$(cat /sys/class/net/"$interface"/statistics/rx_bytes 2>/dev/null || echo 0)
  local tx_bytes_old=$(cat /sys/class/net/"$interface"/statistics/tx_bytes 2>/dev/null || echo 0)
  sleep 1
  local rx_bytes_new=$(cat /sys/class/net/"$interface"/statistics/rx_bytes 2>/dev/null || echo 0)
  local tx_bytes_new=$(cat /sys/class/net/"$interface"/statistics/tx_bytes 2>/dev/null || echo 0)

  local rx_speed=$(((rx_bytes_new - rx_bytes_old) / 1024))
  local tx_speed=$(((tx_bytes_new - tx_bytes_old) / 1024))

  cat <<EOF
{
  "interface": "$interface",
  "type": "$conn_type",
  "ssid": "$ssid",
  "signal": $signal,
  "ip": "$ip_address",
  "gateway": "$gateway",
  "dns": "$dns",
  "download": $rx_speed,
  "upload": $tx_speed,
  "connected": true
}
EOF
}

list_wifi_networks() {
  nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list | while IFS=: read -r ssid signal security; do
    echo "{\"ssid\":\"$ssid\",\"signal\":$signal,\"security\":\"$security\"}"
  done | jq -s '.'
}

connect_wifi() {
  local ssid="$1"
  local password="$2"

  if [ -z "$password" ]; then
    nmcli dev wifi connect "$ssid"
  else
    nmcli dev wifi connect "$ssid" password "$password"
  fi

  if [ $? -eq 0 ]; then
    echo '{"status":"success","message":"Connected to '"$ssid"'"}'
  else
    echo '{"status":"error","message":"Failed to connect"}'
  fi
}

disconnect() {
  local interface=$(ip route | grep default | awk '{print $5}' | head -n1)
  nmcli dev disconnect "$interface"
  echo '{"status":"success","message":"Disconnected"}'
}

toggle_wifi() {
  local status=$(nmcli radio wifi)
  if [ "$status" = "enabled" ]; then
    nmcli radio wifi off
    echo '{"status":"disabled"}'
  else
    nmcli radio wifi on
    echo '{"status":"enabled"}'
  fi
}

case "$1" in
info)
  get_cached_or_update
  ;;
list)
  list_wifi_networks
  ;;
connect)
  connect_wifi "$2" "$3"
  ;;
disconnect)
  disconnect
  ;;
toggle)
  toggle_wifi
  ;;
*)
  echo '{"error":"Unknown command"}'
  exit 1
  ;;
esac
