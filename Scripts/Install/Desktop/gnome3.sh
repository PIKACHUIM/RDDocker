#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/common.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL pulseaudio gnome cmake git sudo software-properties-common" ;;
  fedora)
    eval "$PKG_INSTALL pulseaudio @gnome-desktop cmake git" ;;
  arch|archlinux)
    eval "$PKG_INSTALL pulseaudio gnome gnome-extra cmake git" ;;
  alpine)
    eval "$PKG_INSTALL pulseaudio gnome gnome-apps-core cmake git" ;;
esac

cat >> /run.sh <<'EOF'
echo "Starting GNOME Desktop..."
export DISPLAY=:9
export $(dbus-launch)
nohup Xvfb :9 -ac -screen 0 1920x1080x24 &
bash /x11vnc.sh
nohup gnome-session &
EOF
