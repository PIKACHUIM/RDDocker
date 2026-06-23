#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/commons.sh"

case "$OS_ID" in
  debian)
    # hyprland not in bookworm/trixie; use sid with pinning to avoid conflicts
    echo "deb http://deb.debian.org/debian unstable main" > /etc/apt/sources.list.d/sid.list
    printf 'Package: openssl openssl-provider-legacy libssl3 libssl-dev\nPin: release a=stable\nPin-Priority: 1001\nPackage: *\nPin: release a=unstable\nPin-Priority: 100\n' \
      > /etc/apt/preferences.d/99sid
    eval "$PKG_UPDATE"
    apt-get install -y -t unstable --no-install-recommends hyprland wayvnc xwayland kitty waybar pulseaudio git
    rm /etc/apt/sources.list.d/sid.list /etc/apt/preferences.d/99sid ;;
  ubuntu)
    eval "$PKG_INSTALL software-properties-common"
    add-apt-repository -y universe
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL hyprland wayvnc xwayland kitty waybar pulseaudio git" ;;
  fedora)
    # Try official repo first, fall back to copr with libdisplay-info dep
    eval "$PKG_INSTALL hyprland wayvnc xorg-x11-server-Xwayland kitty waybar pulseaudio git" 2>/dev/null || {
      dnf install -y libdisplay-info 2>/dev/null || true
      dnf copr enable -y solopasha/hyprland
      eval "$PKG_INSTALL hyprland wayvnc xorg-x11-server-Xwayland kitty waybar pulseaudio git"
    } ;;
  alpine)
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
      hyprland wayvnc xwayland kitty waybar pulseaudio git ;;
esac

cat >> /run.sh <<'EOF'
echo "Starting Hyprland..."
export XDG_RUNTIME_DIR=/tmp/xdg-runtime
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
export WLR_BACKENDS=headless
export WLR_RENDERER=pixman
export WLR_LIBINPUT_NO_DEVICES=1
nohup Hyprland &
sleep 3
nohup wayvnc 0.0.0.0 5900 &
EOF
