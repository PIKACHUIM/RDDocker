#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL ca-certificates apt-transport-https curl"
    # Lingmo OS repository
    curl -fsSL https://repo.lingmo.org/lingmo-os/key.gpg \
      | gpg --dearmor -o /usr/share/keyrings/lingmo.gpg 2>/dev/null || true
    echo "deb [signed-by=/usr/share/keyrings/lingmo.gpg] https://repo.lingmo.org/lingmo-os ${VERSION_CODENAME:-bookworm} main" \
      > /etc/apt/sources.list.d/lingmo.list 2>/dev/null || true
    eval "$PKG_UPDATE" || true
    eval "$PKG_INSTALL lingmo-desktop pulseaudio 2>/dev/null || \
      $PKG_INSTALL lingmo-core lingmo-workspace-base pulseaudio || true" ;;
esac

cp "$INSTALL_DIR/configs/de-lingmo.sh" /usr/local/bin/de-lingmo.sh
chmod +x /usr/local/bin/de-lingmo.sh

cat >> /run.sh <<'EOF'
echo "Starting Lingmo Desktop..."
export DISPLAY=:9
nohup Xvfb :9 -ac -screen 0 1920x1080x24 &
sleep 1
eval $(dbus-launch --sh-syntax)
bash /x11vnc.sh
nohup /usr/local/bin/de-lingmo.sh &
EOF
