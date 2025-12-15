#!/bin/bash

get_bluetooth_status() {
  local powered=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
  local connected_devices=$(bluetoothctl devices Connected | wc -l)

  cat <<EOF
{
  "powered": "$powered",
  "connected_devices": $connected_devices
}
EOF
}

list_devices() {
  bluetoothctl devices | while read -r _ mac name; do
    local connected=$(bluetoothctl info "$mac" | grep "Connected: yes" >/dev/null && echo "true" || echo "false")
    local paired=$(bluetoothctl info "$mac" | grep "Paired: yes" >/dev/null && echo "true" || echo "false")
    local type=$(bluetoothctl info "$mac" | grep "Icon:" | awk '{print $2}')
    local battery=$(bluetoothctl info "$mac" | grep "Battery Percentage" | awk '{print $4}' | tr -d '()' || echo "null")

    echo "{\"mac\":\"$mac\",\"name\":\"$name\",\"connected\":$connected,\"paired\":$paired,\"type\":\"$type\",\"battery\":$battery}"
  done | jq -s '.'
}

toggle_bluetooth() {
  local powered=$(bluetoothctl show | grep "Powered" | awk '{print $2}')

  if [ "$powered" = "yes" ]; then
    bluetoothctl power off
    echo '{"status":"disabled"}'
  else
    bluetoothctl power on
    echo '{"status":"enabled"}'
  fi
}

connect_device() {
  local mac="$1"
  bluetoothctl connect "$mac" >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo '{"status":"success","message":"Connected"}'
  else
    echo '{"status":"error","message":"Connection failed"}'
  fi
}

disconnect_device() {
  local mac="$1"
  bluetoothctl disconnect "$mac" >/dev/null 2>&1
  echo '{"status":"success","message":"Disconnected"}'
}

pair_device() {
  local mac="$1"
  bluetoothctl pair "$mac" >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    bluetoothctl trust "$mac" >/dev/null 2>&1
    echo '{"status":"success","message":"Paired successfully"}'
  else
    echo '{"status":"error","message":"Pairing failed"}'
  fi
}

scan() {
  bluetoothctl --timeout 10 scan on >/dev/null 2>&1 &
  echo '{"status":"scanning"}'
}

case "$1" in
status)
  get_bluetooth_status
  ;;
list)
  list_devices
  ;;
toggle)
  toggle_bluetooth
  ;;
connect)
  connect_device "$2"
  ;;
disconnect)
  disconnect_device "$2"
  ;;
pair)
  pair_device "$2"
  ;;
scan)
  scan
  ;;
*)
  echo '{"error":"Unknown command"}'
  exit 1
  ;;
esac
