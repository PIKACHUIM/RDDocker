#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

case "$OS_ID" in
  debian)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL ca-certificates apt-transport-https curl"
    case "${VERSION_CODENAME:-}" in
      trixie) GXDE_CODENAME=lizhi ;;
      *)      GXDE_CODENAME=bixie ;;
    esac
    echo "deb [arch=amd64,arm64 allow-insecure=yes trusted=yes] https://repo.gxde.top/gxde-os/${GXDE_CODENAME}/ /" \
      > /etc/apt/sources.list.d/gxde.list
    # Higher priority so GXDE packages override Debian dde-* packages (avoid conflicts)
    printf 'Package: *\nPin: origin repo.gxde.top\nPin-Priority: 1001\n' \
      > /etc/apt/preferences.d/99gxde
    eval "$PKG_UPDATE" || true
    mkdir -p /tmp/fake-trans/DEBIAN
    printf 'Package: translate-shell\nVersion: 0.9.9-1\nArchitecture: all\nMaintainer: dummy\nDescription: dummy\n' \
      > /tmp/fake-trans/DEBIAN/control
    dpkg-deb --build /tmp/fake-trans /tmp/fake-trans.deb
    dpkg -i /tmp/fake-trans.deb
    eval "$PKG_INSTALL dde-session-ui dde-launcher dde-dock dde-control-center dde-desktop"
    rm /etc/apt/preferences.d/99gxde ;;
  ubuntu)
    eval "$PKG_INSTALL software-properties-common"
    add-apt-repository -y ppa:ubuntudde-dev/stable 2>/dev/null || true
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL ubuntudde-dde pulseaudio" ;;
  arch|archos)
    eval "$PKG_UPDATE"
    pacman -S --noconfirm --overwrite '/usr/share/dbus-1/services/org.deepin.dde.Power1.service' deepin pulseaudio ;;
  # fedora: deepin-desktop-environment retired from Fedora 43+ (FESCo, May 2026)
  # fedora)
  #   eval "$PKG_INSTALL deepin-desktop-environment pulseaudio" ;;
  alpine)
    echo "Deepin DE is not supported on Alpine Linux" >&2; exit 1 ;;
esac

cat >> /run.sh << 'RUN_END'
echo "Starting Deepin Desktop..."
export DISPLAY=:9
nohup Xvfb :9 -ac -screen 0 1920x1080x24 &
sleep 1
eval $(dbus-launch --sh-syntax)
bash /x11vnc.sh
nohup startdde &
RUN_END
