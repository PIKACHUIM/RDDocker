#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/common.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_INSTALL weston wayland-protocols xwayland libwayland-dev" || true ;;
  fedora)
    eval "$PKG_INSTALL weston wayland-protocols xwayland" || true ;;
  arch)
    eval "$PKG_INSTALL weston wayland wayland-protocols xorg-xwayland" || true ;;
  alpine)
    eval "$PKG_INSTALL weston wayland-protocols xwayland" || true ;;
esac
