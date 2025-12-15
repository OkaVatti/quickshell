// FILE: /home/lilith/code-shit/quickshell/omarchy/scripts/notifications.sh
#!/bin/bash

get_notification_count() {
    # Check for notifications using mako or swaync
    local count=0
    
    if command -v makoctl &> /dev/null; then
        count=$(makoctl list | jq -r '.data[] | length' 2>/dev/null || echo 0)
    elif [ -f ~/.cache/swaync/notifications.json ]; then
        count=$(jq -r '.data | length' ~/.cache/swaync/notifications.json 2>/dev/null || echo 0)
    fi
    
    cat <<EOF
{
  "count": $count
}
EOF
}

list_notifications() {
    if command -v makoctl &> /dev/null; then
        makoctl list
    elif [ -f ~/.cache/swaync/notifications.json ]; then
        cat ~/.cache/swaync/notifications.json
    else
        echo '{"data":[]}'
    fi
}

dismiss_all() {
    if command -v makoctl &> /dev/null; then
        makoctl dismiss --all
    elif command -v swaync-client &> /dev/null; then
        swaync-client -c
    fi
    
    echo '{"status":"dismissed"}'
}

case "$1" in
    count)
        get_notification_count
        ;;
    list)
        list_notifications
        ;;
    dismiss)
        dismiss_all
        ;;
    *)
        echo '{"error":"Unknown command"}'
        exit 1
        ;;
esac