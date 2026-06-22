#!/bin/bash
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/common.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL niri foot waybar wofi xwayland weston pulseaudio \
      wayland-protocols swaybg fonts-noto fonts-noto-cjk 2>/dev/null || \
      $PKG_INSTALL sway foot waybar wofi xwayland weston pulseaudio" ;;
  fedora)
    eval "$PKG_INSTALL niri foot waybar wofi xwayland weston pulseaudio 2>/dev/null || \
      dnf install -y sway foot waybar wofi xwayland weston pulseaudio" ;;
  arch)
    eval "$PKG_INSTALL niri foot waybar wofi xwayland weston pulseaudio" ;;
esac

cat >> /run.sh <<'EOF'
echo "Starting Niri Wayland..."
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p "$XDG_RUNTIME_DIR" && chmod 0700 "$XDG_RUNTIME_DIR"
export WAYLAND_DISPLAY=wayland-1
export DISPLAY=:9
nohup Xvfb :9 -ac -screen 0 1920x1080x24 &
bash /x11vnc.sh
nohup weston --backend=headless &
sleep 1
nohup niri 2>/dev/null || nohup sway &
EOF
