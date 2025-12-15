// FILE: /home/lilith/code-shit/quickshell/setup.sh
#!/bin/bash

echo "Setting up Caelestia-style Quickshell for SwayFX..."

# Install dependencies
sudo pacman -S --needed \
    qt6-base \
    qt6-declarative \
    qt6-wayland \
    playerctl \
    pactl \
    pulseaudio \
    bluetooth \
    bluez \
    bluez-utils \
    networkmanager \
    nm-connection-editor \
    lm_sensors \
    htop \
    jq \
    rofi \
    mako \
    swaync \
    swaylock \
    swayidle \
    wlogout \
    nerd-fonts \
    ttf-jetbrains-mono-nerd \
    papirus-icon-theme \
    materia-gtk-theme \
    qt5ct \
    kvantum

# Install AUR dependencies
yay -S --needed \
    quickshell \
    swayfx-git \
    catppuccin-gtk-theme-mocha \
    catppuccin-cursors-mocha

# Create directories
mkdir -p ~/.config/quickshell/panels
mkdir -p ~/.config/omarchy/scripts
mkdir -p ~/.config/omarchy/vpn/{openvpn,wireguard}
mkdir -p ~/.config/rofi
mkdir -p ~/.config/swaync

# Copy configuration files
cp -r components/* ~/.config/quickshell/
cp -r panels/* ~/.config/quickshell/panels/
cp -r omarchy/scripts/* ~/.config/omarchy/scripts/
cp shell.qml ~/.config/quickshell/
cp theme/theme.qml ~/.config/quickshell/theme/

# Make scripts executable
chmod +x ~/.config/omarchy/scripts/*.sh

# Set up SwayFX config
if [ ! -f ~/.config/sway/config ]; then
    mkdir -p ~/.config/sway
    cp configs/swayfx-config ~/.config/sway/config
fi

# Set up Rofi
cat > ~/.config/rofi/launcher.rasi << EOF
@theme "/usr/share/rofi/themes/catppuccin-mocha.rasi"
* {
    background-color: transparent;
}

window {
    background-color: #1e1e2e;
    border-radius: 12px;
    padding: 12px;
}

entry {
    background-color: #313244;
    border-radius: 8px;
    padding: 8px;
    margin: 4px;
}

listview {
    background-color: transparent;
    border-radius: 8px;
    padding: 4px;
    margin: 4px;
}

element {
    background-color: transparent;
    border-radius: 4px;
    padding: 8px;
}

element selected {
    background-color: #89b4fa;
    color: #1e1e2e;
}
EOF

# Set up environment
cat >> ~/.profile << EOF
# Quickshell environment
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
EOF

echo "Setup complete!"
echo "To start:"
echo "1. Log out and select SwayFX session"
echo "2. Run: quickshell ~/.config/quickshell/shell.qml"
echo "3. Enjoy your Caelestia-style desktop!"