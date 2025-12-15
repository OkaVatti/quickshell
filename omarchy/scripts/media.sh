#!/bin/bash

get_media_info() {
    local status=$(playerctl status 2>/dev/null || echo "Stopped")
    local title=$(playerctl metadata title 2>/dev/null || echo "")
    local artist=$(playerctl metadata artist 2>/dev/null || echo "")
    local album=$(playerctl metadata album 2>/dev/null || echo "")
    local art_url=$(playerctl metadata mpris:artUrl 2>/dev/null || echo "")
    local position=$(playerctl position 2>/dev/null || echo "0")
    local length=$(playerctl metadata mpris:length 2>/dev/null | awk '{print $1/1000000}' || echo "0")
    local player=$(playerctl -l 2>/dev/null | head -1 || echo "")

    # Convert position to seconds
    position=$(printf "%.0f" "$position" 2>/dev/null || echo "0")
    length=$(printf "%.0f" "$length" 2>/dev/null || echo "0")

    cat <<EOF
{
    "status": "$status",
    "title": "$title",
    "artist": "$artist",
    "album": "$album",
    "art_url": "$art_url",
    "position": $position,
    "length": $length,
    "player": "$player"
}
EOF
}

play_pause() {
    playerctl play-pause
    get_media_info
}

next() {
    playerctl next
    sleep 0.5
    get_media_info
}

previous() {
    playerctl previous
    sleep 0.5
    get_media_info
}

stop() {
    playerctl stop
    get_media_info
}

seek() {
    local offset="$1"
    playerctl position "$offset"
    get_media_info
}

list_players() {
    playerctl -l 2>/dev/null | while read -r player; do
        local status=$(playerctl -p "$player" status 2>/dev/null || echo "Stopped")
        echo "{\"player\":\"$player\",\"status\":\"$status\"}"
    done | jq -s '.'
}

switch_player() {
    local player="$1"
    export PLAYERCTL_PLAYER="$player"
    get_media_info
}

case "$1" in
    info)
        get_media_info
        ;;
    play-pause)
        play_pause
        ;;
    next)
        next
        ;;
    previous)
        previous
        ;;
    stop)
        stop
        ;;
    seek)
        seek "$2"
        ;;
    list-players)
        list_players
        ;;
    switch-player)
        switch_player "$2"
        ;;
    *)
        echo '{"error":"Unknown command"}'
        exit 1
        ;;
esac