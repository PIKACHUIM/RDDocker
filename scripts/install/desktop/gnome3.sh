#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

_ubver="${VERSION_ID%%.*}"
_is_ubuntu26=false
[ "$OS_ID" = "ubuntu" ] && [ "$_ubver" -ge 26 ] 2>/dev/null && _is_ubuntu26=true

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_UPDATE"
    if [ "$_is_ubuntu26" = true ]; then
      eval "$PKG_INSTALL gnome-shell gnome-remote-desktop pipewire pipewire-pulse sudo"
    else
      eval "$PKG_INSTALL gnome-core cmake git sudo pulseaudio-"
    fi ;;
  fedora)
    eval "$PKG_INSTALL pulseaudio @gnome-desktop cmake git" ;;
  arch|archos)
    eval "$PKG_INSTALL pulseaudio gnome gnome-extra cmake git" ;;
  alpine)
    eval "$PKG_INSTALL pulseaudio gnome gnome-apps-core cmake git" ;;
esac

if [ "$_is_ubuntu26" = true ]; then
  cat >> /run.sh <<'EOF'
# GNOME Wayland (Ubuntu 26+) --------------------------------
echo "Starting GNOME Wayland Desktop..."
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe
mkdir -p /run/user/0 && chmod 700 /run/user/0
export XDG_RUNTIME_DIR=/run/user/0
loginctl enable-linger root
systemctl start user@0.service || true
sleep 2
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/0/bus
# Configure VNC password (12345678) via gnome-remote-desktop
gsettings set org.gnome.desktop.remote-desktop.vnc auth-method password 2>/dev/null || true
gsettings set org.gnome.desktop.remote-desktop.vnc password '12345678' 2>/dev/null || true
# Start GNOME Shell headless
nohup env MUTTER_DEBUG_DUMMY_MODE_SPECS="1920x1080" \
  gnome-shell --headless --wayland &
sleep 3
# gnome-remote-desktop: VNC on :5900, RDP on :3389
systemctl --user start gnome-remote-desktop 2>/dev/null || \
  nohup gnome-remote-desktop-daemon &
EOF
else
  cat >> /run.sh <<'EOF'
# GNOME X11 -----------------------------------------------
echo "Starting GNOME Desktop..."
loginctl enable-linger root
systemctl start user@0.service
export XDG_RUNTIME_DIR=/run/user/0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/0/bus
export DISPLAY=:9
export XDG_SESSION_TYPE=x11
nohup Xvfb :9 -ac -screen 0 1920x1080x24 &
sleep 1
eval $(dbus-launch --sh-syntax)
bash /x11vnc.sh
DISPLAY=:9 nohup gnome-session &
EOF
fi
