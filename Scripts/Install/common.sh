#!/bin/sh
# Common utilities - source this in every install script
set -e

. /etc/os-release 2>/dev/null || true
OS_ID="${ID:-unknown}"

case "$OS_ID" in
  debian|ubuntu)
    PKG_UPDATE="apt-get update"
    PKG_INSTALL="DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends"
    ;;
  fedora)
    PKG_UPDATE="dnf check-update || true"
    PKG_INSTALL="dnf install -y"
    ;;
  arch|archlinux)
    PKG_UPDATE="pacman -Sy --noconfirm"
    PKG_INSTALL="pacman -S --noconfirm"
    ;;
  alpine)
    PKG_UPDATE="apk update"
    PKG_INSTALL="apk add --no-cache"
    ;;
  *)
    echo "Unsupported OS: $OS_ID" && exit 1 ;;
esac

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  ARCH_DEB="amd64"  ARCH_RPM="x86_64"  ;;
  aarch64) ARCH_DEB="aarch64" ARCH_RPM="aarch64" ;;
  *)       ARCH_DEB="$ARCH"  ARCH_RPM="$ARCH"    ;;
esac

# Append a line to /run.sh
run_append() { echo "$*" >> /run.sh; }
