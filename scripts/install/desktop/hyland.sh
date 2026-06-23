#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$INSTALL_DIR/common.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_UPDATE"
    eval "$PKG_INSTALL hyprland wayvnc xwayland kitty waybar pulseaudio git" ;;
  fedora)
    eval "$PKG_INSTALL hyprland wayvnc xwayland kitty waybar pulseaudio git" ;;
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
