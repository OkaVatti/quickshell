#!/bin/bash

get_updates() {
    local pacman_updates=$(checkupdates 2>/dev/null | wc -l)
    local aur_updates=0
    
    if command -v yay &> /dev/null; then
        aur_updates=$(yay -Qua 2>/dev/null | wc -l)
    elif command -v paru &> /dev/null; then
        aur_updates=$(paru -Qua 2>/dev/null | wc -l)
    fi
    
    cat <<EOF
{
  "pacman": $pacman_updates,
  "aur": $aur_updates,
  "total": $((pacman_updates + aur_updates))
}
EOF
}

list_updates() {
    local updates=()
    
    checkupdates 2>/dev/null | while read -r pkg rest; do
        updates+=("{\"name\":\"$pkg\",\"type\":\"pacman\"}")
    done
    
    if command -v yay &> /dev/null; then
        yay -Qua 2>/dev/null | while read -r pkg rest; do
            updates+=("{\"name\":\"$pkg\",\"type\":\"aur\"}")
        done
    fi
    
    printf '%s\n' "${updates[@]}" | jq -s '.'
}

update_system() {
    local helper="pacman"
    
    if command -v yay &> /dev/null; then
        helper="yay"
    elif command -v paru &> /dev/null; then
        helper="paru"
    fi
    
    # Run in terminal
    $TERMINAL -e bash -c "sudo $helper -Syu; read -p 'Press enter to close'"
    echo '{"status":"updating"}'
}

search_package() {
    local query="$1"
    local helper="pacman"
    
    if command -v yay &> /dev/null; then
        helper="yay"
    elif command -v paru &> /dev/null; then
        helper="paru"
    fi
    
    $helper -Ss "$query" | head -20
}

install_package() {
    local package="$1"
    local helper="pacman"
    
    if command -v yay &> /dev/null; then
        helper="yay"
    elif command -v paru &> /dev/null; then
        helper="paru"
    fi
    
    $TERMINAL -e bash -c "sudo $helper -S $package; read -p 'Press enter to close'"
    echo '{"status":"installing","package":"'"$package"'"}'
}

remove_package() {
    local package="$1"
    $TERMINAL -e bash -c "sudo pacman -Rns $package; read -p 'Press enter to close'"
    echo '{"status":"removing","package":"'"$package"'"}'
}

case "$1" in
    updates)
        get_updates
        ;;
    list)
        list_updates
        ;;
    update)
        update_system
        ;;
    search)
        search_package "$2"
        ;;
    install)
        install_package "$2"
        ;;
    remove)
        remove_package "$2"
        ;;
    *)
        echo '{"error":"Unknown command"}'
        exit 1
        ;;
esac