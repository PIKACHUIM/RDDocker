#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/common.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL pulseaudio xfce4 xfce4-terminal xfce4-goodies \
      adwaita-qt papirus-icon-theme moka-icon-theme xfwm4 qt5ct git"
    systemctl disable lightdm 2>/dev/null || true ;;
  fedora)
    eval "$PKG_INSTALL pulseaudio @xfce-desktop xfce4-terminal git" ;;
  arch)
    eval "$PKG_INSTALL pulseaudio xfce4 xfce4-goodies git" ;;
  alpine)
    eval "$PKG_INSTALL pulseaudio xfce4 xfce4-terminal xfce4-goodies git" ;;
esac

echo "LANG=en_US.UTF-8"   >  /etc/default/locale
echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale

cat >> /run.sh <<'EOF'
echo "Starting Xfce4 Desktop..."
export DISPLAY=:9
export $(dbus-launch)
service lightdm stop 2>/dev/null; killall xfce4-session 2>/dev/null || true
nohup Xvfb :9 -ac -screen 0 1600x900x24 &
bash /x11vnc.sh
nohup xfce4-session &
EOF
