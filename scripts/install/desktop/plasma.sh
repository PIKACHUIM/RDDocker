#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

case "$OS_ID" in
  debian)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL pulseaudio kde-plasma-desktop git cmake nano vim" ;;
  ubuntu)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL software-properties-common"
    add-apt-repository -y ppa:kubuntu-ppa/backports 2>/dev/null || true
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL pulseaudio kubuntu-desktop git cmake nano vim" \
      || eval "$PKG_INSTALL pulseaudio kde-plasma-desktop git cmake nano vim" ;;
  fedora)
    eval "$PKG_INSTALL pipewire-pulseaudio @kde-desktop-environment cmake git" ;;
  arch|archos)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL pulseaudio plasma kde-applications cmake git" ;;
  alpine)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL pulseaudio plasma-desktop kde-applications-base cmake git" ;;
esac

cp "$INSTALL_DIR/configs/sddm.conf" /etc/sddm.config 2>/dev/null || true

cat >> /run.sh <<'EOF'
echo "Starting KDE Plasma Desktop..."
export DISPLAY=:9
systemctl disable sddm 2>/dev/null || true
service sddm stop 2>/dev/null; killall startplasma-x11 2>/dev/null || true
killall plasma_session 2>/dev/null; killall kwin_x11 2>/dev/null || true
nohup Xvfb :9 -ac -screen 0 1920x1080x24 &
sleep 1
eval $(dbus-launch --sh-syntax)
bash /x11vnc.sh
nohup startplasma-x11 &
EOF
