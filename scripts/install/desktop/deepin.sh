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
    # Only give GXDE priority for DDE/deepin packages, not system libs
    printf 'Package: dde-* deepin-* libdde-* gxde-* libgxde-* dde libdframeworkdbus*\nPin: origin repo.gxde.top\nPin-Priority: 1001\nPackage: *\nPin: origin repo.gxde.top\nPin-Priority: 100\n' \
      > /etc/apt/preferences.d/99gxde
    eval "$PKG_UPDATE" || true
    mkdir -p /tmp/fake-trans/DEBIAN
    printf 'Package: translate-shell\nVersion: 0.9.9-1\nArchitecture: all\nMaintainer: dummy\nDescription: dummy\n' \
      > /tmp/fake-trans/DEBIAN/control
    dpkg-deb --build /tmp/fake-trans /tmp/fake-trans.deb
    dpkg -i /tmp/fake-trans.deb
    eval "$PKG_INSTALL gxde-session-ui dde-launcher dde-dock gxde-control-center dde-desktop" || \
      echo "Warning: DDE unavailable for Debian ${VERSION_CODENAME}" >&2
    eval "$PKG_INSTALL gxde-desktop --install-recommends" || \
          echo "Warning: DDE unavailable for Debian ${VERSION_CODENAME}" >&2
    rm -f /etc/apt/sources.list.d/gxde.list /etc/apt/preferences.d/99gxde ;;
  ubuntu)
    eval "$PKG_INSTALL software-properties-common"
    add-apt-repository -y ppa:ubuntudde-dev/stable 2>/dev/null || true
    eval "$PKG_UPDATE" || true
    eval "$PKG_INSTALL ubuntudde-dde pulseaudio" || \
      echo "Warning: ubuntudde-dde unavailable for Ubuntu ${VERSION_CODENAME}" >&2 ;;
  arch|archos)
    eval "$PKG_UPDATE"
    pacman -S --noconfirm --overwrite '/usr/share/dbus-1/services/org.deepin.dde.Power1.service' deepin pulseaudio ;;
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
DISPLAY=:9 nohup startdde &
RUN_END
