#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/commons.sh"

case "$OS_ID" in
  debian|ubuntu)
    eval "$PKG_INSTALL weston wayland-protocols xwayland libwayland-dev" ;;
  fedora)
    eval "$PKG_INSTALL weston wayland-protocols xwayland" ;;
  arch|archos)
    eval "$PKG_INSTALL weston wayland wayland-protocols xorg-xwayland" ;;
  alpine)
    eval "$PKG_INSTALL weston wayland-protocols xwayland" ;;
esac
