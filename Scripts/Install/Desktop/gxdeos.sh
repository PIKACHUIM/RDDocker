#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/common.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL ca-certificates apt-transport-https curl gnupg"
    curl -fsSL https://repo.gxde.top/gxde-os/key.gpg \
      | gpg --dearmor -o /usr/share/keyrings/gxde.gpg
    echo "deb [signed-by=/usr/share/keyrings/gxde.gpg] https://repo.gxde.top/gxde-os ${VERSION_CODENAME:-bookworm} main" \
      > /etc/apt/sources.list.d/gxde.list
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL gxde-desktop gxde-dock gxde-wallpapers pulseaudio 2>/dev/null || \
      $PKG_INSTALL dde-session-ui dde-launcher dde-dock dde-control-center dde-desktop pulseaudio" ;;
esac

cat >> /run.sh <<'EOF'
echo "Starting GXDeOS Desktop..."
export DISPLAY=:9
export $(dbus-launch)
nohup Xvfb :9 -ac -screen 0 1920x1080x24 &
bash /x11vnc.sh
nohup startdde &
EOF
