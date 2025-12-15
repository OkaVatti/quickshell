#!/bin/bash

get_audio_info() {
  local sink=$(pactl get-default-sink)
  local volume=$(pactl get-sink-volume "$sink" | grep -Po '\d+%' | head -1 | tr -d '%')
  local muted=$(pactl get-sink-mute "$sink" | grep -q "yes" && echo "true" || echo "false")

  local source=$(pactl get-default-source)
  local mic_volume=$(pactl get-source-volume "$source" | grep -Po '\d+%' | head -1 | tr -d '%')
  local mic_muted=$(pactl get-source-mute "$source" | grep -q "yes" && echo "true" || echo "false")

  cat <<EOF
{
  "volume": $volume,
  "muted": $muted,
  "mic_volume": $mic_volume,
  "mic_muted": $mic_muted,
  "sink": "$sink",
  "source": "$source"
}
EOF
}

list_sinks() {
  pactl list sinks short | while read -r id name driver sample state; do
    local default=$([ "$(pactl get-default-sink)" = "$name" ] && echo "true" || echo "false")
    local description=$(pactl list sinks | grep -A 20 "Name: $name" | grep "Description:" | cut -d: -f2- | xargs)
    echo "{\"id\":$id,\"name\":\"$name\",\"description\":\"$description\",\"default\":$default}"
  done | jq -s '.'
}

list_sources() {
  pactl list sources short | while read -r id name driver sample state; do
    local default=$([ "$(pactl get-default-source)" = "$name" ] && echo "true" || echo "false")
    local description=$(pactl list sources | grep -A 20 "Name: $name" | grep "Description:" | cut -d: -f2- | xargs)
    echo "{\"id\":$id,\"name\":\"$name\",\"description\":\"$description\",\"default\":$default}"
  done | jq -s '.'
}

volume_up() {
  pactl set-sink-volume @DEFAULT_SINK@ +5%
  get_audio_info
}

volume_down() {
  pactl set-sink-volume @DEFAULT_SINK@ -5%
  get_audio_info
}

set_volume() {
  pactl set-sink-volume @DEFAULT_SINK@ "$1%"
  get_audio_info
}

toggle_mute() {
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  get_audio_info
}

toggle_mic_mute() {
  pactl set-source-mute @DEFAULT_SOURCE@ toggle
  get_audio_info
}

set_sink() {
  pactl set-default-sink "$1"
  get_audio_info
}

set_source() {
  pactl set-default-source "$1"
  get_audio_info
}

case "$1" in
info)
  get_audio_info
  ;;
list-sinks)
  list_sinks
  ;;
list-sources)
  list_sources
  ;;
volume-up)
  volume_up
  ;;
volume-down)
  volume_down
  ;;
set-volume)
  set_volume "$2"
  ;;
toggle-mute)
  toggle_mute
  ;;
toggle-mic-mute)
  toggle_mic_mute
  ;;
set-sink)
  set_sink "$2"
  ;;
set-source)
  set_source "$2"
  ;;
*)
  echo '{"error":"Unknown command"}'
  exit 1
  ;;
esac
