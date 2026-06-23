#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL gnome-core cmake git sudo pulseaudio-" ;;
  fedora)
    eval "$PKG_INSTALL pulseaudio @gnome-desktop cmake git" ;;
  arch|archos)
    eval "$PKG_INSTALL pulseaudio gnome gnome-extra cmake git" ;;
  alpine)
    eval "$PKG_INSTALL pulseaudio gnome gnome-apps-core cmake git" ;;
esac

cat >> /run.sh <<'EOF'
echo "Starting GNOME Desktop..."
export DISPLAY=:9
export XDG_SESSION_TYPE=x11
nohup Xvfb :9 -ac -screen 0 1920x1080x24 &
sleep 1
eval $(dbus-launch --sh-syntax)
bash /x11vnc.sh
nohup gnome-session &
EOF
