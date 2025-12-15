#!/bin/bash

VPN_CONFIG_DIR="$HOME/.config/omarchy/vpn"
VPN_STATE_FILE="/tmp/vpn-state"

get_vpn_status() {
    local connected=false
    local type=""
    local name=""
    local ip=""
    
    # Check OpenVPN
    if pgrep -x openvpn > /dev/null; then
        connected=true
        type="openvpn"
        name=$(ps aux | grep openvpn | grep -v grep | awk '{print $NF}' | xargs basename)
        ip=$(ip addr show tun0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    fi
    
    # Check WireGuard
    if wg show 2>/dev/null | grep -q interface; then
        connected=true
        type="wireguard"
        name=$(wg show | grep interface | awk '{print $2}')
        ip=$(wg show "$name" 2>/dev/null | grep "latest handshake" -A 1 | tail -1 | awk '{print $2}')
    fi
    
    # Check Tailscale
    if systemctl is-active --quiet tailscaled; then
        local ts_status=$(tailscale status --json 2>/dev/null)
        if echo "$ts_status" | jq -e '.BackendState == "Running"' > /dev/null 2>&1; then
            connected=true
            type="tailscale"
            name="Tailscale"
            ip=$(tailscale ip -4 2>/dev/null)
        fi
    fi
    
    # Check ProtonVPN
    if command -v protonvpn &> /dev/null; then
        local pvpn_status=$(protonvpn status 2>/dev/null)
        if echo "$pvpn_status" | grep -q "Connected"; then
            connected=true
            type="protonvpn"
            name=$(echo "$pvpn_status" | grep "Server:" | awk '{print $2}')
            ip=$(echo "$pvpn_status" | grep "IP:" | awk '{print $2}')
        fi
    fi
    
    cat <<EOF
{
  "connected": $connected,
  "type": "$type",
  "name": "$name",
  "ip": "$ip"
}
EOF
}

list_configs() {
    local configs=()
    
    # OpenVPN configs
    if [ -d "$VPN_CONFIG_DIR/openvpn" ]; then
        for conf in "$VPN_CONFIG_DIR/openvpn"/*.ovpn; do
            [ -f "$conf" ] && configs+=("{\"type\":\"openvpn\",\"name\":\"$(basename "$conf" .ovpn)\",\"path\":\"$conf\"}")
        done
    fi
    
    # WireGuard configs
    if [ -d "$VPN_CONFIG_DIR/wireguard" ]; then
        for conf in "$VPN_CONFIG_DIR/wireguard"/*.conf; do
            [ -f "$conf" ] && configs+=("{\"type\":\"wireguard\",\"name\":\"$(basename "$conf" .conf)\",\"path\":\"$conf\"}")
        done
    fi
    
    # Tailscale (always available if installed)
    if command -v tailscale &> /dev/null; then
        configs+=("{\"type\":\"tailscale\",\"name\":\"Tailscale\",\"path\":\"\"}")
    fi
    
    # ProtonVPN
    if command -v protonvpn &> /dev/null; then
        protonvpn list 2>/dev/null | grep -E "^\[" | while read -r line; do
            local server=$(echo "$line" | awk '{print $2}')
            configs+=("{\"type\":\"protonvpn\",\"name\":\"$server\",\"path\":\"\"}")
        done
    fi
    
    printf '%s\n' "${configs[@]}" | jq -s '.'
}

connect() {
    local type="$1"
    local config="$2"
    
    case "$type" in
        openvpn)
            sudo openvpn --config "$config" --daemon
            echo "$type:$config" > "$VPN_STATE_FILE"
            ;;
        wireguard)
            sudo wg-quick up "$config"
            echo "$type:$config" > "$VPN_STATE_FILE"
            ;;
        tailscale)
            sudo tailscale up
            echo "$type:" > "$VPN_STATE_FILE"
            ;;
        protonvpn)
            protonvpn connect "$config"
            echo "$type:$config" > "$VPN_STATE_FILE"
            ;;
    esac
    
    sleep 2
    get_vpn_status
}

disconnect() {
    local type="$1"
    
    case "$type" in
        openvpn)
            sudo killall openvpn
            ;;
        wireguard)
            local interface=$(wg show | grep interface | awk '{print $2}')
            [ -n "$interface" ] && sudo wg-quick down "$interface"
            ;;
        tailscale)
            sudo tailscale down
            ;;
        protonvpn)
            protonvpn disconnect
            ;;
        *)
            # Try to disconnect everything
            sudo killall openvpn 2>/dev/null
            wg show 2>/dev/null | grep interface | awk '{print $2}' | xargs -r -I {} sudo wg-quick down {}
            command -v tailscale &> /dev/null && sudo tailscale down
            command -v protonvpn &> /dev/null && protonvpn disconnect
            ;;
    esac
    
    rm -f "$VPN_STATE_FILE"
    get_vpn_status
}

autostart() {
    if [ -f "$VPN_STATE_FILE" ]; then
        local saved_vpn=$(cat "$VPN_STATE_FILE")
        local type=$(echo "$saved_vpn" | cut -d: -f1)
        local config=$(echo "$saved_vpn" | cut -d: -f2-)
        
        [ -n "$config" ] && connect "$type" "$config" || connect "$type"
    fi
}

case "$1" in
    status)
        get_vpn_status
        ;;
    list)
        list_configs
        ;;
    connect)
        connect "$2" "$3"
        ;;
    disconnect)
        disconnect "$2"
        ;;
    autostart)
        autostart
        ;;
    *)
        echo '{"error":"Unknown command"}'
        exit 1
        ;;
esac