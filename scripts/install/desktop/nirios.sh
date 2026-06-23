#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

case "$OS_ID" in
  debian)
    echo "deb http://deb.debian.org/debian unstable main" > /etc/apt/sources.list.d/sid.list
    echo "deb http://deb.debian.org/debian experimental main" >> /etc/apt/sources.list.d/sid.list
    printf 'Package: *\nPin: release a=experimental\nPin-Priority: 1\nPackage: *\nPin: release a=unstable\nPin-Priority: 100\n' > /etc/apt/preferences.d/99sid
    eval "$PKG_UPDATE"
    apt-get install -y -t unstable --no-install-recommends niri 2>/dev/null || \
      apt-get install -y -t experimental --no-install-recommends niri 2>/dev/null || \
      echo "Warning: niri unavailable for Debian ${VERSION_CODENAME}" >&2
    apt-get install -y -t unstable --no-install-recommends foot waybar wofi xwayland weston pulseaudio \
      wayland-protocols swaybg fonts-noto fonts-noto-cjk
    rm /etc/apt/sources.list.d/sid.list /etc/apt/preferences.d/99sid ;;
  ubuntu)
    eval "$PKG_INSTALL software-properties-common"
    add-apt-repository -y universe
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL niri foot waybar wofi xwayland weston pulseaudio \
      wayland-protocols swaybg fonts-noto fonts-noto-cjk" 2>/dev/null || \
      eval "$PKG_INSTALL foot waybar wofi xwayland weston pulseaudio \
      wayland-protocols swaybg fonts-noto fonts-noto-cjk" ;;
  fedora)
    eval "$PKG_INSTALL niri foot waybar wofi xwayland weston pulseaudio" ;;
  arch|archos)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL niri foot waybar wofi xorg-xwayland weston pulseaudio" ;;
  alpine)
    echo "Niri is not available on Alpine Linux" >&2; exit 1 ;;
esac

cat >> /run.sh << 'RUN_END'
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
RUN_END
