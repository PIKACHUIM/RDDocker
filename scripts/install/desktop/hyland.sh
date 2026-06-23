#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

case "$OS_ID" in
  debian)
    echo "deb http://deb.debian.org/debian unstable main" > /etc/apt/sources.list.d/sid.list
    printf 'Package: openssl openssl-provider-legacy libssl3 libssl-dev\nPin: release a=stable\nPin-Priority: 1001\nPackage: *\nPin: release a=unstable\nPin-Priority: 100\n' \
      > /etc/apt/preferences.d/99sid
    eval "$PKG_UPDATE"
    apt-get install -y -t unstable --no-install-recommends -o Dpkg::Options::="--force-overwrite" hyprland wayvnc xwayland kitty waybar pulseaudio git
    rm /etc/apt/sources.list.d/sid.list /etc/apt/preferences.d/99sid ;;
  ubuntu)
    eval "$PKG_INSTALL software-properties-common"
    add-apt-repository -y universe
    add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME)-backports main universe" 2>/dev/null || true
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL hyprland wayvnc xwayland kitty waybar pulseaudio git" || \
      echo "Warning: hyprland unavailable for Ubuntu ${VERSION_CODENAME}" >&2 ;;
  fedora)
    dnf copr enable -y solopasha/hyprland
    # Use --allowerasing so copr's libdisplay-info (so.2) replaces base version (so.1)
    dnf install -y --allowerasing hyprland wayvnc xorg-x11-server-Xwayland kitty waybar pulseaudio git ;;
  alpine)
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
      hyprland wayvnc xwayland kitty waybar pulseaudio git ;;
esac

mkdir -p /root/.config/hypr
cat > /root/.config/hypr/hyprland.conf << 'CONF'
monitor=,1920x1080,0x0,1
CONF

cat >> /run.sh << 'RUN_END'
echo "Starting Hyprland..."
export XDG_RUNTIME_DIR=/tmp/xdg-runtime
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
export WLR_BACKENDS=headless
export WLR_RENDERER=pixman
export WLR_LIBINPUT_NO_DEVICES=1
nohup Hyprland &
sleep 3
nohup wayvnc 0.0.0.0 5900 &
RUN_END
