#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

# Install niri binary from GitHub releases (not available in apt repos)
install_niri_binary() {
  ARCH_BIN="x86_64-unknown-linux-gnu"
  [ "$(uname -m)" = "aarch64" ] && ARCH_BIN="aarch64-unknown-linux-gnu"
  NIRI_VER=$(curl -fsSL "https://api.github.com/repos/YaLTeR/niri/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
  curl -fsSL "https://github.com/YaLTeR/niri/releases/download/${NIRI_VER}/niri-${NIRI_VER}-${ARCH_BIN}.tar.gz" \
    | tar xz -C /usr/local/bin/ niri
}

case "$OS_ID" in
  debian)
    echo "deb http://deb.debian.org/debian unstable main" > /etc/apt/sources.list.d/sid.list
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 100\n' > /etc/apt/preferences.d/99sid
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL curl ca-certificates"
    update-ca-certificates 2>/dev/null || true
    install_niri_binary
    apt-get install -y -t unstable --no-install-recommends foot waybar wofi xwayland weston pulseaudio \
      wayland-protocols swaybg fonts-noto fonts-noto-cjk
    rm /etc/apt/sources.list.d/sid.list /etc/apt/preferences.d/99sid ;;
  ubuntu)
    eval "$PKG_INSTALL software-properties-common curl ca-certificates"
    update-ca-certificates 2>/dev/null || true
    add-apt-repository -y universe
    eval "$PKG_UPDATE"
    install_niri_binary
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
