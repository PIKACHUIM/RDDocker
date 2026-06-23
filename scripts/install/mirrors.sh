#!/bin/sh
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/commons.sh"

# Use MIRROR env var if set; skip rewrite if empty (keeps official mirrors for CI)
MIRROR="${MIRROR:-}"
[ -z "$MIRROR" ] && eval "$PKG_UPDATE" && exit 0

case "$OS_ID" in
  debian)
    # bookworm/trixie use new .sources format
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then
      sed -i "s|deb.debian.org|$MIRROR|g; s|security.debian.org|$MIRROR|g" \
        /etc/apt/sources.list.d/debian.sources
    else
      sed -i "s|deb.debian.org|$MIRROR|g; s|security.debian.org|$MIRROR|g" \
        /etc/apt/sources.list
    fi
    ;;
  ubuntu)
    find /etc/apt -name "*.list" -o -name "*.sources" 2>/dev/null | xargs \
      sed -i "s|archive.ubuntu.com|$MIRROR|g; s|security.ubuntu.com|$MIRROR|g" 2>/dev/null || true
    ;;
  fedora)
    echo "fastestmirror=True" >> /etc/dnf/dnf.conf
    ;;
  arch|archos)
    sed -i '/^Server =/s/^/#/' /etc/pacman.d/mirrorlist
    echo "Server = https://$MIRROR/archos/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
    # archoscn
    if ! grep -q archoscn /etc/pacman.conf; then
      printf '\n[archoscn]\nServer = https://%s/archoscn/$arch\n' "$MIRROR" >> /etc/pacman.conf
    fi
    ;;
  alpine)
    VER=$(cut -d. -f1-2 /etc/alpine-release)
    { echo "https://$MIRROR/alpine/v${VER}/main"
      echo "https://$MIRROR/alpine/v${VER}/community"; } > /etc/apk/repositories
    ;;
esac

eval "$PKG_UPDATE"
