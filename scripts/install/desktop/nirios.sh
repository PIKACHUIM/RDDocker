#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

case "$OS_ID" in
  debian)
    echo "deb http://deb.debian.org/debian trixie main" > /etc/apt/sources.list.d/trixie.list
    eval "$PKG_UPDATE"
    apt-get install -y -t trixie --no-install-recommends niri foot waybar wofi xwayland weston pulseaudio \
      wayland-protocols swaybg fonts-noto fonts-noto-cjk
    rm /etc/apt/sources.list.d/trixie.list ;;
  ubuntu)
    eval "$PKG_INSTALL software-properties-common"
    add-apt-repository -y universe
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL niri foot waybar wofi xwayland weston pulseaudio \
      wayland-protocols swaybg fonts-noto fonts-noto-cjk" ;;
  fedora)
    eval "$PKG_INSTALL niri foot waybar wofi xwayland weston pulseaudio" ;;
  arch|archos)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL niri foot waybar wofi xorg-xwayland weston pulseaudio" ;;
  alpine)
    echo "Niri is not available on Alpine Linux" >&2; exit 1 ;;
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
nohup niri &
EOF
