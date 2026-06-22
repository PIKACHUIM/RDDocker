#!/bin/bash
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/common.sh"

case "$OS_ID" in
  debian)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL ca-certificates apt-transport-https"
    curl -fsSL https://repo.gxde.top/gxde-os/key.gpg \
      | gpg --dearmor -o /usr/share/keyrings/gxde.gpg 2>/dev/null || true
    echo "deb [signed-by=/usr/share/keyrings/gxde.gpg] https://repo.gxde.top/gxde-os bookworm main" \
      > /etc/apt/sources.list.d/gxde.list 2>/dev/null || true
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL dde-session-ui dde-launcher dde-dock dde-control-center \
      dde-desktop pulseaudio" ;;
  ubuntu)
    add-apt-repository -y ppa:ubuntudde-dev/stable 2>/dev/null || true
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL ubuntudde-dde pulseaudio" ;;
  fedora)
    eval "$PKG_INSTALL deepin-desktop-environment pulseaudio" ;;
esac

cat >> /run.sh <<'EOF'
echo "Starting Deepin Desktop..."
export DISPLAY=:9
export $(dbus-launch)
nohup Xvfb :9 -ac -screen 0 1920x1080x24 &
bash /x11vnc.sh
nohup startdde &
EOF
