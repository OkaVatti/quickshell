#!/bin/bash

get_mail_count() {
    # Check if proton-bridge is running
    if ! pgrep -x proton-bridge > /dev/null; then
        echo '{"error":"Proton Bridge not running","unread":0}'
        return
    fi
    
    # Get unread count from local mail client (assuming mbsync or similar)
    local unread=$(find ~/.local/share/mail/proton/INBOX/new -type f 2>/dev/null | wc -l)
    
    cat <<EOF
{
  "unread": $unread,
  "status": "connected"
}
EOF
}

sync_mail() {
    if ! pgrep -x proton-bridge > /dev/null; then
        echo '{"error":"Proton Bridge not running"}'
        return
    fi
    
    notify-send "Mail" "Syncing mail..."
    mbsync -a > /dev/null 2>&1 &
    echo '{"status":"syncing"}'
}

open_mail() {
    xdg-open "https://mail.proton.me" &
    echo '{"status":"opened"}'
}

case "$1" in
    count)
        get_mail_count
        ;;
    sync)
        sync_mail
        ;;
    open)
        open_mail
        ;;
    *)
        echo '{"error":"Unknown command"}'
        exit 1
        ;;
esac